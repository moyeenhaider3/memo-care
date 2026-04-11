/// Shared constants and sample data for MemoCare trace verification (manual + tests).
///
/// Caregiver number: valid E.164 after normalization (`8527436117`, 10 digits).
const String kTraceVerificationCaregiverPhone = '+8527436117';

/// Monday 00:00 local for the ISO week that contains [instant].
DateTime traceVerificationWeekStartContaining(DateTime instant) {
  final local = instant.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  return day.subtract(Duration(days: local.weekday - DateTime.monday));
}

/// Sample `(scheduledAtUtc, weekStart)` for PDF export tests: always in the past, and
/// `weekStart` is Monday 00:00 local of the week containing that scheduled time.
({DateTime scheduledAtUtc, DateTime weekStart}) traceVerificationSampleHistoryExport() {
  final scheduledLocal = DateTime.now().toLocal().subtract(const Duration(hours: 2));
  final weekStart = traceVerificationWeekStartContaining(scheduledLocal);
  return (
    scheduledAtUtc: scheduledLocal.toUtc(),
    weekStart: weekStart,
  );
}
