import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/oem_detector.dart';

void main() {
  group('OemDetector', () {
    test('returns Xiaomi guidance for xiaomi manufacturer', () {
      final guidance = OemDetector.getGuidanceForManufacturer('xiaomi');
      expect(guidance.oemName, 'Xiaomi (MIUI)');
      expect(guidance.severity, 10);
      expect(guidance.steps.length, 4);
    });

    test('returns Samsung guidance for samsung manufacturer', () {
      final guidance = OemDetector.getGuidanceForManufacturer('Samsung');
      expect(guidance.oemName, 'Samsung (OneUI)');
      expect(guidance.severity, 8);
    });

    test('handles case insensitivity', () {
      final guidance = OemDetector.getGuidanceForManufacturer('HUAWEI');
      expect(guidance.oemName, 'Huawei (EMUI)');
    });

    test('returns generic guidance for unknown OEM', () {
      final guidance = OemDetector.getGuidanceForManufacturer('Google');
      expect(guidance.oemName, 'Your device');
      expect(guidance.severity, 5);
    });

    test('covers all 6 aggressive OEMs', () {
      final oems = [
        'xiaomi',
        'samsung',
        'huawei',
        'oppo',
        'vivo',
        'oneplus',
      ];
      for (final oem in oems) {
        final guidance = OemDetector.getGuidanceForManufacturer(oem);
        expect(
          guidance.oemName,
          isNot('Your device'),
          reason: '$oem should have specific guidance',
        );
        expect(
          guidance.steps,
          isNotEmpty,
          reason: '$oem should have steps',
        );
      }
    });

    test('every guidance has warning text', () {
      final oems = [
        'xiaomi',
        'samsung',
        'huawei',
        'oppo',
        'vivo',
        'oneplus',
        'google',
      ];
      for (final oem in oems) {
        final guidance = OemDetector.getGuidanceForManufacturer(oem);
        expect(
          guidance.warningText,
          isNotEmpty,
          reason: '$oem should have warning text',
        );
      }
    });
  });
}
