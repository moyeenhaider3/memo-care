import 'package:flutter/foundation.dart';

/// Configuration for anchor-resolver timing offsets.
///
/// All offsets are relative to the anchor confirmation time
/// (or default time). This class makes the hardcoded values in
/// the architecture sketch configurable (ANCR-01).
///
/// Pure Dart — no Flutter imports.
@immutable
class AnchorConfig {
  /// Creates an [AnchorConfig] with sensible defaults that
  /// match the architecture specification.
  const AnchorConfig({
    this.beforeMealOffset = const Duration(minutes: -30),
    this.afterMealOffset = const Duration(minutes: 30),
    this.emptyStomachFastHours = 2,
    this.defaultGapHours = 4,
  });

  /// Offset applied to before-meal reminders.
  ///
  /// Negative duration: fire BEFORE the anchor time.
  /// Default: 30 minutes before meal.
  /// Example: lunch at 1:00 PM → fires at 12:30 PM.
  final Duration beforeMealOffset;

  /// Offset applied to after-meal reminders.
  ///
  /// Positive duration: fire AFTER the anchor time.
  /// Default: 30 minutes after meal.
  /// Example: lunch at 1:00 PM → fires at 1:30 PM.
  final Duration afterMealOffset;

  /// Minimum hours since last meal for empty-stomach
  /// pre-condition (ANCR-05).
  ///
  /// If a meal was confirmed within this window,
  /// empty-stomach reminders are NOT scheduled.
  /// Default: 2 hours.
  final int emptyStomachFastHours;

  /// Fallback gap hours for dose-gap reminders when
  /// `Reminder.gapHours` is null.
  ///
  /// Safety net — production reminders should always have
  /// gapHours set.
  /// Default: 4 hours.
  final int defaultGapHours;

  /// Default configuration — matches the architecture
  /// specification hardcoded values.
  static const defaults = AnchorConfig();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorConfig &&
          beforeMealOffset == other.beforeMealOffset &&
          afterMealOffset == other.afterMealOffset &&
          emptyStomachFastHours ==
              other.emptyStomachFastHours &&
          defaultGapHours == other.defaultGapHours;

  @override
  int get hashCode => Object.hash(
        beforeMealOffset,
        afterMealOffset,
        emptyStomachFastHours,
        defaultGapHours,
      );

  @override
  String toString() => 'AnchorConfig('
      'beforeMealOffset: $beforeMealOffset, '
      'afterMealOffset: $afterMealOffset, '
      'emptyStomachFastHours: $emptyStomachFastHours, '
      'defaultGapHours: $defaultGapHours)';
}
