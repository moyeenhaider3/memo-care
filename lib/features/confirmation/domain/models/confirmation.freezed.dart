// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirmation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Confirmation {

 int get id; int get reminderId; ConfirmationState get state; DateTime get confirmedAt; DateTime? get snoozeUntil;
/// Create a copy of Confirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmationCopyWith<Confirmation> get copyWith => _$ConfirmationCopyWithImpl<Confirmation>(this as Confirmation, _$identity);

  /// Serializes this Confirmation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Confirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.state, state) || other.state == state)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.snoozeUntil, snoozeUntil) || other.snoozeUntil == snoozeUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reminderId,state,confirmedAt,snoozeUntil);

@override
String toString() {
  return 'Confirmation(id: $id, reminderId: $reminderId, state: $state, confirmedAt: $confirmedAt, snoozeUntil: $snoozeUntil)';
}


}

/// @nodoc
abstract mixin class $ConfirmationCopyWith<$Res>  {
  factory $ConfirmationCopyWith(Confirmation value, $Res Function(Confirmation) _then) = _$ConfirmationCopyWithImpl;
@useResult
$Res call({
 int id, int reminderId, ConfirmationState state, DateTime confirmedAt, DateTime? snoozeUntil
});




}
/// @nodoc
class _$ConfirmationCopyWithImpl<$Res>
    implements $ConfirmationCopyWith<$Res> {
  _$ConfirmationCopyWithImpl(this._self, this._then);

  final Confirmation _self;
  final $Res Function(Confirmation) _then;

/// Create a copy of Confirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reminderId = null,Object? state = null,Object? confirmedAt = null,Object? snoozeUntil = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConfirmationState,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,snoozeUntil: freezed == snoozeUntil ? _self.snoozeUntil : snoozeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Confirmation].
extension ConfirmationPatterns on Confirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Confirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Confirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Confirmation value)  $default,){
final _that = this;
switch (_that) {
case _Confirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Confirmation value)?  $default,){
final _that = this;
switch (_that) {
case _Confirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int reminderId,  ConfirmationState state,  DateTime confirmedAt,  DateTime? snoozeUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Confirmation() when $default != null:
return $default(_that.id,_that.reminderId,_that.state,_that.confirmedAt,_that.snoozeUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int reminderId,  ConfirmationState state,  DateTime confirmedAt,  DateTime? snoozeUntil)  $default,) {final _that = this;
switch (_that) {
case _Confirmation():
return $default(_that.id,_that.reminderId,_that.state,_that.confirmedAt,_that.snoozeUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int reminderId,  ConfirmationState state,  DateTime confirmedAt,  DateTime? snoozeUntil)?  $default,) {final _that = this;
switch (_that) {
case _Confirmation() when $default != null:
return $default(_that.id,_that.reminderId,_that.state,_that.confirmedAt,_that.snoozeUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Confirmation implements Confirmation {
  const _Confirmation({required this.id, required this.reminderId, required this.state, required this.confirmedAt, this.snoozeUntil});
  factory _Confirmation.fromJson(Map<String, dynamic> json) => _$ConfirmationFromJson(json);

@override final  int id;
@override final  int reminderId;
@override final  ConfirmationState state;
@override final  DateTime confirmedAt;
@override final  DateTime? snoozeUntil;

/// Create a copy of Confirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmationCopyWith<_Confirmation> get copyWith => __$ConfirmationCopyWithImpl<_Confirmation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Confirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.state, state) || other.state == state)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.snoozeUntil, snoozeUntil) || other.snoozeUntil == snoozeUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reminderId,state,confirmedAt,snoozeUntil);

@override
String toString() {
  return 'Confirmation(id: $id, reminderId: $reminderId, state: $state, confirmedAt: $confirmedAt, snoozeUntil: $snoozeUntil)';
}


}

/// @nodoc
abstract mixin class _$ConfirmationCopyWith<$Res> implements $ConfirmationCopyWith<$Res> {
  factory _$ConfirmationCopyWith(_Confirmation value, $Res Function(_Confirmation) _then) = __$ConfirmationCopyWithImpl;
@override @useResult
$Res call({
 int id, int reminderId, ConfirmationState state, DateTime confirmedAt, DateTime? snoozeUntil
});




}
/// @nodoc
class __$ConfirmationCopyWithImpl<$Res>
    implements _$ConfirmationCopyWith<$Res> {
  __$ConfirmationCopyWithImpl(this._self, this._then);

  final _Confirmation _self;
  final $Res Function(_Confirmation) _then;

/// Create a copy of Confirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reminderId = null,Object? state = null,Object? confirmedAt = null,Object? snoozeUntil = freezed,}) {
  return _then(_Confirmation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConfirmationState,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,snoozeUntil: freezed == snoozeUntil ? _self.snoozeUntil : snoozeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
