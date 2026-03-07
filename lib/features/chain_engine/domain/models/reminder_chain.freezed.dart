// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_chain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReminderChain {

 int get id; String get name; DateTime get createdAt; bool get isActive;
/// Create a copy of ReminderChain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderChainCopyWith<ReminderChain> get copyWith => _$ReminderChainCopyWithImpl<ReminderChain>(this as ReminderChain, _$identity);

  /// Serializes this ReminderChain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderChain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,isActive);

@override
String toString() {
  return 'ReminderChain(id: $id, name: $name, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ReminderChainCopyWith<$Res>  {
  factory $ReminderChainCopyWith(ReminderChain value, $Res Function(ReminderChain) _then) = _$ReminderChainCopyWithImpl;
@useResult
$Res call({
 int id, String name, DateTime createdAt, bool isActive
});




}
/// @nodoc
class _$ReminderChainCopyWithImpl<$Res>
    implements $ReminderChainCopyWith<$Res> {
  _$ReminderChainCopyWithImpl(this._self, this._then);

  final ReminderChain _self;
  final $Res Function(ReminderChain) _then;

/// Create a copy of ReminderChain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderChain].
extension ReminderChainPatterns on ReminderChain {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderChain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderChain() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderChain value)  $default,){
final _that = this;
switch (_that) {
case _ReminderChain():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderChain value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderChain() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  DateTime createdAt,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderChain() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  DateTime createdAt,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ReminderChain():
return $default(_that.id,_that.name,_that.createdAt,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  DateTime createdAt,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ReminderChain() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReminderChain implements ReminderChain {
  const _ReminderChain({required this.id, required this.name, required this.createdAt, this.isActive = true});
  factory _ReminderChain.fromJson(Map<String, dynamic> json) => _$ReminderChainFromJson(json);

@override final  int id;
@override final  String name;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isActive;

/// Create a copy of ReminderChain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderChainCopyWith<_ReminderChain> get copyWith => __$ReminderChainCopyWithImpl<_ReminderChain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderChainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderChain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,isActive);

@override
String toString() {
  return 'ReminderChain(id: $id, name: $name, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ReminderChainCopyWith<$Res> implements $ReminderChainCopyWith<$Res> {
  factory _$ReminderChainCopyWith(_ReminderChain value, $Res Function(_ReminderChain) _then) = __$ReminderChainCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DateTime createdAt, bool isActive
});




}
/// @nodoc
class __$ReminderChainCopyWithImpl<$Res>
    implements _$ReminderChainCopyWith<$Res> {
  __$ReminderChainCopyWithImpl(this._self, this._then);

  final _ReminderChain _self;
  final $Res Function(_ReminderChain) _then;

/// Create a copy of ReminderChain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? isActive = null,}) {
  return _then(_ReminderChain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
