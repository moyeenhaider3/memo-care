// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fasting_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FastingState {

 bool get isActive; int get fastingDay; int get totalDays; DateTime? get sehriTime; DateTime? get iftarTime; bool get isFasting; List<FastingMedicine> get sehriMedicines; List<FastingMedicine> get iftarMedicines; double get progressPercent; String get locationName;
/// Create a copy of FastingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FastingStateCopyWith<FastingState> get copyWith => _$FastingStateCopyWithImpl<FastingState>(this as FastingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FastingState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.fastingDay, fastingDay) || other.fastingDay == fastingDay)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.sehriTime, sehriTime) || other.sehriTime == sehriTime)&&(identical(other.iftarTime, iftarTime) || other.iftarTime == iftarTime)&&(identical(other.isFasting, isFasting) || other.isFasting == isFasting)&&const DeepCollectionEquality().equals(other.sehriMedicines, sehriMedicines)&&const DeepCollectionEquality().equals(other.iftarMedicines, iftarMedicines)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.locationName, locationName) || other.locationName == locationName));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,fastingDay,totalDays,sehriTime,iftarTime,isFasting,const DeepCollectionEquality().hash(sehriMedicines),const DeepCollectionEquality().hash(iftarMedicines),progressPercent,locationName);

@override
String toString() {
  return 'FastingState(isActive: $isActive, fastingDay: $fastingDay, totalDays: $totalDays, sehriTime: $sehriTime, iftarTime: $iftarTime, isFasting: $isFasting, sehriMedicines: $sehriMedicines, iftarMedicines: $iftarMedicines, progressPercent: $progressPercent, locationName: $locationName)';
}


}

/// @nodoc
abstract mixin class $FastingStateCopyWith<$Res>  {
  factory $FastingStateCopyWith(FastingState value, $Res Function(FastingState) _then) = _$FastingStateCopyWithImpl;
@useResult
$Res call({
 bool isActive, int fastingDay, int totalDays, DateTime? sehriTime, DateTime? iftarTime, bool isFasting, List<FastingMedicine> sehriMedicines, List<FastingMedicine> iftarMedicines, double progressPercent, String locationName
});




}
/// @nodoc
class _$FastingStateCopyWithImpl<$Res>
    implements $FastingStateCopyWith<$Res> {
  _$FastingStateCopyWithImpl(this._self, this._then);

  final FastingState _self;
  final $Res Function(FastingState) _then;

/// Create a copy of FastingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,Object? fastingDay = null,Object? totalDays = null,Object? sehriTime = freezed,Object? iftarTime = freezed,Object? isFasting = null,Object? sehriMedicines = null,Object? iftarMedicines = null,Object? progressPercent = null,Object? locationName = null,}) {
  return _then(_self.copyWith(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fastingDay: null == fastingDay ? _self.fastingDay : fastingDay // ignore: cast_nullable_to_non_nullable
as int,totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,sehriTime: freezed == sehriTime ? _self.sehriTime : sehriTime // ignore: cast_nullable_to_non_nullable
as DateTime?,iftarTime: freezed == iftarTime ? _self.iftarTime : iftarTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isFasting: null == isFasting ? _self.isFasting : isFasting // ignore: cast_nullable_to_non_nullable
as bool,sehriMedicines: null == sehriMedicines ? _self.sehriMedicines : sehriMedicines // ignore: cast_nullable_to_non_nullable
as List<FastingMedicine>,iftarMedicines: null == iftarMedicines ? _self.iftarMedicines : iftarMedicines // ignore: cast_nullable_to_non_nullable
as List<FastingMedicine>,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,locationName: null == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FastingState].
extension FastingStatePatterns on FastingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FastingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FastingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FastingState value)  $default,){
final _that = this;
switch (_that) {
case _FastingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FastingState value)?  $default,){
final _that = this;
switch (_that) {
case _FastingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isActive,  int fastingDay,  int totalDays,  DateTime? sehriTime,  DateTime? iftarTime,  bool isFasting,  List<FastingMedicine> sehriMedicines,  List<FastingMedicine> iftarMedicines,  double progressPercent,  String locationName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FastingState() when $default != null:
return $default(_that.isActive,_that.fastingDay,_that.totalDays,_that.sehriTime,_that.iftarTime,_that.isFasting,_that.sehriMedicines,_that.iftarMedicines,_that.progressPercent,_that.locationName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isActive,  int fastingDay,  int totalDays,  DateTime? sehriTime,  DateTime? iftarTime,  bool isFasting,  List<FastingMedicine> sehriMedicines,  List<FastingMedicine> iftarMedicines,  double progressPercent,  String locationName)  $default,) {final _that = this;
switch (_that) {
case _FastingState():
return $default(_that.isActive,_that.fastingDay,_that.totalDays,_that.sehriTime,_that.iftarTime,_that.isFasting,_that.sehriMedicines,_that.iftarMedicines,_that.progressPercent,_that.locationName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isActive,  int fastingDay,  int totalDays,  DateTime? sehriTime,  DateTime? iftarTime,  bool isFasting,  List<FastingMedicine> sehriMedicines,  List<FastingMedicine> iftarMedicines,  double progressPercent,  String locationName)?  $default,) {final _that = this;
switch (_that) {
case _FastingState() when $default != null:
return $default(_that.isActive,_that.fastingDay,_that.totalDays,_that.sehriTime,_that.iftarTime,_that.isFasting,_that.sehriMedicines,_that.iftarMedicines,_that.progressPercent,_that.locationName);case _:
  return null;

}
}

}

/// @nodoc


class _FastingState implements FastingState {
  const _FastingState({this.isActive = false, this.fastingDay = 1, this.totalDays = 30, this.sehriTime, this.iftarTime, this.isFasting = false, final  List<FastingMedicine> sehriMedicines = const [], final  List<FastingMedicine> iftarMedicines = const [], this.progressPercent = 0.0, this.locationName = ''}): _sehriMedicines = sehriMedicines,_iftarMedicines = iftarMedicines;
  

@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int fastingDay;
@override@JsonKey() final  int totalDays;
@override final  DateTime? sehriTime;
@override final  DateTime? iftarTime;
@override@JsonKey() final  bool isFasting;
 final  List<FastingMedicine> _sehriMedicines;
@override@JsonKey() List<FastingMedicine> get sehriMedicines {
  if (_sehriMedicines is EqualUnmodifiableListView) return _sehriMedicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sehriMedicines);
}

 final  List<FastingMedicine> _iftarMedicines;
@override@JsonKey() List<FastingMedicine> get iftarMedicines {
  if (_iftarMedicines is EqualUnmodifiableListView) return _iftarMedicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_iftarMedicines);
}

@override@JsonKey() final  double progressPercent;
@override@JsonKey() final  String locationName;

/// Create a copy of FastingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FastingStateCopyWith<_FastingState> get copyWith => __$FastingStateCopyWithImpl<_FastingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FastingState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.fastingDay, fastingDay) || other.fastingDay == fastingDay)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.sehriTime, sehriTime) || other.sehriTime == sehriTime)&&(identical(other.iftarTime, iftarTime) || other.iftarTime == iftarTime)&&(identical(other.isFasting, isFasting) || other.isFasting == isFasting)&&const DeepCollectionEquality().equals(other._sehriMedicines, _sehriMedicines)&&const DeepCollectionEquality().equals(other._iftarMedicines, _iftarMedicines)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.locationName, locationName) || other.locationName == locationName));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,fastingDay,totalDays,sehriTime,iftarTime,isFasting,const DeepCollectionEquality().hash(_sehriMedicines),const DeepCollectionEquality().hash(_iftarMedicines),progressPercent,locationName);

@override
String toString() {
  return 'FastingState(isActive: $isActive, fastingDay: $fastingDay, totalDays: $totalDays, sehriTime: $sehriTime, iftarTime: $iftarTime, isFasting: $isFasting, sehriMedicines: $sehriMedicines, iftarMedicines: $iftarMedicines, progressPercent: $progressPercent, locationName: $locationName)';
}


}

/// @nodoc
abstract mixin class _$FastingStateCopyWith<$Res> implements $FastingStateCopyWith<$Res> {
  factory _$FastingStateCopyWith(_FastingState value, $Res Function(_FastingState) _then) = __$FastingStateCopyWithImpl;
@override @useResult
$Res call({
 bool isActive, int fastingDay, int totalDays, DateTime? sehriTime, DateTime? iftarTime, bool isFasting, List<FastingMedicine> sehriMedicines, List<FastingMedicine> iftarMedicines, double progressPercent, String locationName
});




}
/// @nodoc
class __$FastingStateCopyWithImpl<$Res>
    implements _$FastingStateCopyWith<$Res> {
  __$FastingStateCopyWithImpl(this._self, this._then);

  final _FastingState _self;
  final $Res Function(_FastingState) _then;

/// Create a copy of FastingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? fastingDay = null,Object? totalDays = null,Object? sehriTime = freezed,Object? iftarTime = freezed,Object? isFasting = null,Object? sehriMedicines = null,Object? iftarMedicines = null,Object? progressPercent = null,Object? locationName = null,}) {
  return _then(_FastingState(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fastingDay: null == fastingDay ? _self.fastingDay : fastingDay // ignore: cast_nullable_to_non_nullable
as int,totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,sehriTime: freezed == sehriTime ? _self.sehriTime : sehriTime // ignore: cast_nullable_to_non_nullable
as DateTime?,iftarTime: freezed == iftarTime ? _self.iftarTime : iftarTime // ignore: cast_nullable_to_non_nullable
as DateTime?,isFasting: null == isFasting ? _self.isFasting : isFasting // ignore: cast_nullable_to_non_nullable
as bool,sehriMedicines: null == sehriMedicines ? _self._sehriMedicines : sehriMedicines // ignore: cast_nullable_to_non_nullable
as List<FastingMedicine>,iftarMedicines: null == iftarMedicines ? _self._iftarMedicines : iftarMedicines // ignore: cast_nullable_to_non_nullable
as List<FastingMedicine>,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,locationName: null == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
