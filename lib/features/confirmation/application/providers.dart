// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart';
import 'package:memo_care/features/confirmation/data/confirmation_dao.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation.dart';
import 'package:memo_care/features/confirmation/domain/snooze_limiter.dart';
import 'package:memo_care/features/confirmation/domain/undo_confirmation_service.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/reminders/application/providers.dart'
    as reminder_providers;
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

/// Provides the [ConfirmationDao] from the database singleton.
final confirmationDaoProvider = Provider<ConfirmationDao>((ref) {
  return ref.watch(appDatabaseProvider).confirmationDao;
});

/// Provides the [ConfirmationRepository] wrapping the
/// [ConfirmationDao].
final confirmationRepositoryProvider = Provider<ConfirmationRepository>((ref) {
  return ConfirmationRepository(
    ref.watch(confirmationDaoProvider),
  );
});

/// Snooze limiter provider — stateless, const-constructible.
final snoozeLimiterProvider = Provider<SnoozeLimiter>((ref) {
  return const SnoozeLimiter();
});

/// Confirmation service provider — orchestrates the full
/// confirmation flow (snooze check → record → chain eval).
final confirmationServiceProvider = Provider<ConfirmationService>((ref) {
  return ConfirmationService(
    chainEngine: ref.watch(chainEngineProvider),
    snoozeLimiter: ref.watch(snoozeLimiterProvider),
    confirmationRepository: ref.watch(confirmationRepositoryProvider),
    chainRepository: ref.watch(chainRepositoryProvider),
  );
});

/// Reactive stream of the latest confirmation for a specific
/// reminder.
final latestConfirmationProvider = StreamProvider.autoDispose
    .family<Confirmation?, int>((ref, reminderId) {
      return ref.watch(confirmationRepositoryProvider).watchLatest(reminderId);
    });

/// Provides the [UndoConfirmationService] for reversing
/// confirmation actions (A11Y-07).
final undoConfirmationServiceProvider = Provider<UndoConfirmationService>((
  ref,
) {
  final fastingState = ref.watch(fastingNotifierProvider);
  final fastingNotifier = ref.watch(fastingNotifierProvider.notifier);

  return UndoConfirmationService(
    confirmationRepository: ref.watch(confirmationRepositoryProvider),
    reminderRepository: ref.watch(
      reminder_providers.reminderRepositoryProvider,
    ),
    alarmScheduler: ref.watch(alarmSchedulerProvider),
    shouldSuppressSchedule: (reminder, scheduledAt) {
      final isMealLinked =
          reminder.medicineType == MedicineType.beforeMeal ||
          reminder.medicineType == MedicineType.afterMeal ||
          reminder.medicineType == MedicineType.emptyStomach;
      return fastingState.isActive &&
          fastingNotifier.isSuppressedDuringFast(
            scheduledAt: scheduledAt,
            isMealLinked: isMealLinked,
          );
    },
  );
});
