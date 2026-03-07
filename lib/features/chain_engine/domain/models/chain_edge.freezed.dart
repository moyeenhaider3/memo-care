// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chain_edge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChainEdge {

 int get id; int get chainId; int get sourceId; int get targetId;
/// Create a copy of ChainEdge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChainEdgeCopyWith<ChainEdge> get copyWith => _$ChainEdgeCopyWithImpl<ChainEdge>(this as ChainEdge, _$identity);

  /// Serializes this ChainEdge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChainEdge&&(identical(other.id, id) || other.id == id)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.targetId, targetId) || other.targetId == targetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chainId,sourceId,targetId);

@override
String toString() {
  return 'ChainEdge(id: $id, chainId: $chainId, sourceId: $sourceId, targetId: $targetId)';
}


}

/// @nodoc
abstract mixin class $ChainEdgeCopyWith<$Res>  {
  factory $ChainEdgeCopyWith(ChainEdge value, $Res Function(ChainEdge) _then) = _$ChainEdgeCopyWithImpl;
@useResult
$Res call({
 int id, int chainId, int sourceId, int targetId
});




}
/// @nodoc
class _$ChainEdgeCopyWithImpl<$Res>
    implements $ChainEdgeCopyWith<$Res> {
  _$ChainEdgeCopyWithImpl(this._self, this._then);

  final ChainEdge _self;
  final $Res Function(ChainEdge) _then;

/// Create a copy of ChainEdge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chainId = null,Object? sourceId = null,Object? targetId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChainEdge].
extension ChainEdgePatterns on ChainEdge {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChainEdge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChainEdge() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChainEdge value)  $default,){
final _that = this;
switch (_that) {
case _ChainEdge():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChainEdge value)?  $default,){
final _that = this;
switch (_that) {
case _ChainEdge() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int chainId,  int sourceId,  int targetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChainEdge() when $default != null:
return $default(_that.id,_that.chainId,_that.sourceId,_that.targetId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int chainId,  int sourceId,  int targetId)  $default,) {final _that = this;
switch (_that) {
case _ChainEdge():
return $default(_that.id,_that.chainId,_that.sourceId,_that.targetId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int chainId,  int sourceId,  int targetId)?  $default,) {final _that = this;
switch (_that) {
case _ChainEdge() when $default != null:
return $default(_that.id,_that.chainId,_that.sourceId,_that.targetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChainEdge implements ChainEdge {
  const _ChainEdge({required this.id, required this.chainId, required this.sourceId, required this.targetId});
  factory _ChainEdge.fromJson(Map<String, dynamic> json) => _$ChainEdgeFromJson(json);

@override final  int id;
@override final  int chainId;
@override final  int sourceId;
@override final  int targetId;

/// Create a copy of ChainEdge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChainEdgeCopyWith<_ChainEdge> get copyWith => __$ChainEdgeCopyWithImpl<_ChainEdge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChainEdgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChainEdge&&(identical(other.id, id) || other.id == id)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.targetId, targetId) || other.targetId == targetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chainId,sourceId,targetId);

@override
String toString() {
  return 'ChainEdge(id: $id, chainId: $chainId, sourceId: $sourceId, targetId: $targetId)';
}


}

/// @nodoc
abstract mixin class _$ChainEdgeCopyWith<$Res> implements $ChainEdgeCopyWith<$Res> {
  factory _$ChainEdgeCopyWith(_ChainEdge value, $Res Function(_ChainEdge) _then) = __$ChainEdgeCopyWithImpl;
@override @useResult
$Res call({
 int id, int chainId, int sourceId, int targetId
});




}
/// @nodoc
class __$ChainEdgeCopyWithImpl<$Res>
    implements _$ChainEdgeCopyWith<$Res> {
  __$ChainEdgeCopyWithImpl(this._self, this._then);

  final _ChainEdge _self;
  final $Res Function(_ChainEdge) _then;

/// Create a copy of ChainEdge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chainId = null,Object? sourceId = null,Object? targetId = null,}) {
  return _then(_ChainEdge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,chainId: null == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
