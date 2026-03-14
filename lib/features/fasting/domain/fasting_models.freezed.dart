// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fasting_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FastingDay {

 int get dayNumber; DateTime get sehriTime; DateTime get iftarTime; bool get isFasting;
/// Create a copy of FastingDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FastingDayCopyWith<FastingDay> get copyWith => _$FastingDayCopyWithImpl<FastingDay>(this as FastingDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FastingDay&&(identical(other.dayNumber, dayNumber) || other.dayNumber == dayNumber)&&(identical(other.sehriTime, sehriTime) || other.sehriTime == sehriTime)&&(identical(other.iftarTime, iftarTime) || other.iftarTime == iftarTime)&&(identical(other.isFasting, isFasting) || other.isFasting == isFasting));
}


@override
int get hashCode => Object.hash(runtimeType,dayNumber,sehriTime,iftarTime,isFasting);

@override
String toString() {
  return 'FastingDay(dayNumber: $dayNumber, sehriTime: $sehriTime, iftarTime: $iftarTime, isFasting: $isFasting)';
}


}

/// @nodoc
abstract mixin class $FastingDayCopyWith<$Res>  {
  factory $FastingDayCopyWith(FastingDay value, $Res Function(FastingDay) _then) = _$FastingDayCopyWithImpl;
@useResult
$Res call({
 int dayNumber, DateTime sehriTime, DateTime iftarTime, bool isFasting
});




}
/// @nodoc
class _$FastingDayCopyWithImpl<$Res>
    implements $FastingDayCopyWith<$Res> {
  _$FastingDayCopyWithImpl(this._self, this._then);

  final FastingDay _self;
  final $Res Function(FastingDay) _then;

/// Create a copy of FastingDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayNumber = null,Object? sehriTime = null,Object? iftarTime = null,Object? isFasting = null,}) {
  return _then(_self.copyWith(
dayNumber: null == dayNumber ? _self.dayNumber : dayNumber // ignore: cast_nullable_to_non_nullable
as int,sehriTime: null == sehriTime ? _self.sehriTime : sehriTime // ignore: cast_nullable_to_non_nullable
as DateTime,iftarTime: null == iftarTime ? _self.iftarTime : iftarTime // ignore: cast_nullable_to_non_nullable
as DateTime,isFasting: null == isFasting ? _self.isFasting : isFasting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FastingDay].
extension FastingDayPatterns on FastingDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FastingDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FastingDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FastingDay value)  $default,){
final _that = this;
switch (_that) {
case _FastingDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FastingDay value)?  $default,){
final _that = this;
switch (_that) {
case _FastingDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayNumber,  DateTime sehriTime,  DateTime iftarTime,  bool isFasting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FastingDay() when $default != null:
return $default(_that.dayNumber,_that.sehriTime,_that.iftarTime,_that.isFasting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayNumber,  DateTime sehriTime,  DateTime iftarTime,  bool isFasting)  $default,) {final _that = this;
switch (_that) {
case _FastingDay():
return $default(_that.dayNumber,_that.sehriTime,_that.iftarTime,_that.isFasting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayNumber,  DateTime sehriTime,  DateTime iftarTime,  bool isFasting)?  $default,) {final _that = this;
switch (_that) {
case _FastingDay() when $default != null:
return $default(_that.dayNumber,_that.sehriTime,_that.iftarTime,_that.isFasting);case _:
  return null;

}
}

}

/// @nodoc


class _FastingDay implements FastingDay {
  const _FastingDay({required this.dayNumber, required this.sehriTime, required this.iftarTime, this.isFasting = true});
  

@override final  int dayNumber;
@override final  DateTime sehriTime;
@override final  DateTime iftarTime;
@override@JsonKey() final  bool isFasting;

/// Create a copy of FastingDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FastingDayCopyWith<_FastingDay> get copyWith => __$FastingDayCopyWithImpl<_FastingDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FastingDay&&(identical(other.dayNumber, dayNumber) || other.dayNumber == dayNumber)&&(identical(other.sehriTime, sehriTime) || other.sehriTime == sehriTime)&&(identical(other.iftarTime, iftarTime) || other.iftarTime == iftarTime)&&(identical(other.isFasting, isFasting) || other.isFasting == isFasting));
}


@override
int get hashCode => Object.hash(runtimeType,dayNumber,sehriTime,iftarTime,isFasting);

@override
String toString() {
  return 'FastingDay(dayNumber: $dayNumber, sehriTime: $sehriTime, iftarTime: $iftarTime, isFasting: $isFasting)';
}


}

/// @nodoc
abstract mixin class _$FastingDayCopyWith<$Res> implements $FastingDayCopyWith<$Res> {
  factory _$FastingDayCopyWith(_FastingDay value, $Res Function(_FastingDay) _then) = __$FastingDayCopyWithImpl;
@override @useResult
$Res call({
 int dayNumber, DateTime sehriTime, DateTime iftarTime, bool isFasting
});




}
/// @nodoc
class __$FastingDayCopyWithImpl<$Res>
    implements _$FastingDayCopyWith<$Res> {
  __$FastingDayCopyWithImpl(this._self, this._then);

  final _FastingDay _self;
  final $Res Function(_FastingDay) _then;

/// Create a copy of FastingDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayNumber = null,Object? sehriTime = null,Object? iftarTime = null,Object? isFasting = null,}) {
  return _then(_FastingDay(
dayNumber: null == dayNumber ? _self.dayNumber : dayNumber // ignore: cast_nullable_to_non_nullable
as int,sehriTime: null == sehriTime ? _self.sehriTime : sehriTime // ignore: cast_nullable_to_non_nullable
as DateTime,iftarTime: null == iftarTime ? _self.iftarTime : iftarTime // ignore: cast_nullable_to_non_nullable
as DateTime,isFasting: null == isFasting ? _self.isFasting : isFasting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$FastingMedicine {

 String get id; String get name; String get dosage; String get notes; FastingSection get section; bool get isTaken; String? get scheduledTime;
/// Create a copy of FastingMedicine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FastingMedicineCopyWith<FastingMedicine> get copyWith => _$FastingMedicineCopyWithImpl<FastingMedicine>(this as FastingMedicine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FastingMedicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.section, section) || other.section == section)&&(identical(other.isTaken, isTaken) || other.isTaken == isTaken)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,dosage,notes,section,isTaken,scheduledTime);

@override
String toString() {
  return 'FastingMedicine(id: $id, name: $name, dosage: $dosage, notes: $notes, section: $section, isTaken: $isTaken, scheduledTime: $scheduledTime)';
}


}

/// @nodoc
abstract mixin class $FastingMedicineCopyWith<$Res>  {
  factory $FastingMedicineCopyWith(FastingMedicine value, $Res Function(FastingMedicine) _then) = _$FastingMedicineCopyWithImpl;
@useResult
$Res call({
 String id, String name, String dosage, String notes, FastingSection section, bool isTaken, String? scheduledTime
});




}
/// @nodoc
class _$FastingMedicineCopyWithImpl<$Res>
    implements $FastingMedicineCopyWith<$Res> {
  _$FastingMedicineCopyWithImpl(this._self, this._then);

  final FastingMedicine _self;
  final $Res Function(FastingMedicine) _then;

/// Create a copy of FastingMedicine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? dosage = null,Object? notes = null,Object? section = null,Object? isTaken = null,Object? scheduledTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as FastingSection,isTaken: null == isTaken ? _self.isTaken : isTaken // ignore: cast_nullable_to_non_nullable
as bool,scheduledTime: freezed == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FastingMedicine].
extension FastingMedicinePatterns on FastingMedicine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FastingMedicine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FastingMedicine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FastingMedicine value)  $default,){
final _that = this;
switch (_that) {
case _FastingMedicine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FastingMedicine value)?  $default,){
final _that = this;
switch (_that) {
case _FastingMedicine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String dosage,  String notes,  FastingSection section,  bool isTaken,  String? scheduledTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FastingMedicine() when $default != null:
return $default(_that.id,_that.name,_that.dosage,_that.notes,_that.section,_that.isTaken,_that.scheduledTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String dosage,  String notes,  FastingSection section,  bool isTaken,  String? scheduledTime)  $default,) {final _that = this;
switch (_that) {
case _FastingMedicine():
return $default(_that.id,_that.name,_that.dosage,_that.notes,_that.section,_that.isTaken,_that.scheduledTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String dosage,  String notes,  FastingSection section,  bool isTaken,  String? scheduledTime)?  $default,) {final _that = this;
switch (_that) {
case _FastingMedicine() when $default != null:
return $default(_that.id,_that.name,_that.dosage,_that.notes,_that.section,_that.isTaken,_that.scheduledTime);case _:
  return null;

}
}

}

/// @nodoc


class _FastingMedicine implements FastingMedicine {
  const _FastingMedicine({required this.id, required this.name, required this.dosage, required this.notes, required this.section, this.isTaken = false, this.scheduledTime});
  

@override final  String id;
@override final  String name;
@override final  String dosage;
@override final  String notes;
@override final  FastingSection section;
@override@JsonKey() final  bool isTaken;
@override final  String? scheduledTime;

/// Create a copy of FastingMedicine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FastingMedicineCopyWith<_FastingMedicine> get copyWith => __$FastingMedicineCopyWithImpl<_FastingMedicine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FastingMedicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.section, section) || other.section == section)&&(identical(other.isTaken, isTaken) || other.isTaken == isTaken)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,dosage,notes,section,isTaken,scheduledTime);

@override
String toString() {
  return 'FastingMedicine(id: $id, name: $name, dosage: $dosage, notes: $notes, section: $section, isTaken: $isTaken, scheduledTime: $scheduledTime)';
}


}

/// @nodoc
abstract mixin class _$FastingMedicineCopyWith<$Res> implements $FastingMedicineCopyWith<$Res> {
  factory _$FastingMedicineCopyWith(_FastingMedicine value, $Res Function(_FastingMedicine) _then) = __$FastingMedicineCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String dosage, String notes, FastingSection section, bool isTaken, String? scheduledTime
});




}
/// @nodoc
class __$FastingMedicineCopyWithImpl<$Res>
    implements _$FastingMedicineCopyWith<$Res> {
  __$FastingMedicineCopyWithImpl(this._self, this._then);

  final _FastingMedicine _self;
  final $Res Function(_FastingMedicine) _then;

/// Create a copy of FastingMedicine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? dosage = null,Object? notes = null,Object? section = null,Object? isTaken = null,Object? scheduledTime = freezed,}) {
  return _then(_FastingMedicine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as FastingSection,isTaken: null == isTaken ? _self.isTaken : isTaken // ignore: cast_nullable_to_non_nullable
as bool,scheduledTime: freezed == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
