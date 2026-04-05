import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds and shares medication history PDF reports.
class HistoryExportService {
  const HistoryExportService._();

  /// Generates and opens the platform share sheet for a history PDF.
  static Future<void> exportPdf({
    required List<HistoryEntry> entries,
    required DateTime weekStart,
    DateTime? selectedDay,
    String patientName = 'User',
  }) async {
    final bytes = await buildPdfBytes(
      entries: entries,
      weekStart: weekStart,
      selectedDay: selectedDay,
      patientName: patientName,
    );

    final suffix = selectedDay == null
        ? '${DateFormat('yyyyMMdd').format(weekStart)}_'
              '${DateFormat('yyyyMMdd').format(
                weekStart.add(const Duration(days: 6)),
              )}'
        : DateFormat('yyyyMMdd').format(selectedDay);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'memocare_history_$suffix.pdf',
    );
  }

  /// Builds PDF report bytes for sharing/export.
  static Future<Uint8List> buildPdfBytes({
    required List<HistoryEntry> entries,
    required DateTime weekStart,
    DateTime? selectedDay,
    String patientName = 'User',
  }) async {
    final sortedEntries = [...entries]
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final filteredEntries = selectedDay == null
        ? sortedEntries
        : sortedEntries
              .where((entry) => _isSameLocalDay(entry.scheduledAt, selectedDay))
              .toList();

    final generatedAt = DateTime.now();
    final reportRange = selectedDay == null
        ? '${DateFormat('MMM d').format(weekStart)} - '
              '${DateFormat('MMM d, yyyy').format(
                weekStart.add(const Duration(days: 6)),
              )}'
        : DateFormat('EEE, MMM d, yyyy').format(selectedDay);

    final doc = pw.Document()
      ..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => [
            pw.Text(
              'MemoCare Compliance Report',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Patient: $patientName'),
            pw.Text('Range: $reportRange'),
            pw.Text(
              'Generated: ${DateFormat('yyyy-MM-dd h:mm a').format(generatedAt)}',
            ),
            pw.SizedBox(height: 12),
            if (filteredEntries.isEmpty)
              pw.Text('No reminder history entries found for this period.')
            else
              pw.TableHelper.fromTextArray(
                headers: const [
                  'Medicine',
                  'Dose',
                  'Scheduled',
                  'Status',
                  'Confirmed',
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                data: filteredEntries.map((entry) {
                  final scheduled = entry.scheduledAt.toLocal();
                  final confirmed = entry.confirmedAt?.toLocal();
                  final confirmedText = confirmed == null
                      ? '-'
                      : DateFormat('yyyy-MM-dd h:mm a').format(confirmed);
                  return [
                    entry.medicineName,
                    entry.dosage ?? '-',
                    DateFormat('yyyy-MM-dd h:mm a').format(scheduled),
                    entry.statusLabel,
                    confirmedText,
                  ];
                }).toList(),
              ),
          ],
        ),
      );

    return doc.save();
  }

  static bool _isSameLocalDay(DateTime a, DateTime b) {
    final aLocal = a.toLocal();
    final bLocal = b.toLocal();
    return aLocal.year == bLocal.year &&
        aLocal.month == bLocal.month &&
        aLocal.day == bLocal.day;
  }
}
