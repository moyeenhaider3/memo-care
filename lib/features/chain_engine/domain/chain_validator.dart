import 'dart:collection';

import 'package:fpdart/fpdart.dart';

import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';

/// Validates chain DAG structure: detects cycles and enforces
/// max depth.
///
/// Uses Kahn's algorithm (topological sort via BFS) for cycle
/// detection. Runs on every chain creation and edge mutation
/// (CHAIN-02).
///
/// Pure Dart — no Flutter imports. Safe to run in background
/// isolate (CHAIN-05).
class ChainValidator {
  /// Creates a validator with the given [maxDepth] limit.
  ///
  /// Default max depth: 10 (CHAIN-03).
  const ChainValidator({this.maxDepth = 10});

  /// Maximum allowed chain depth (longest path from root to
  /// leaf).
  final int maxDepth;

  /// Validates the chain structure defined by [nodeIds] and
  /// [edges].
  ///
  /// Returns:
  /// - `Right(List<int>)`: topologically sorted node IDs
  ///   (valid DAG)
  /// - `Left(CycleDetected)`: edges form a cycle
  /// - `Left(MaxDepthExceeded)`: longest path exceeds
  ///   [maxDepth]
  ///
  /// [edges] is a list of records with `sourceId` and
  /// `targetId` fields. These can come from `ChainEdge`
  /// models or be constructed inline for testing.
  Either<ChainError, List<int>> validate({
    required List<int> nodeIds,
    required List<({int sourceId, int targetId})> edges,
  }) {
    if (nodeIds.isEmpty) return right(const []);

    // Build adjacency list and in-degree map.
    final adjacency = <int, List<int>>{};
    final inDegree = <int, int>{};

    for (final id in nodeIds) {
      adjacency[id] = [];
      inDegree[id] = 0;
    }

    for (final edge in edges) {
      adjacency[edge.sourceId]?.add(edge.targetId);
      inDegree[edge.targetId] =
          (inDegree[edge.targetId] ?? 0) + 1;

      // Self-loops: node can never reach in-degree 0.
      if (edge.sourceId == edge.targetId) {
        inDegree[edge.sourceId] =
            (inDegree[edge.sourceId] ?? 0) + 1;
      }
    }

    // Kahn's algorithm: BFS from nodes with in-degree 0.
    final queue = Queue<int>();
    for (final entry in inDegree.entries) {
      if (entry.value == 0) queue.add(entry.key);
    }

    final sorted = <int>[];
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      sorted.add(node);

      for (final neighbor
          in adjacency[node] ?? const <int>[]) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    // If not all nodes are sorted, a cycle exists.
    if (sorted.length < nodeIds.length) {
      return left(const CycleDetected());
    }

    // Check max depth via longest path (DP on topological
    // order).
    return _checkDepth(sorted, adjacency);
  }

  /// Computes the longest path (depth) in the DAG using
  /// dynamic programming on the topologically sorted nodes.
  Either<ChainError, List<int>> _checkDepth(
    List<int> sorted,
    Map<int, List<int>> adjacency,
  ) {
    final depth = <int, int>{};
    for (final node in sorted) {
      depth[node] = 1; // each node has depth at least 1
    }

    var maxFoundDepth = 1;
    for (final node in sorted) {
      for (final neighbor
          in adjacency[node] ?? const <int>[]) {
        final newDepth = depth[node]! + 1;
        if (newDepth > (depth[neighbor] ?? 1)) {
          depth[neighbor] = newDepth;
          if (newDepth > maxFoundDepth) {
            maxFoundDepth = newDepth;
          }
        }
      }
    }

    if (maxFoundDepth > maxDepth) {
      return left(
        MaxDepthExceeded(
          depth: maxFoundDepth,
          maxDepth: maxDepth,
        ),
      );
    }

    return right(sorted);
  }
}
