import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/features/escalation/application/escalation_controller.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EscalationController', () {
    test('initial state is not active', () {
      final controller = EscalationController(
        notificationService: NotificationService(),
      );
      expect(controller.isActive, isFalse);
      expect(controller.activeReminderId, isNull);
      expect(
        controller.currentLevel,
        EscalationLevel.silent,
      );
    });

    test('currentLevel defaults to silent', () {
      final controller = EscalationController(
        notificationService: NotificationService(),
      );
      expect(
        controller.currentLevel,
        EscalationLevel.silent,
      );
    });
  });
}
