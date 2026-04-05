import 'package:drift/drift.dart';

import 'package:memo_care/core/database/app_database.dart';

part 'anchor_dao.g.dart';

/// Data access object for meal time anchors (breakfast, lunch, dinner).
@DriftAccessor(tables: [MealAnchors])
class AnchorDao extends DatabaseAccessor<AppDatabase> with _$AnchorDaoMixin {
  AnchorDao(super.attachedDatabase);

  /// Watch all meal anchors.
  Stream<List<MealAnchorRow>> watchAllAnchors() {
    return select(mealAnchors).watch();
  }

  /// Watch a specific anchor by meal type.
  Stream<MealAnchorRow?> watchAnchorByMealType(String mealType) {
    return (select(
      mealAnchors,
    )..where((a) => a.mealType.equals(mealType))).watchSingleOrNull();
  }

  /// Insert a new meal anchor.
  Future<int> insertAnchor(MealAnchorsCompanion companion) {
    return into(mealAnchors).insert(companion);
  }

  /// Update an existing anchor.
  Future<bool> updateAnchor(MealAnchorsCompanion companion) {
    return update(mealAnchors).replace(companion);
  }

  /// Upsert an anchor — insert if not exists, update if exists.
  Future<int> upsertAnchor(MealAnchorsCompanion companion) {
    return into(mealAnchors).insertOnConflictUpdate(companion);
  }
}
