import 'package:just_audio/just_audio.dart';

/// Service for playing alarm sounds with loop support.
///
/// Uses `just_audio` to loop a reminder sound until the user
/// acknowledges.
class AudioService {
  /// Creates an [AudioService].
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  bool _playing = false;

  /// Whether sound is currently playing.
  bool get isPlaying => _playing;

  /// Starts looping the alarm sound.
  ///
  /// Uses the bundled alarm tone asset. If [assetPath] is null,
  /// defaults to a built-in alarm resource.
  Future<void> startLoop({String? assetPath}) async {
    if (_playing) return;

    try {
      await _player.setLoopMode(LoopMode.one);

      final source = assetPath ?? 'assets/audio/cheer_fanfare.wav';
      await _player.setAsset(source);
      await _player.play();
      _playing = true;
    } on Exception {
      // Audio failure should not prevent the reminder
      // from working.
      _playing = false;
    }
  }

  /// Stops the looping alarm sound.
  Future<void> stop() async {
    if (!_playing) return;
    await _player.stop();
    _playing = false;
  }

  /// Releases all resources held by the audio player.
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
