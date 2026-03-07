// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/anchors/application/anchor_notifier.dart';
import 'package:memo_care/features/anchors/data/anchor_dao.dart';
import 'package:memo_care/features/anchors/data/anchor_repository.dart';
import 'package:memo_care/features/anchors/domain/anchor_resolver.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';

/// Provides the [AnchorDao] from the database singleton.
final anchorDaoProvider = Provider<AnchorDao>((ref) {
  return ref.watch(appDatabaseProvider).anchorDao;
});

/// Provides the [AnchorRepository] wrapping the [AnchorDao].
final anchorRepositoryProvider = Provider<AnchorRepository>((ref) {
  return AnchorRepository(ref.watch(anchorDaoProvider));
});

/// Reactive stream of all meal anchors.
final allAnchorsProvider = StreamProvider.autoDispose<List<MealAnchor>>((ref) {
  return ref.watch(anchorRepositoryProvider).watchAll();
});

/// Provides a const [AnchorResolver] with default configuration.
///
/// Override in tests to inject a custom `AnchorConfig`.
final anchorResolverProvider = Provider<AnchorResolver>((ref) {
  return const AnchorResolver();
});

/// Provides the [AnchorNotifier] managing all meal anchors.
final anchorNotifierProvider =
    AsyncNotifierProvider.autoDispose<AnchorNotifier, List<MealAnchor>>(
  AnchorNotifier.new,
);
