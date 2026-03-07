// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_anchor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealAnchor {

 int get id; String get mealType; int get defaultTimeMinutes; DateTime? get confirmedAt;
/// Create a copy of MealAnchor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealAnchorCopyWith<MealAnchor> get copyWith => _$MealAnchorCopyWithImpl<MealAnchor>(this as MealAnchor, _$identity);

  /// Serializes this MealAnchor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealAnchor&&(identical(other.id, id) || other.id == id)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.defaultTimeMinutes, defaultTimeMinutes) || other.defaultTimeMinutes == defaultTimeMinutes)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mealType,defaultTimeMinutes,confirmedAt);

@override
String toString() {
  return 'MealAnchor(id: $id, mealType: $mealType, defaultTimeMinutes: $defaultTimeMinutes, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class $MealAnchorCopyWith<$Res>  {
  factory $MealAnchorCopyWith(MealAnchor value, $Res Function(MealAnchor) _then) = _$MealAnchorCopyWithImpl;
@useResult
$Res call({
 int id, String mealType, int defaultTimeMinutes, DateTime? confirmedAt
});




}
/// @nodoc
class _$MealAnchorCopyWithImpl<$Res>
    implements $MealAnchorCopyWith<$Res> {
  _$MealAnchorCopyWithImpl(this._self, this._then);

  final MealAnchor _self;
  final $Res Function(MealAnchor) _then;

/// Create a copy of MealAnchor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mealType = null,Object? defaultTimeMinutes = null,Object? confirmedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,defaultTimeMinutes: null == defaultTimeMinutes ? _self.defaultTimeMinutes : defaultTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealAnchor].
extension MealAnchorPatterns on MealAnchor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealAnchor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealAnchor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealAnchor value)  $default,){
final _that = this;
switch (_that) {
case _MealAnchor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealAnchor value)?  $default,){
final _that = this;
switch (_that) {
case _MealAnchor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String mealType,  int defaultTimeMinutes,  DateTime? confirmedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealAnchor() when $default != null:
return $default(_that.id,_that.mealType,_that.defaultTimeMinutes,_that.confirmedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String mealType,  int defaultTimeMinutes,  DateTime? confirmedAt)  $default,) {final _that = this;
switch (_that) {
case _MealAnchor():
return $default(_that.id,_that.mealType,_that.defaultTimeMinutes,_that.confirmedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String mealType,  int defaultTimeMinutes,  DateTime? confirmedAt)?  $default,) {final _that = this;
switch (_that) {
case _MealAnchor() when $default != null:
return $default(_that.id,_that.mealType,_that.defaultTimeMinutes,_that.confirmedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealAnchor implements MealAnchor {
  const _MealAnchor({required this.id, required this.mealType, required this.defaultTimeMinutes, this.confirmedAt});
  factory _MealAnchor.fromJson(Map<String, dynamic> json) => _$MealAnchorFromJson(json);

@override final  int id;
@override final  String mealType;
@override final  int defaultTimeMinutes;
@override final  DateTime? confirmedAt;

/// Create a copy of MealAnchor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealAnchorCopyWith<_MealAnchor> get copyWith => __$MealAnchorCopyWithImpl<_MealAnchor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealAnchorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealAnchor&&(identical(other.id, id) || other.id == id)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.defaultTimeMinutes, defaultTimeMinutes) || other.defaultTimeMinutes == defaultTimeMinutes)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mealType,defaultTimeMinutes,confirmedAt);

@override
String toString() {
  return 'MealAnchor(id: $id, mealType: $mealType, defaultTimeMinutes: $defaultTimeMinutes, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class _$MealAnchorCopyWith<$Res> implements $MealAnchorCopyWith<$Res> {
  factory _$MealAnchorCopyWith(_MealAnchor value, $Res Function(_MealAnchor) _then) = __$MealAnchorCopyWithImpl;
@override @useResult
$Res call({
 int id, String mealType, int defaultTimeMinutes, DateTime? confirmedAt
});




}
/// @nodoc
class __$MealAnchorCopyWithImpl<$Res>
    implements _$MealAnchorCopyWith<$Res> {
  __$MealAnchorCopyWithImpl(this._self, this._then);

  final _MealAnchor _self;
  final $Res Function(_MealAnchor) _then;

/// Create a copy of MealAnchor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mealType = null,Object? defaultTimeMinutes = null,Object? confirmedAt = freezed,}) {
  return _then(_MealAnchor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,defaultTimeMinutes: null == defaultTimeMinutes ? _self.defaultTimeMinutes : defaultTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
