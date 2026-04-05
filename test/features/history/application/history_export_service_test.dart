import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/history/application/history_export_service.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';

void main() {
  group('HistoryExportService.buildPdfBytes', () {
    test('returns non-empty bytes with entries', () async {
      final entries = [
        HistoryEntry(
          reminderId: 1,
          medicineName: 'Metformin',
          dosage: '500 mg',
          scheduledAt: DateTime.utc(2026, 3, 29, 8),
          status: ConfirmationState.done,
          confirmedAt: DateTime.utc(2026, 3, 29, 8, 5),
        ),
      ];

      final bytes = await HistoryExportService.buildPdfBytes(
        entries: entries,
        weekStart: DateTime.utc(2026, 3, 23),
        patientName: 'Test User',
      );

      expect(bytes, isNotEmpty);
    });

    test('returns non-empty bytes for empty period', () async {
      final bytes = await HistoryExportService.buildPdfBytes(
        entries: const [],
        weekStart: DateTime.utc(2026, 3, 23),
        selectedDay: DateTime.utc(2026, 3, 25),
      );

      expect(bytes, isNotEmpty);
    });
  });
}
