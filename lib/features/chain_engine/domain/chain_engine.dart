import 'package:fpdart/fpdart.dart';

import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_eval_result.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Pure Dart DAG evaluator — the core of MemoCare's chain
/// engine.
///
/// Given a confirmed reminder and its [ConfirmationState],
/// determines which downstream reminders should be activated,
/// suspended, or rescheduled.
///
/// **Resolution strategy:**
/// - [ConfirmationState.done]: LAZY — only immediate
///   downstream children (CHAIN-04)
/// - [ConfirmationState.skipped]: EAGER — all transitive
///   descendants (for suspension)
/// - [ConfirmationState.snoozed]: returns the confirmed
///   reminder itself (for rescheduling)
///
/// No Flutter imports. No I/O. No side effects. Runs in both
/// main isolate and alarm callback isolate (CHAIN-05).
class ChainEngine {
  /// Creates a [ChainEngine] instance.
  const ChainEngine();

  /// Evaluates the effect of confirming reminder
  /// [confirmedId] with [state].
  ///
  /// Returns:
  /// - `Right(List<Reminder>)`: reminders to activate
  ///   (DONE), suspend (SKIPPED), or reschedule (SNOOZED)
  /// - `Left(NodeNotFound)`: [confirmedId] not found in
  ///   [reminders]
  ChainEvalResult evaluate({
    required List<Reminder> reminders,
    required List<ChainEdge> edges,
    required int confirmedId,
    required ConfirmationState state,
  }) {
    // Validate that the confirmed node exists.
    final reminderMap = {for (final r in reminders) r.id: r};
    if (!reminderMap.containsKey(confirmedId)) {
      return left(NodeNotFound(nodeId: confirmedId));
    }

    return switch (state) {
      ConfirmationState.done => _activateDownstream(
          reminderMap: reminderMap,
          edges: edges,
          sourceId: confirmedId,
        ),
      ConfirmationState.snoozed => right(
          [reminderMap[confirmedId]!],
        ),
      ConfirmationState.skipped => _suspendDownstream(
          reminderMap: reminderMap,
          edges: edges,
          sourceId: confirmedId,
        ),
    };
  }

  /// LAZY resolution: returns only IMMEDIATE downstream
  /// children.
  ///
  /// For DONE confirmation, only the next step(s) are
  /// activated. Each of those steps will trigger their own
  /// downstream when confirmed. This prevents cascade storms
  /// (P-06).
  ChainEvalResult _activateDownstream({
    required Map<int, Reminder> reminderMap,
    required List<ChainEdge> edges,
    required int sourceId,
  }) {
    final downstream = <Reminder>[];
    for (final edge in edges) {
      if (edge.sourceId == sourceId) {
        final target = reminderMap[edge.targetId];
        if (target != null) {
          downstream.add(target);
        }
      }
    }
    return right(downstream);
  }

  /// EAGER collection: returns ALL transitive descendants.
  ///
  /// For SKIPPED confirmation, every downstream node —
  /// however deep — must be suspended. Uses a visited set to
  /// handle diamond DAGs (prevent adding the same node
  /// twice).
  ChainEvalResult _suspendDownstream({
    required Map<int, Reminder> reminderMap,
    required List<ChainEdge> edges,
    required int sourceId,
  }) {
    // Build adjacency list for efficient traversal.
    final adjacency = <int, List<int>>{};
    for (final edge in edges) {
      adjacency
          .putIfAbsent(edge.sourceId, () => [])
          .add(edge.targetId);
    }

    final suspended = <Reminder>[];
    final visited = <int>{};

    void walk(int current) {
      for (final targetId
          in adjacency[current] ?? const <int>[]) {
        if (visited.add(targetId)) {
          final target = reminderMap[targetId];
          if (target != null) {
            suspended.add(target);
          }
          walk(targetId);
        }
      }
    }

    walk(sourceId);
    return right(suspended);
  }
}
