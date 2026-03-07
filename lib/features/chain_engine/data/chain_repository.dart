import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/features/chain_engine/data/chain_dao.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/reminder_chain.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Repository bridging [ChainDao] → [ReminderChain] and [ChainEdge]
/// domain models.
class ChainRepository {
  ChainRepository(this._dao);
  final ChainDao _dao;

  // --------------- Chain queries ---------------

  /// Watch all chains as domain models, newest first.
  Stream<List<ReminderChain>> watchAllChains() {
    return _dao.watchAllChains().map(
      (rows) => rows.map(_chainFromRow).toList(),
    );
  }

  /// Watch a single chain by ID.
  Stream<ReminderChain?> watchChainById(int id) {
    return _dao
        .watchChainById(id)
        .map(
          (row) => row == null ? null : _chainFromRow(row),
        );
  }

  /// Create a new chain. Returns the auto-generated ID.
  Future<int> createChain({
    required String name,
    DateTime? createdAt,
  }) {
    return _dao.insertChain(
      ReminderChainsCompanion.insert(
        name: name,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  /// Update a chain from a domain model.
  Future<bool> updateChain(ReminderChain chain) {
    return _dao.updateChain(
      ReminderChainsCompanion(
        id: Value(chain.id),
        name: Value(chain.name),
        isActive: Value(chain.isActive),
        createdAt: Value(chain.createdAt),
      ),
    );
  }

  /// Delete a chain and all its edges.
  Future<void> deleteChain(int id) async {
    await _dao.deleteEdgesForChain(id);
    await _dao.deleteChain(id);
  }

  // --------------- Edge queries ---------------

  /// Watch all edges for a chain as domain models.
  Stream<List<ChainEdge>> watchEdgesForChain(int chainId) {
    return _dao
        .watchEdgesForChain(chainId)
        .map(
          (rows) => rows.map(_edgeFromRow).toList(),
        );
  }

  /// Create a new edge. Returns the auto-generated ID.
  Future<int> createEdge({
    required int chainId,
    required int sourceId,
    required int targetId,
  }) {
    return _dao.insertEdge(
      ChainEdgesCompanion.insert(
        chainId: chainId,
        sourceId: sourceId,
        targetId: targetId,
      ),
    );
  }

  /// Delete a single edge.
  Future<int> deleteEdge(int id) => _dao.deleteEdge(id);

  // --------------- One-shot queries ---------------

  /// Get all reminders for a chain (one-shot).
  Future<List<Reminder>> getReminders(int chainId) async {
    final rows = await _dao.getRemindersForChain(chainId);
    return rows.map(_reminderFromRow).toList();
  }

  /// Get all edges for a chain (one-shot).
  Future<List<ChainEdge>> getEdges(int chainId) async {
    final rows = await _dao.getEdgesForChain(chainId);
    return rows.map(_edgeFromRow).toList();
  }

  // --------------- Mapping ---------------

  ReminderChain _chainFromRow(ReminderChainRow row) => ReminderChain(
    id: row.id,
    name: row.name,
    isActive: row.isActive,
    createdAt: row.createdAt,
  );

  ChainEdge _edgeFromRow(ChainEdgeRow row) => ChainEdge(
    id: row.id,
    chainId: row.chainId,
    sourceId: row.sourceId,
    targetId: row.targetId,
  );

  Reminder _reminderFromRow(ReminderRow row) => Reminder(
    id: row.id,
    chainId: row.chainId,
    medicineName: row.medicineName,
    medicineType: MedicineType.fromDbString(row.medicineType),
    dosage: row.dosage,
    scheduledAt: row.scheduledAt,
    isActive: row.isActive,
    gapHours: row.gapHours,
  );
}
