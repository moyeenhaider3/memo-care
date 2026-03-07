// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/reminders/data/reminder_dao.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Provides the [ReminderDao] from the database singleton.
final reminderDaoProvider = Provider<ReminderDao>((ref) {
  return ref.watch(appDatabaseProvider).reminderDao;
});

/// Provides the [ReminderRepository] wrapping the [ReminderDao].
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(ref.watch(reminderDaoProvider));
});

/// Reactive stream of all active reminders, ordered by scheduled time.
final activeRemindersProvider =
    StreamProvider.autoDispose<List<Reminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchActive();
});

/// Reactive stream of reminders for a specific chain.
final chainRemindersProvider =
    StreamProvider.autoDispose.family<List<Reminder>, int>((ref, chainId) {
  return ref.watch(reminderRepositoryProvider).watchForChain(chainId);
});
