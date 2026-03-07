import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart'
    as chain_providers;
import 'package:memo_care/features/reminders/application/providers.dart'
    as reminder_providers;
import 'package:memo_care/features/templates/data/template_repository.dart';
import 'package:memo_care/features/templates/domain/template_service.dart';

/// Provides the [TemplateRepository].
///
/// In-memory, no dependencies — always available.
final templateRepositoryProvider =
    Provider<TemplateRepository>((ref) {
  return const TemplateRepository();
});

/// Provides the [TemplateService] for template instantiation.
///
/// Depends on chain + reminder repositories, chain validator,
/// and alarm scheduler from earlier phases.
final templateServiceProvider =
    Provider<TemplateService>((ref) {
  return TemplateService(
    chainRepository:
        ref.watch(chain_providers.chainRepositoryProvider),
    reminderRepository:
        ref.watch(reminder_providers.reminderRepositoryProvider),
    chainValidator:
        ref.watch(chain_providers.chainValidatorProvider),
    alarmScheduler: ref.watch(alarmSchedulerProvider),
  );
});
