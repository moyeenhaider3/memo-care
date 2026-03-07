import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildReminderTtsText', () {
    test('includes medicine name, dosage, and context', () {
      final text = buildReminderTtsText(
        medicineName: 'Metformin',
        dosage: '500mg',
        contextPhrase: 'after your meal',
      );
      expect(
        text,
        'Time to take Metformin, 500mg, after your meal',
      );
    });

    test('omits dosage when null', () {
      final text = buildReminderTtsText(
        medicineName: 'Insulin',
        dosage: null,
        contextPhrase: 'before your meal',
      );
      expect(
        text,
        'Time to take Insulin, before your meal',
      );
    });

    test('omits dosage when empty', () {
      final text = buildReminderTtsText(
        medicineName: 'Insulin',
        dosage: '',
        contextPhrase: 'on an empty stomach',
      );
      expect(
        text,
        'Time to take Insulin, on an empty stomach',
      );
    });
  });

  group('MedicineTypeTts extension', () {
    test('beforeMeal context phrase', () {
      expect(
        MedicineType.beforeMeal.ttsContext,
        'before your meal',
      );
    });

    test('afterMeal context phrase', () {
      expect(
        MedicineType.afterMeal.ttsContext,
        'after your meal',
      );
    });

    test('emptyStomach context phrase', () {
      expect(
        MedicineType.emptyStomach.ttsContext,
        'on an empty stomach',
      );
    });

    test('fixedTime context phrase', () {
      expect(
        MedicineType.fixedTime.ttsContext,
        'at your scheduled time',
      );
    });

    test('doseGap context phrase', () {
      expect(
        MedicineType.doseGap.ttsContext,
        'for your next dose',
      );
    });
  });

  group('TTSService', () {
    test('isInitialized is false before initialize', () {
      final tts = TTSService();
      expect(tts.isInitialized, isFalse);
    });

    test('speak does nothing when not initialized', () async {
      final tts = TTSService();
      // Should not throw — graceful no-op.
      await tts.speak('test');
    });
  });
}
