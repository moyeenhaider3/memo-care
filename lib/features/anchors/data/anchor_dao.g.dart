// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_dao.dart';

// ignore_for_file: type=lint
mixin _$AnchorDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealAnchorsTable get mealAnchors => attachedDatabase.mealAnchors;
  AnchorDaoManager get managers => AnchorDaoManager(this);
}

class AnchorDaoManager {
  final _$AnchorDaoMixin _db;
  AnchorDaoManager(this._db);
  $$MealAnchorsTableTableManager get mealAnchors =>
      $$MealAnchorsTableTableManager(_db.attachedDatabase, _db.mealAnchors);
}
