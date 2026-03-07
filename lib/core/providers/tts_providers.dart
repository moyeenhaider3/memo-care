import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/tts_service.dart';

/// Singleton [TTSService] provider.
///
/// Must be overridden in `ProviderScope` with the
/// pre-initialized instance from `main.dart`.
/// The default throws to catch missing overrides early.
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     ttsServiceProvider.overrideWithValue(ttsService),
///   ],
///   child: const App(),
/// )
/// ```
final ttsServiceProvider = Provider<TTSService>((ref) {
  throw UnimplementedError(
    'ttsServiceProvider must be overridden with a '
    'pre-initialized TTSService instance in '
    'ProviderScope.',
  );
});
