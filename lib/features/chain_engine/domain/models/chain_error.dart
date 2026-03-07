/// Error types produced by the chain engine and validator.
///
/// Used as the `Left` side of `ChainEvalResult`
/// (`Either<ChainError, List<Reminder>>`).
///
/// Pure Dart — no Flutter imports.
sealed class ChainError {
  const ChainError();

  /// Human-readable error description for logging and
  /// debugging.
  String get message;
}

/// The chain contains a cycle — edges form a loop that
/// can never complete.
///
/// Detected by the chain validator using Kahn's algorithm
/// topological sort. Chains with cycles are rejected at
/// creation/mutation time (CHAIN-02).
final class CycleDetected extends ChainError {
  /// Creates a [CycleDetected] error.
  const CycleDetected();

  @override
  String get message =>
      'Chain contains a cycle — edges form a loop';
}

/// The chain exceeds the maximum allowed depth of
/// [maxDepth] levels.
///
/// Enforced to prevent unbounded cascade chains
/// (CHAIN-03). Default max depth: 10 nodes.
final class MaxDepthExceeded extends ChainError {
  /// Creates a [MaxDepthExceeded] error.
  const MaxDepthExceeded({
    required this.depth,
    required this.maxDepth,
  });

  /// The actual depth of the chain.
  final int depth;

  /// The maximum allowed depth (default: 10).
  final int maxDepth;

  @override
  String get message =>
      'Chain depth $depth exceeds maximum $maxDepth';
}

/// A referenced node ID was not found in the chain's
/// reminder list.
///
/// Indicates data inconsistency — an edge references a
/// reminder that doesn't exist in the chain.
final class NodeNotFound extends ChainError {
  /// Creates a [NodeNotFound] error.
  const NodeNotFound({required this.nodeId});

  /// The ID of the node that was not found.
  final int nodeId;

  @override
  String get message =>
      'Reminder node $nodeId not found in chain';
}
