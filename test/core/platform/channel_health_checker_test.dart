import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/channel_health_checker.dart';

void main() {
  group('ChannelHealthStatus', () {
    test('allHealthy returns isHealthy = true', () {
      const status = ChannelHealthStatus.allHealthy();
      expect(status.isHealthy, isTrue);
      expect(status.issues, isEmpty);
    });

    test('notifications disabled shows correct issue', () {
      const status = ChannelHealthStatus(
        notificationsEnabled: false,
        silentChannelEnabled: true,
        urgentChannelEnabled: true,
        criticalChannelEnabled: true,
      );
      expect(status.isHealthy, isFalse);
      expect(
        status.issues,
        ['Notifications are turned off for this app'],
      );
    });

    test('single channel disabled shows specific message', () {
      const status = ChannelHealthStatus(
        notificationsEnabled: true,
        silentChannelEnabled: true,
        urgentChannelEnabled: false,
        criticalChannelEnabled: true,
      );
      expect(status.isHealthy, isFalse);
      expect(status.issues, [
        'Urgent Medication Alerts channel is disabled',
      ]);
    });

    test('multiple issues listed', () {
      const status = ChannelHealthStatus(
        notificationsEnabled: true,
        silentChannelEnabled: false,
        urgentChannelEnabled: false,
        criticalChannelEnabled: false,
      );
      expect(status.issues, hasLength(3));
    });
  });
}
