// Riverpod family builder return types are not publicly
// exported.
// ignore_for_file: specify_nonobvious_property_types

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/chain_engine/domain/models/reminder_chain.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Immutable state snapshot for a single chain.
class ChainState {
  /// Creates a [ChainState].
  const ChainState({
    required this.chain,
    required this.reminders,
    required this.edges,
  });

  /// The chain metadata.
  final ReminderChain chain;

  /// All reminders belonging to this chain.
  final List<Reminder> reminders;

  /// All edges (dependencies) in this chain.
  final List<ChainEdge> edges;
}

/// Manages the state of a single reminder chain, keyed by
/// chain ID.
///
/// Loads chain data reactively and provides mutation methods
/// that validate via `ChainValidator` before persisting.
class ChainNotifier extends AsyncNotifier<ChainState> {
  /// Creates a [ChainNotifier] for the given [chainId].
  ChainNotifier(this.chainId);

  /// The chain this notifier manages.
  final int chainId;

  @override
  FutureOr<ChainState> build() async {
    final repo = ref.watch(chainRepositoryProvider);
    final chain =
        await repo.watchChainById(chainId).first;

    if (chain == null) {
      throw StateError('Chain $chainId not found');
    }

    final reminders = await repo.getReminders(chainId);
    final edges = await repo.getEdges(chainId);

    return ChainState(
      chain: chain,
      reminders: reminders,
      edges: edges,
    );
  }

  /// Adds an edge after validating no cycles are introduced.
  ///
  /// Returns `Right(void)` on success,
  /// `Left(ChainError)` on validation failure.
  Future<Either<ChainError, void>> addEdge({
    required int sourceId,
    required int targetId,
  }) async {
    final currentState = await future;
    final validator = ref.read(chainValidatorProvider);
    final repo = ref.read(chainRepositoryProvider);

    // Tentatively add the edge and validate the new graph.
    final newEdges = [
      ...currentState.edges.map(
        (e) =>
            (sourceId: e.sourceId, targetId: e.targetId),
      ),
      (sourceId: sourceId, targetId: targetId),
    ];
    final nodeIds = currentState.reminders
        .map((r) => r.id)
        .toList();

    final validation = validator.validate(
      nodeIds: nodeIds,
      edges: newEdges,
    );

    return validation.fold(
      left,
      (_) async {
        await repo.createEdge(
          chainId: currentState.chain.id,
          sourceId: sourceId,
          targetId: targetId,
        );
        ref.invalidateSelf();
        return right<ChainError, void>(null);
      },
    );
  }

  /// Removes an edge from the chain.
  Future<void> removeEdge(int edgeId) async {
    final repo = ref.read(chainRepositoryProvider);
    await repo.deleteEdge(edgeId);
    ref.invalidateSelf();
  }
}

/// Provider for [ChainNotifier], keyed by chain ID.
///
/// Auto-disposes when no longer watched.
final chainNotifierProvider = AsyncNotifierProvider
    .autoDispose
    .family<ChainNotifier, ChainState, int>(
      ChainNotifier.new,
    );
