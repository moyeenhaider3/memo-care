import 'package:memo_care/features/reminders/domain/models/reminder.dart';

export 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// The resolved chain context for a single reminder (VIEW-03).
///
/// Contains the current reminder, its upstream parents
/// (what triggered it), and downstream children
/// (what it triggers).
class ChainContext {
  const ChainContext({
    required this.currentReminder,
    required this.upstreamReminders,
    required this.downstreamReminders,
    required this.chainName,
  });

  /// The reminder being inspected.
  final Reminder currentReminder;

  /// Reminders that trigger this one (upstream edges where
  /// target == current).
  final List<Reminder> upstreamReminders;

  /// Reminders that this one triggers (downstream edges
  /// where source == current).
  final List<Reminder> downstreamReminders;

  /// Name of the chain this reminder belongs to.
  final String chainName;
}
