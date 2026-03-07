import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech service wrapping `FlutterTts`.
///
/// Pre-initialize on app startup via [initialize] to avoid
/// 300-800ms cold-start delay when first speech is requested
/// (PITFALLS.md §4).
///
/// In a background isolate (alarm callback), create a fresh
/// instance and initialize — objects cannot cross the isolate
/// boundary.
///
/// Speech rate is set to 0.45 (slower than default 0.5) for
/// elderly users who need more time to process spoken
/// information.
class TTSService {
  TTSService();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Whether [initialize] has been called successfully.
  bool get isInitialized => _isInitialized;

  /// Initialize the TTS engine. Must be called before
  /// [speak].
  ///
  /// Sets:
  /// - Language: en-US
  /// - Speech rate: 0.45 (slower for elderly)
  /// - Pitch: 1.0 (natural)
  /// - Volume: 1.0 (max)
  /// - Await speak completion: true (sequential speech)
  ///
  /// If the device has no TTS engine installed, this may
  /// throw. Callers should catch and log — TTS is an
  /// enhancement, not a blocker.
  Future<void> initialize() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1);
      await _tts.setVolume(1);
      await _tts.awaitSpeakCompletion(true);
      _isInitialized = true;
    } on Exception catch (e) {
      debugPrint('TTSService.initialize() failed: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Speak [text] aloud. No-op if not initialized.
  ///
  /// Returns when speech completes
  /// (`awaitSpeakCompletion` is true).
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint(
        'TTSService.speak() called before '
        'initialize — skipping',
      );
      return;
    }
    await _tts.speak(text);
  }

  /// Stop any in-progress speech.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Release TTS resources.
  Future<void> dispose() async {
    await _tts.stop();
    _isInitialized = false;
  }
}

/// Builds the TTS announcement text for a fired reminder.
///
/// Format: "Time to take {name}, {dose}, {context}"
///
/// Example:
/// ```text
/// "Time to take Metformin, 500 milligrams, after your
/// meal"
/// ```
///
/// If dosage is null or empty, the dose segment is omitted.
String buildReminderTtsText({
  required String medicineName,
  required String? dosage,
  required String contextPhrase,
}) {
  final doseSegment =
      (dosage != null && dosage.isNotEmpty)
          ? ', $dosage'
          : '';
  return 'Time to take $medicineName$doseSegment'
      ', $contextPhrase';
}
