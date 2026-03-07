import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/permission_service.dart';

void main() {
  group('PermissionCheckResult', () {
    test('allGranted returns true when all permissions granted', () {
      const result = PermissionCheckResult(
        notifications: true,
        exactAlarms: true,
        fullScreenIntent: true,
        batteryOptimization: true,
      );
      expect(result.allGranted, isTrue);
      expect(result.missingPermissions, isEmpty);
    });

    test('allGranted returns false when any permission missing', () {
      const result = PermissionCheckResult(
        notifications: true,
        exactAlarms: false,
        fullScreenIntent: true,
        batteryOptimization: true,
      );
      expect(result.allGranted, isFalse);
      expect(result.missingPermissions, ['exactAlarms']);
    });

    test('missingPermissions lists all missing', () {
      const result = PermissionCheckResult(
        notifications: false,
        exactAlarms: false,
        fullScreenIntent: false,
        batteryOptimization: false,
      );
      expect(
        result.missingPermissions,
        [
          'notifications',
          'exactAlarms',
          'fullScreenIntent',
          'batteryOptimization',
        ],
      );
    });

    test('missingPermissions lists subset of missing', () {
      const result = PermissionCheckResult(
        notifications: true,
        exactAlarms: false,
        fullScreenIntent: true,
        batteryOptimization: false,
      );
      expect(
        result.missingPermissions,
        ['exactAlarms', 'batteryOptimization'],
      );
    });
  });
}
