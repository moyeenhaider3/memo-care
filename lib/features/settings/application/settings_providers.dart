import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/settings/data/settings_repository.dart';
import 'package:memo_care/features/settings/domain/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences singleton — kept alive since it is used
/// app-wide.
///
/// Must be overridden in [ProviderScope] with
/// `sharedPreferencesProvider.overrideWithValue(prefs)` after
/// awaiting `SharedPreferences.getInstance()` in `main()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden '
    'with an instance in ProviderScope',
  ),
);

/// [SettingsRepository] singleton — kept alive, depends on
/// SharedPreferences.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final repo = SettingsRepository(prefs);
    ref.onDispose(repo.dispose);
    return repo;
  },
);

/// Reactive stream of [AppSettings] — rebuilds UI on any
/// settings change.
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});
