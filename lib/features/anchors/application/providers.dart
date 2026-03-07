// Riverpod's StreamProvider.autoDispose types are not publicly exported.
// ignore_for_file: specify_nonobvious_property_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/anchors/data/anchor_dao.dart';
import 'package:memo_care/features/anchors/data/anchor_repository.dart';
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
