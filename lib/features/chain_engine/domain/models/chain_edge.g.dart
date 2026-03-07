// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_edge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChainEdge _$ChainEdgeFromJson(Map<String, dynamic> json) => _ChainEdge(
  id: (json['id'] as num).toInt(),
  chainId: (json['chainId'] as num).toInt(),
  sourceId: (json['sourceId'] as num).toInt(),
  targetId: (json['targetId'] as num).toInt(),
);

Map<String, dynamic> _$ChainEdgeToJson(_ChainEdge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chainId': instance.chainId,
      'sourceId': instance.sourceId,
      'targetId': instance.targetId,
    };
