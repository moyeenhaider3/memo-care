import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/data/reminder_dao.dart';

part 'history_entry.freezed.dart';
part 'history_entry.g.dart';

/// A single entry in the medication history log (HIST-01).
///
/// Represents a reminder with its confirmation outcome.
/// [status] is null if the reminder has no terminal confirmation
/// yet (still pending / missed).
@freezed
abstract class HistoryEntry with _$HistoryEntry {
  /// Creates a [HistoryEntry].
  const factory HistoryEntry({
    required int reminderId,
    required String medicineName,
    required DateTime scheduledAt,
    String? dosage,
    ConfirmationState? status,
    DateTime? confirmedAt,
  }) = _HistoryEntry;
  const HistoryEntry._();

  /// Deserialises from JSON.
  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);

  /// Maps from the raw Drift query row to domain model.
  factory HistoryEntry.fromQueryRow(HistoryQueryRow row) {
    return HistoryEntry(
      reminderId: row.reminderId,
      medicineName: row.medicineName,
      dosage: row.dosage,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        row.scheduledAt,
        isUtc: true,
      ),
      status: row.confirmationState != null
          ? ConfirmationState.values.firstWhere(
              (s) => s.name == row.confirmationState,
              orElse: () => ConfirmationState.skipped,
            )
          : null,
      confirmedAt: row.confirmedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              row.confirmedAt!,
              isUtc: true,
            )
          : null,
    );
  }

  /// Display label for the status.
  String get statusLabel => switch (status) {
    ConfirmationState.done => 'Taken',
    ConfirmationState.skipped => 'Skipped',
    ConfirmationState.snoozed => 'Snoozed',
    null => 'Missed',
  };
}
