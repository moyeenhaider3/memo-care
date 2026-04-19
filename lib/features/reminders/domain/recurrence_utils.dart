/// Weekly repeat helpers for reminder scheduling.
class RecurrenceUtils {
  RecurrenceUtils._();

  /// Encodes UI day set to DB CSV; `null` means every day (no weekday filter).
  static String? encodeRecurrenceDays(Set<int> selectedDaysMon0Sun6) {
    if (selectedDaysMon0Sun6.isEmpty || selectedDaysMon0Sun6.length == 7) {
      return null;
    }
    final sorted = selectedDaysMon0Sun6.toList()..sort();
    return sorted.join(',');
  }

  static Set<int> _parseDays(String csv) {
    return csv
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toSet();
  }

  /// Next calendar firing at [hour]:[minute] matching selected weekdays.
  static DateTime nextOccurrence({
    required int hour,
    required int minute,
    required Set<int> selectedDaysMon0Sun6,
    required DateTime now,
  }) {
    if (selectedDaysMon0Sun6.isEmpty || selectedDaysMon0Sun6.length == 7) {
      final today = DateTime(now.year, now.month, now.day, hour, minute);
      if (today.isAfter(now)) return today;
      return today.add(const Duration(days: 1));
    }

    final ok = selectedDaysMon0Sun6.map((i) => i + 1).toSet();
    for (var add = 0; add < 14; add++) {
      final base = now.add(Duration(days: add));
      final d = DateTime(base.year, base.month, base.day, hour, minute);
      if (ok.contains(d.weekday) && d.isAfter(now)) return d;
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Applies weekday filter to a same-day [candidate] time (local).
  static DateTime alignToSelectedDays({
    required DateTime candidate,
    required Set<int> selectedDaysMon0Sun6,
    required DateTime now,
  }) {
    return nextOccurrence(
      hour: candidate.hour,
      minute: candidate.minute,
      selectedDaysMon0Sun6: selectedDaysMon0Sun6,
      now: now,
    );
  }

  /// After DONE, schedule the next repeat using [recurrenceCsv] and wall time.
  static DateTime? nextFireAfterDone({
    required DateTime? lastScheduledLocal,
    required String? recurrenceCsv,
    required DateTime nowUtc,
  }) {
    if (lastScheduledLocal == null ||
        recurrenceCsv == null ||
        recurrenceCsv.isEmpty) {
      return null;
    }
    final days = _parseDays(recurrenceCsv);
    if (days.isEmpty) return null;

    final now = nowUtc.toLocal();
    final next = nextOccurrence(
      hour: lastScheduledLocal.hour,
      minute: lastScheduledLocal.minute,
      selectedDaysMon0Sun6: days,
      now: now,
    );
    return next.toUtc();
  }
}
