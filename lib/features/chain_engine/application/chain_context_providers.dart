import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_context.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

/// Loads the chain context for a given reminder ID.
///
/// Queries:
/// 1. Load the reminder to get its `chainId`
/// 2. Load the chain name
/// 3. Load all edges & reminders for the chain
/// 4. Filter upstream (target == reminderId) and
///    downstream (source == reminderId)
///
/// `FutureProvider.family` because chain structure changes
/// infrequently — only on chain mutation.
// ignore: specify_nonobvious_property_types
final chainContextProvider = FutureProvider.family<ChainContext, int>((
  ref,
  reminderId,
) async {
  final reminderDao = ref.watch(reminderDaoProvider);
  final chainRepo = ref.watch(chainRepositoryProvider);

  // 1. Load current reminder row for chainId.
  final row = await reminderDao.getReminderById(reminderId);
  if (row == null) {
    throw Exception('Reminder $reminderId not found');
  }
  final chainId = row.chainId;

  // 2. Load chain name (stream → first event).
  final chain = await chainRepo.watchChainById(chainId).first;
  final chainName = chain?.name ?? 'Unknown Chain';

  // 3. Fetch all edges & reminders for this chain.
  final edges = await chainRepo.getEdges(chainId);
  final allReminders = await chainRepo.getReminders(chainId);

  // Build a quick lookup map keyed by reminder ID.
  final reminderMap = <int, Reminder>{
    for (final r in allReminders) r.id: r,
  };

  // The current reminder as a domain model.
  final current =
      reminderMap[reminderId] ??
      Reminder(
        id: row.id,
        chainId: row.chainId,
        medicineName: row.medicineName,
        medicineType: MedicineType.fromDbString(row.medicineType),
        dosage: row.dosage,
        scheduledAt: row.scheduledAt,
        isActive: row.isActive,
        gapHours: row.gapHours,
      );

  // 4. Filter upstream & downstream.
  final upstream = edges
      .where((e) => e.targetId == reminderId)
      .map((e) => reminderMap[e.sourceId])
      .whereType<Reminder>()
      .toList();

  final downstream = edges
      .where((e) => e.sourceId == reminderId)
      .map((e) => reminderMap[e.targetId])
      .whereType<Reminder>()
      .toList();

  return ChainContext(
    currentReminder: current,
    upstreamReminders: upstream,
    downstreamReminders: downstream,
    chainName: chainName,
  );
});
