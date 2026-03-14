// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kids_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Quest {

 String get id; String get title; String get time; bool get isCompleted; String get category;
/// Create a copy of Quest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestCopyWith<Quest> get copyWith => _$QuestCopyWithImpl<Quest>(this as Quest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quest&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,time,isCompleted,category);

@override
String toString() {
  return 'Quest(id: $id, title: $title, time: $time, isCompleted: $isCompleted, category: $category)';
}


}

/// @nodoc
abstract mixin class $QuestCopyWith<$Res>  {
  factory $QuestCopyWith(Quest value, $Res Function(Quest) _then) = _$QuestCopyWithImpl;
@useResult
$Res call({
 String id, String title, String time, bool isCompleted, String category
});




}
/// @nodoc
class _$QuestCopyWithImpl<$Res>
    implements $QuestCopyWith<$Res> {
  _$QuestCopyWithImpl(this._self, this._then);

  final Quest _self;
  final $Res Function(Quest) _then;

/// Create a copy of Quest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? time = null,Object? isCompleted = null,Object? category = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Quest].
extension QuestPatterns on Quest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quest value)  $default,){
final _that = this;
switch (_that) {
case _Quest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quest value)?  $default,){
final _that = this;
switch (_that) {
case _Quest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String time,  bool isCompleted,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quest() when $default != null:
return $default(_that.id,_that.title,_that.time,_that.isCompleted,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String time,  bool isCompleted,  String category)  $default,) {final _that = this;
switch (_that) {
case _Quest():
return $default(_that.id,_that.title,_that.time,_that.isCompleted,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String time,  bool isCompleted,  String category)?  $default,) {final _that = this;
switch (_that) {
case _Quest() when $default != null:
return $default(_that.id,_that.title,_that.time,_that.isCompleted,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _Quest implements Quest {
  const _Quest({required this.id, required this.title, required this.time, this.isCompleted = false, this.category = 'task'});
  

@override final  String id;
@override final  String title;
@override final  String time;
@override@JsonKey() final  bool isCompleted;
@override@JsonKey() final  String category;

/// Create a copy of Quest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestCopyWith<_Quest> get copyWith => __$QuestCopyWithImpl<_Quest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quest&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,time,isCompleted,category);

@override
String toString() {
  return 'Quest(id: $id, title: $title, time: $time, isCompleted: $isCompleted, category: $category)';
}


}

/// @nodoc
abstract mixin class _$QuestCopyWith<$Res> implements $QuestCopyWith<$Res> {
  factory _$QuestCopyWith(_Quest value, $Res Function(_Quest) _then) = __$QuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String time, bool isCompleted, String category
});




}
/// @nodoc
class __$QuestCopyWithImpl<$Res>
    implements _$QuestCopyWith<$Res> {
  __$QuestCopyWithImpl(this._self, this._then);

  final _Quest _self;
  final $Res Function(_Quest) _then;

/// Create a copy of Quest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? time = null,Object? isCompleted = null,Object? category = null,}) {
  return _then(_Quest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$KidsPoints {

 int get totalPoints; int get dailyPoints; int get dailyStreak;
/// Create a copy of KidsPoints
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KidsPointsCopyWith<KidsPoints> get copyWith => _$KidsPointsCopyWithImpl<KidsPoints>(this as KidsPoints, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KidsPoints&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.dailyPoints, dailyPoints) || other.dailyPoints == dailyPoints)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak));
}


@override
int get hashCode => Object.hash(runtimeType,totalPoints,dailyPoints,dailyStreak);

@override
String toString() {
  return 'KidsPoints(totalPoints: $totalPoints, dailyPoints: $dailyPoints, dailyStreak: $dailyStreak)';
}


}

/// @nodoc
abstract mixin class $KidsPointsCopyWith<$Res>  {
  factory $KidsPointsCopyWith(KidsPoints value, $Res Function(KidsPoints) _then) = _$KidsPointsCopyWithImpl;
@useResult
$Res call({
 int totalPoints, int dailyPoints, int dailyStreak
});




}
/// @nodoc
class _$KidsPointsCopyWithImpl<$Res>
    implements $KidsPointsCopyWith<$Res> {
  _$KidsPointsCopyWithImpl(this._self, this._then);

  final KidsPoints _self;
  final $Res Function(KidsPoints) _then;

/// Create a copy of KidsPoints
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPoints = null,Object? dailyPoints = null,Object? dailyStreak = null,}) {
  return _then(_self.copyWith(
totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,dailyPoints: null == dailyPoints ? _self.dailyPoints : dailyPoints // ignore: cast_nullable_to_non_nullable
as int,dailyStreak: null == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KidsPoints].
extension KidsPointsPatterns on KidsPoints {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KidsPoints value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KidsPoints() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KidsPoints value)  $default,){
final _that = this;
switch (_that) {
case _KidsPoints():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KidsPoints value)?  $default,){
final _that = this;
switch (_that) {
case _KidsPoints() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalPoints,  int dailyPoints,  int dailyStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KidsPoints() when $default != null:
return $default(_that.totalPoints,_that.dailyPoints,_that.dailyStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalPoints,  int dailyPoints,  int dailyStreak)  $default,) {final _that = this;
switch (_that) {
case _KidsPoints():
return $default(_that.totalPoints,_that.dailyPoints,_that.dailyStreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalPoints,  int dailyPoints,  int dailyStreak)?  $default,) {final _that = this;
switch (_that) {
case _KidsPoints() when $default != null:
return $default(_that.totalPoints,_that.dailyPoints,_that.dailyStreak);case _:
  return null;

}
}

}

/// @nodoc


class _KidsPoints implements KidsPoints {
  const _KidsPoints({this.totalPoints = 0, this.dailyPoints = 0, this.dailyStreak = 0});
  

@override@JsonKey() final  int totalPoints;
@override@JsonKey() final  int dailyPoints;
@override@JsonKey() final  int dailyStreak;

/// Create a copy of KidsPoints
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KidsPointsCopyWith<_KidsPoints> get copyWith => __$KidsPointsCopyWithImpl<_KidsPoints>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KidsPoints&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.dailyPoints, dailyPoints) || other.dailyPoints == dailyPoints)&&(identical(other.dailyStreak, dailyStreak) || other.dailyStreak == dailyStreak));
}


@override
int get hashCode => Object.hash(runtimeType,totalPoints,dailyPoints,dailyStreak);

@override
String toString() {
  return 'KidsPoints(totalPoints: $totalPoints, dailyPoints: $dailyPoints, dailyStreak: $dailyStreak)';
}


}

/// @nodoc
abstract mixin class _$KidsPointsCopyWith<$Res> implements $KidsPointsCopyWith<$Res> {
  factory _$KidsPointsCopyWith(_KidsPoints value, $Res Function(_KidsPoints) _then) = __$KidsPointsCopyWithImpl;
@override @useResult
$Res call({
 int totalPoints, int dailyPoints, int dailyStreak
});




}
/// @nodoc
class __$KidsPointsCopyWithImpl<$Res>
    implements _$KidsPointsCopyWith<$Res> {
  __$KidsPointsCopyWithImpl(this._self, this._then);

  final _KidsPoints _self;
  final $Res Function(_KidsPoints) _then;

/// Create a copy of KidsPoints
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPoints = null,Object? dailyPoints = null,Object? dailyStreak = null,}) {
  return _then(_KidsPoints(
totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,dailyPoints: null == dailyPoints ? _self.dailyPoints : dailyPoints // ignore: cast_nullable_to_non_nullable
as int,dailyStreak: null == dailyStreak ? _self.dailyStreak : dailyStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
