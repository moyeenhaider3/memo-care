import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo_care/core/database/app_database.dart';

/// Provides the singleton [AppDatabase] instance.
///
/// Uses a manual [Provider] instead of @Riverpod code-gen because
/// riverpod_generator was dropped due to analyzer version conflicts
/// with drift_dev.
///
/// The database is lazily opened on first access and closed when the
/// provider is disposed (app shutdown).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
