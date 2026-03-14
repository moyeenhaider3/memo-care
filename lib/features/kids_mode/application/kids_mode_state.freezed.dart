// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kids_mode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KidsModeState {

 bool get isActive; List<Quest> get dailyQuests; KidsPoints get points; String get childName; int get starRating; bool get allQuestsComplete;
/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KidsModeStateCopyWith<KidsModeState> get copyWith => _$KidsModeStateCopyWithImpl<KidsModeState>(this as KidsModeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KidsModeState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.dailyQuests, dailyQuests)&&(identical(other.points, points) || other.points == points)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.starRating, starRating) || other.starRating == starRating)&&(identical(other.allQuestsComplete, allQuestsComplete) || other.allQuestsComplete == allQuestsComplete));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,const DeepCollectionEquality().hash(dailyQuests),points,childName,starRating,allQuestsComplete);

@override
String toString() {
  return 'KidsModeState(isActive: $isActive, dailyQuests: $dailyQuests, points: $points, childName: $childName, starRating: $starRating, allQuestsComplete: $allQuestsComplete)';
}


}

/// @nodoc
abstract mixin class $KidsModeStateCopyWith<$Res>  {
  factory $KidsModeStateCopyWith(KidsModeState value, $Res Function(KidsModeState) _then) = _$KidsModeStateCopyWithImpl;
@useResult
$Res call({
 bool isActive, List<Quest> dailyQuests, KidsPoints points, String childName, int starRating, bool allQuestsComplete
});


$KidsPointsCopyWith<$Res> get points;

}
/// @nodoc
class _$KidsModeStateCopyWithImpl<$Res>
    implements $KidsModeStateCopyWith<$Res> {
  _$KidsModeStateCopyWithImpl(this._self, this._then);

  final KidsModeState _self;
  final $Res Function(KidsModeState) _then;

/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,Object? dailyQuests = null,Object? points = null,Object? childName = null,Object? starRating = null,Object? allQuestsComplete = null,}) {
  return _then(_self.copyWith(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,dailyQuests: null == dailyQuests ? _self.dailyQuests : dailyQuests // ignore: cast_nullable_to_non_nullable
as List<Quest>,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as KidsPoints,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,starRating: null == starRating ? _self.starRating : starRating // ignore: cast_nullable_to_non_nullable
as int,allQuestsComplete: null == allQuestsComplete ? _self.allQuestsComplete : allQuestsComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KidsPointsCopyWith<$Res> get points {
  
  return $KidsPointsCopyWith<$Res>(_self.points, (value) {
    return _then(_self.copyWith(points: value));
  });
}
}


/// Adds pattern-matching-related methods to [KidsModeState].
extension KidsModeStatePatterns on KidsModeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KidsModeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KidsModeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KidsModeState value)  $default,){
final _that = this;
switch (_that) {
case _KidsModeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KidsModeState value)?  $default,){
final _that = this;
switch (_that) {
case _KidsModeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isActive,  List<Quest> dailyQuests,  KidsPoints points,  String childName,  int starRating,  bool allQuestsComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KidsModeState() when $default != null:
return $default(_that.isActive,_that.dailyQuests,_that.points,_that.childName,_that.starRating,_that.allQuestsComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isActive,  List<Quest> dailyQuests,  KidsPoints points,  String childName,  int starRating,  bool allQuestsComplete)  $default,) {final _that = this;
switch (_that) {
case _KidsModeState():
return $default(_that.isActive,_that.dailyQuests,_that.points,_that.childName,_that.starRating,_that.allQuestsComplete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isActive,  List<Quest> dailyQuests,  KidsPoints points,  String childName,  int starRating,  bool allQuestsComplete)?  $default,) {final _that = this;
switch (_that) {
case _KidsModeState() when $default != null:
return $default(_that.isActive,_that.dailyQuests,_that.points,_that.childName,_that.starRating,_that.allQuestsComplete);case _:
  return null;

}
}

}

/// @nodoc


class _KidsModeState implements KidsModeState {
  const _KidsModeState({this.isActive = false, final  List<Quest> dailyQuests = const [], this.points = const KidsPoints(), this.childName = '', this.starRating = 0, this.allQuestsComplete = false}): _dailyQuests = dailyQuests;
  

@override@JsonKey() final  bool isActive;
 final  List<Quest> _dailyQuests;
@override@JsonKey() List<Quest> get dailyQuests {
  if (_dailyQuests is EqualUnmodifiableListView) return _dailyQuests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyQuests);
}

@override@JsonKey() final  KidsPoints points;
@override@JsonKey() final  String childName;
@override@JsonKey() final  int starRating;
@override@JsonKey() final  bool allQuestsComplete;

/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KidsModeStateCopyWith<_KidsModeState> get copyWith => __$KidsModeStateCopyWithImpl<_KidsModeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KidsModeState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._dailyQuests, _dailyQuests)&&(identical(other.points, points) || other.points == points)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.starRating, starRating) || other.starRating == starRating)&&(identical(other.allQuestsComplete, allQuestsComplete) || other.allQuestsComplete == allQuestsComplete));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,const DeepCollectionEquality().hash(_dailyQuests),points,childName,starRating,allQuestsComplete);

@override
String toString() {
  return 'KidsModeState(isActive: $isActive, dailyQuests: $dailyQuests, points: $points, childName: $childName, starRating: $starRating, allQuestsComplete: $allQuestsComplete)';
}


}

/// @nodoc
abstract mixin class _$KidsModeStateCopyWith<$Res> implements $KidsModeStateCopyWith<$Res> {
  factory _$KidsModeStateCopyWith(_KidsModeState value, $Res Function(_KidsModeState) _then) = __$KidsModeStateCopyWithImpl;
@override @useResult
$Res call({
 bool isActive, List<Quest> dailyQuests, KidsPoints points, String childName, int starRating, bool allQuestsComplete
});


@override $KidsPointsCopyWith<$Res> get points;

}
/// @nodoc
class __$KidsModeStateCopyWithImpl<$Res>
    implements _$KidsModeStateCopyWith<$Res> {
  __$KidsModeStateCopyWithImpl(this._self, this._then);

  final _KidsModeState _self;
  final $Res Function(_KidsModeState) _then;

/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? dailyQuests = null,Object? points = null,Object? childName = null,Object? starRating = null,Object? allQuestsComplete = null,}) {
  return _then(_KidsModeState(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,dailyQuests: null == dailyQuests ? _self._dailyQuests : dailyQuests // ignore: cast_nullable_to_non_nullable
as List<Quest>,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as KidsPoints,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,starRating: null == starRating ? _self.starRating : starRating // ignore: cast_nullable_to_non_nullable
as int,allQuestsComplete: null == allQuestsComplete ? _self.allQuestsComplete : allQuestsComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of KidsModeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KidsPointsCopyWith<$Res> get points {
  
  return $KidsPointsCopyWith<$Res>(_self.points, (value) {
    return _then(_self.copyWith(points: value));
  });
}
}

// dart format on
