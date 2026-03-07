import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/features/anchors/data/anchor_dao.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';

/// Repository bridging [AnchorDao] → [MealAnchor] domain models.
///
/// Each user has 3 meal anchors (breakfast, lunch, dinner) with
/// configurable default times and daily confirmation tracking.
class AnchorRepository {
  AnchorRepository(this._dao);
  final AnchorDao _dao;

  /// Watch all meal anchors as domain models.
  Stream<List<MealAnchor>> watchAll() {
    return _dao.watchAllAnchors().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  /// Watch a specific anchor by meal type.
  Stream<MealAnchor?> watchByMealType(String mealType) {
    return _dao.watchAnchorByMealType(mealType).map(
          (row) => row == null ? null : _fromRow(row),
        );
  }

  /// Create a new meal anchor. Returns the auto-generated ID.
  Future<int> createAnchor({
    required String mealType,
    required int defaultTimeMinutes,
  }) {
    return _dao.insertAnchor(
      MealAnchorsCompanion.insert(
        mealType: mealType,
        defaultTime: defaultTimeMinutes,
      ),
    );
  }

  /// Update an anchor from a domain model.
  Future<bool> updateAnchor(MealAnchor anchor) {
    return _dao.updateAnchor(
      MealAnchorsCompanion(
        id: Value(anchor.id),
        mealType: Value(anchor.mealType),
        defaultTime: Value(anchor.defaultTimeMinutes),
        confirmedAt: Value(anchor.confirmedAt),
      ),
    );
  }

  /// Upsert an anchor — initialize defaults on first launch.
  Future<int> upsertAnchor({
    required String mealType,
    required int defaultTimeMinutes,
  }) {
    return _dao.upsertAnchor(
      MealAnchorsCompanion.insert(
        mealType: mealType,
        defaultTime: defaultTimeMinutes,
      ),
    );
  }

  // --------------- Mapping ---------------

  MealAnchor _fromRow(MealAnchorRow row) => MealAnchor(
        id: row.id,
        mealType: row.mealType,
        defaultTimeMinutes: row.defaultTime,
        confirmedAt: row.confirmedAt,
      );
}
