/// IDs and handles produced by `TestDataSeeder` for use in runners.
///
/// Populated after `TestDataSeeder.seedAll` completes.
class HarnessSeedContext {
  HarnessSeedContext._();

  /// Upcoming today (future) reminder ids in seed order.
  static List<int> upcomingReminderIds = [];

  /// Missed reminder id (past, no terminal confirmation).
  static int? missedReminderId;

  /// Middle reminder in a 3-node chain (step 2 of 3).
  static int? chainMiddleReminderId;

  /// Chain id for the 3-node chain.
  static int? chainTripleId;

  /// Reminder for alarm caregiver scenario (with phone in settings).
  static int? alarmWithCaregiverReminderId;

  /// Reminder for alarm without caregiver.
  static int? alarmNoCaregiverReminderId;

  /// History: reminder ids (past) for mixed statuses.
  static List<int> historyReminderIds = [];

  static void clear() {
    upcomingReminderIds = [];
    missedReminderId = null;
    chainMiddleReminderId = null;
    chainTripleId = null;
    alarmWithCaregiverReminderId = null;
    alarmNoCaregiverReminderId = null;
    historyReminderIds = [];
  }
}
