import 'package:freezed_annotation/freezed_annotation.dart';

part 'chain_edge.freezed.dart';
part 'chain_edge.g.dart';

/// A directed edge in a reminder chain DAG.
/// When source reminder is confirmed DONE, target reminder is activated.
@freezed
abstract class ChainEdge with _$ChainEdge {
  const factory ChainEdge({
    required int id,
    required int chainId,
    required int sourceId,
    required int targetId,
  }) = _ChainEdge;

  factory ChainEdge.fromJson(Map<String, dynamic> json) =>
      _$ChainEdgeFromJson(json);
}
