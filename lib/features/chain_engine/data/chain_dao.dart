import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';

part 'chain_dao.g.dart';

/// Data access object for reminder chains and their DAG edges.
@DriftAccessor(tables: [ReminderChains, ChainEdges, Reminders])
class ChainDao extends DatabaseAccessor<AppDatabase> with _$ChainDaoMixin {
  ChainDao(super.attachedDatabase);

  /// Watch all chains ordered by creation date (newest first).
  Stream<List<ReminderChainRow>> watchAllChains() {
    return (select(
      reminderChains,
    )..orderBy([(c) => OrderingTerm.desc(c.createdAt)])).watch();
  }

  /// Watch a single chain by ID.
  Stream<ReminderChainRow?> watchChainById(int id) {
    return (select(
      reminderChains,
    )..where((c) => c.id.equals(id))).watchSingleOrNull();
  }

  /// Insert a new chain. Returns the auto-generated ID.
  Future<int> insertChain(ReminderChainsCompanion companion) {
    return into(reminderChains).insert(companion);
  }

  /// Update an existing chain.
  Future<bool> updateChain(ReminderChainsCompanion companion) {
    return update(reminderChains).replace(companion);
  }

  /// Delete a chain by ID.
  Future<int> deleteChain(int id) {
    return (delete(reminderChains)..where((c) => c.id.equals(id))).go();
  }

  /// Watch all edges for a specific chain.
  Stream<List<ChainEdgeRow>> watchEdgesForChain(int chainId) {
    return (select(
      chainEdges,
    )..where((e) => e.chainId.equals(chainId))).watch();
  }

  /// Insert a new edge.
  Future<int> insertEdge(ChainEdgesCompanion companion) {
    return into(chainEdges).insert(companion);
  }

  /// Delete a single edge by ID.
  Future<int> deleteEdge(int id) {
    return (delete(chainEdges)..where((e) => e.id.equals(id))).go();
  }

  /// Delete all edges for a chain.
  Future<int> deleteEdgesForChain(int chainId) {
    return (delete(chainEdges)..where((e) => e.chainId.equals(chainId))).go();
  }

  /// Get all edges for a chain (one-shot).
  Future<List<ChainEdgeRow>> getEdgesForChain(int chainId) {
    return (select(chainEdges)..where((e) => e.chainId.equals(chainId))).get();
  }

  /// Get all reminders for a chain (one-shot).
  Future<List<ReminderRow>> getRemindersForChain(int chainId) {
    return (select(reminders)..where((r) => r.chainId.equals(chainId))).get();
  }
}
