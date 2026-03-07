import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/constants/notification_channels.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';

/// Callback type for notification action responses.
typedef NotificationResponseCallback = void Function(
  NotificationResponse response,
);

/// Wraps [FlutterLocalNotificationsPlugin] with 3 Android notification channels
/// matching [EscalationLevel] tiers.
///
/// Channels:
/// - `memo_silent`   — IMPORTANCE_LOW, no sound
/// - `memo_urgent`   — IMPORTANCE_HIGH, custom sound + vibration
/// - `memo_critical` — IMPORTANCE_MAX, full-screen intent
class NotificationService {
  /// Creates a [NotificationService].
  ///
  /// Accepts an optional [plugin] for testing with mocks.
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// The underlying plugin instance (for channel health checks).
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Initializes the notification plugin and creates all 3 channels.
  ///
  /// [onResponse] is called when a user taps a notification or action button.
  /// Must be called once at app startup before any [show] calls.
  Future<void> initialize({
    NotificationResponseCallback? onResponse,
    NotificationResponseCallback? onBackgroundResponse,
  }) async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundResponse,
    );

    // Create all 3 channels.
    await _createChannels();
    _initialized = true;
  }

  /// Shows a notification at the given [level] tier.
  ///
  /// - [id] — unique notification ID (use reminder ID hash).
  /// - [title] — notification title (e.g., "Time to take Metformin").
  /// - [body] — notification body (e.g., "500mg, after meal").
  /// - [level] — determines which channel and priority to use.
  /// - [fullScreenIntent] — if true AND level is fullscreen, shows
  ///   full-screen intent.
  /// - [actions] — notification action buttons (DONE/SNOOZE/SKIP).
  /// - [payload] — data string passed to the response callback.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required EscalationLevel level,
    bool fullScreenIntent = false,
    List<AndroidNotificationAction>? actions,
    String? payload,
  }) async {
    assert(
      _initialized,
      'NotificationService.initialize() must be called first',
    );

    final details = _buildNotificationDetails(
      level: level,
      fullScreenIntent:
          fullScreenIntent && level == EscalationLevel.fullscreen,
      actions: actions,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: details),
      payload: payload,
    );
  }

  /// Cancels a notification by [id].
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancels all active notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Checks if notifications are enabled globally.
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.areNotificationsEnabled() ?? false;
  }

  // ── Private helpers ─────────────────────────────────────────────

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Silent channel
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.silentId,
        NotificationChannels.silentName,
        description: NotificationChannels.silentDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );

    // Urgent channel (custom sound + vibration)
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.urgentId,
        NotificationChannels.urgentName,
        description: NotificationChannels.urgentDescription,
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(
          NotificationChannels.customSoundFile,
        ),
      ),
    );

    // Critical channel (full-screen intent)
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.criticalId,
        NotificationChannels.criticalName,
        description: NotificationChannels.criticalDescription,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound(
          NotificationChannels.customSoundFile,
        ),
      ),
    );
  }

  AndroidNotificationDetails _buildNotificationDetails({
    required EscalationLevel level,
    required bool fullScreenIntent,
    List<AndroidNotificationAction>? actions,
  }) {
    return switch (level) {
      EscalationLevel.silent => AndroidNotificationDetails(
          NotificationChannels.silentId,
          NotificationChannels.silentName,
          channelDescription: NotificationChannels.silentDescription,
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          ongoing: true,
          autoCancel: false,
          actions: actions,
        ),
      EscalationLevel.audible => AndroidNotificationDetails(
          NotificationChannels.urgentId,
          NotificationChannels.urgentName,
          channelDescription: NotificationChannels.urgentDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound(
            NotificationChannels.customSoundFile,
          ),
          ongoing: true,
          autoCancel: false,
          actions: actions,
        ),
      EscalationLevel.fullscreen => AndroidNotificationDetails(
          NotificationChannels.criticalId,
          NotificationChannels.criticalName,
          channelDescription: NotificationChannels.criticalDescription,
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound(
            NotificationChannels.customSoundFile,
          ),
          ongoing: true,
          autoCancel: false,
          fullScreenIntent: fullScreenIntent,
          actions: actions,
        ),
    };
  }
}
