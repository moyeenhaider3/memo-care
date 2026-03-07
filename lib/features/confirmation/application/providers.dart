// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/confirmation/data/confirmation_dao.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation.dart';

/// Provides the [ConfirmationDao] from the database singleton.
final confirmationDaoProvider = Provider<ConfirmationDao>((ref) {
  return ref.watch(appDatabaseProvider).confirmationDao;
});

/// Provides the [ConfirmationRepository] wrapping the [ConfirmationDao].
final confirmationRepositoryProvider = Provider<ConfirmationRepository>((ref) {
  return ConfirmationRepository(ref.watch(confirmationDaoProvider));
});

/// Reactive stream of the latest confirmation for a specific reminder.
final latestConfirmationProvider = StreamProvider.autoDispose
    .family<Confirmation?, int>((ref, reminderId) {
      return ref.watch(confirmationRepositoryProvider).watchLatest(reminderId);
    });
