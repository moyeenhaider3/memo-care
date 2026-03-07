import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of checking all critical permissions.
class PermissionCheckResult {
  /// Creates a [PermissionCheckResult].
  const PermissionCheckResult({
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreenIntent,
    required this.batteryOptimization,
  });

  /// Whether POST_NOTIFICATIONS is granted (always true on Android < 13).
  final bool notifications;

  /// Whether exact alarms can be scheduled.
  final bool exactAlarms;

  /// Whether full-screen intents are allowed (always true on Android < 14).
  final bool fullScreenIntent;

  /// Whether battery optimization is ignored (app is whitelisted).
  final bool batteryOptimization;

  /// True if all critical permissions are granted.
  bool get allGranted =>
      notifications && exactAlarms && fullScreenIntent && batteryOptimization;

  /// List of permission names that are NOT granted.
  List<String> get missingPermissions => [
    if (!notifications) 'notifications',
    if (!exactAlarms) 'exactAlarms',
    if (!fullScreenIntent) 'fullScreenIntent',
    if (!batteryOptimization) 'batteryOptimization',
  ];
}

/// Abstracts Android 12–15 permission complexity into a clean API.
///
/// Handles version-gated checks and requests for:
/// - POST_NOTIFICATIONS (Android 13+)
/// - SCHEDULE_EXACT_ALARM (Android 12+)
/// - USE_FULL_SCREEN_INTENT (Android 14+)
/// - REQUEST_IGNORE_BATTERY_OPTIMIZATIONS (all versions)
class PermissionService {
  /// Creates a [PermissionService].
  ///
  /// Accepts optional [deviceInfo] for testing.
  PermissionService({
    DeviceInfoPlugin? deviceInfo,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;
  int? _sdkVersion;

  /// Gets the Android SDK version, cached after first call.
  Future<int> get sdkVersion async {
    if (_sdkVersion != null) return _sdkVersion!;
    final info = await _deviceInfo.androidInfo;
    _sdkVersion = info.version.sdkInt;
    return _sdkVersion!;
  }

  // ── Notification Permission (Android 13+ / API 33) ─────────────

  /// Checks if POST_NOTIFICATIONS permission is granted.
  ///
  /// Returns true on Android < 13 (permission not required).
  Future<bool> isNotificationPermissionGranted() async {
    final sdk = await sdkVersion;
    if (sdk < 33) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Requests POST_NOTIFICATIONS permission.
  ///
  /// Returns the resulting [PermissionStatus].
  /// On Android < 13, always returns [PermissionStatus.granted].
  Future<PermissionStatus> requestNotificationPermission() async {
    final sdk = await sdkVersion;
    if (sdk < 33) return PermissionStatus.granted;
    return Permission.notification.request();
  }

  // ── Exact Alarm Permission (Android 12+ / API 31) ──────────────

  /// Checks if exact alarms can be scheduled.
  Future<bool> canScheduleExactAlarms() async {
    final sdk = await sdkVersion;
    if (sdk < 31) return true;
    return Permission.scheduleExactAlarm.isGranted;
  }

  /// Opens system settings for exact alarm permission.
  ///
  /// This is NOT a runtime dialog — it opens the Settings app.
  Future<void> requestExactAlarmPermission() async {
    await Permission.scheduleExactAlarm.request();
  }

  // ── Full-Screen Intent (Android 14+ / API 34) ──────────────────

  /// Checks if full-screen intents are allowed.
  ///
  /// Returns true on Android < 14 (permission not required).
  /// On Android 14+, there's no Flutter API to check this directly.
  /// We return true as a best-effort: the notification will degrade
  /// to heads-up if the permission was revoked.
  /// A proper check requires native `NotificationManager
  /// .canUseFullScreenIntent()` — deferred to Plan 03-08.
  Future<bool> canUseFullScreenIntent() async {
    final sdk = await sdkVersion;
    if (sdk < 34) return true;

    // Android 14+ requires USE_FULL_SCREEN_INTENT special permission.
    // flutter_local_notifications v21 and permission_handler v12
    // don't expose a check for this. The notification gracefully
    // degrades to heads-up if denied.
    // TODO(memo-care): Add native method channel check in Plan 03-08.
    return true;
  }

  /// Opens system settings for full-screen intent permission.
  Future<void> requestFullScreenIntentPermission() async {
    await openAppSettings();
  }

  // ── Battery Optimization ───────────────────────────────────────

  /// Checks if the app is whitelisted (ignoring battery optimization).
  Future<bool> isBatteryOptimizationIgnored() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Requests battery optimization exemption.
  ///
  /// Shows a system dialog (not app Settings).
  Future<PermissionStatus> requestBatteryOptimization() async {
    return Permission.ignoreBatteryOptimizations.request();
  }

  // ── Batch Operations ───────────────────────────────────────────

  /// Checks all critical permissions at once.
  ///
  /// Use during channel health checks or onboarding.
  Future<PermissionCheckResult> checkAllCritical() async {
    final results = await Future.wait([
      isNotificationPermissionGranted(),
      canScheduleExactAlarms(),
      canUseFullScreenIntent(),
      isBatteryOptimizationIgnored(),
    ]);

    return PermissionCheckResult(
      notifications: results[0],
      exactAlarms: results[1],
      fullScreenIntent: results[2],
      batteryOptimization: results[3],
    );
  }

  /// Requests all missing critical permissions sequentially.
  ///
  /// Sequential because Android only shows one permission dialog
  /// at a time. Returns the final state after all requests complete.
  Future<PermissionCheckResult> requestAllMissing() async {
    final current = await checkAllCritical();

    if (!current.notifications) {
      await requestNotificationPermission();
    }
    if (!current.exactAlarms) {
      await requestExactAlarmPermission();
    }
    if (!current.batteryOptimization) {
      await requestBatteryOptimization();
    }
    // Full-screen intent is requested last — it opens Settings
    // and the user must navigate back manually.
    if (!current.fullScreenIntent) {
      await requestFullScreenIntentPermission();
    }

    return checkAllCritical();
  }
}
