import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/core/platform/permission_service.dart';

/// Provides the singleton [NotificationService] instance.
///
/// Uses a manual [Provider] (not @Riverpod code-gen) because
/// riverpod_generator was dropped due to analyzer version conflicts
/// with drift_dev.
///
/// Must be overridden in the root [ProviderScope] with an
/// already-initialized instance, OR call
/// [NotificationService.initialize] in app bootstrap before any
/// provider reads this.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Default creates an uninitialized instance.
  // Override in main.dart bootstrap with pre-initialized instance.
  return NotificationService();
});

/// Provides the singleton [PermissionService] instance.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
