import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_chain.freezed.dart';
part 'reminder_chain.g.dart';

/// A named group of reminders forming a directed acyclic graph (DAG).
@freezed
abstract class ReminderChain with _$ReminderChain {
  const factory ReminderChain({
    required int id,
    required String name,
    required DateTime createdAt,
    @Default(true) bool isActive,
  }) = _ReminderChain;

  factory ReminderChain.fromJson(Map<String, dynamic> json) =>
      _$ReminderChainFromJson(json);
}
