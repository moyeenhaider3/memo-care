// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryEntry {

 int get reminderId; String get medicineName; String? get dosage; DateTime get scheduledAt; ConfirmationState? get status; DateTime? get confirmedAt;
/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryEntryCopyWith<HistoryEntry> get copyWith => _$HistoryEntryCopyWithImpl<HistoryEntry>(this as HistoryEntry, _$identity);

  /// Serializes this HistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryEntry&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reminderId,medicineName,dosage,scheduledAt,status,confirmedAt);

@override
String toString() {
  return 'HistoryEntry(reminderId: $reminderId, medicineName: $medicineName, dosage: $dosage, scheduledAt: $scheduledAt, status: $status, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class $HistoryEntryCopyWith<$Res>  {
  factory $HistoryEntryCopyWith(HistoryEntry value, $Res Function(HistoryEntry) _then) = _$HistoryEntryCopyWithImpl;
@useResult
$Res call({
 int reminderId, String medicineName, String? dosage, DateTime scheduledAt, ConfirmationState? status, DateTime? confirmedAt
});




}
/// @nodoc
class _$HistoryEntryCopyWithImpl<$Res>
    implements $HistoryEntryCopyWith<$Res> {
  _$HistoryEntryCopyWithImpl(this._self, this._then);

  final HistoryEntry _self;
  final $Res Function(HistoryEntry) _then;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reminderId = null,Object? medicineName = null,Object? dosage = freezed,Object? scheduledAt = null,Object? status = freezed,Object? confirmedAt = freezed,}) {
  return _then(_self.copyWith(
reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int,medicineName: null == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfirmationState?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryEntry].
extension HistoryEntryPatterns on HistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _HistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reminderId,  String medicineName,  String? dosage,  DateTime scheduledAt,  ConfirmationState? status,  DateTime? confirmedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
return $default(_that.reminderId,_that.medicineName,_that.dosage,_that.scheduledAt,_that.status,_that.confirmedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reminderId,  String medicineName,  String? dosage,  DateTime scheduledAt,  ConfirmationState? status,  DateTime? confirmedAt)  $default,) {final _that = this;
switch (_that) {
case _HistoryEntry():
return $default(_that.reminderId,_that.medicineName,_that.dosage,_that.scheduledAt,_that.status,_that.confirmedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reminderId,  String medicineName,  String? dosage,  DateTime scheduledAt,  ConfirmationState? status,  DateTime? confirmedAt)?  $default,) {final _that = this;
switch (_that) {
case _HistoryEntry() when $default != null:
return $default(_that.reminderId,_that.medicineName,_that.dosage,_that.scheduledAt,_that.status,_that.confirmedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryEntry extends HistoryEntry {
  const _HistoryEntry({required this.reminderId, required this.medicineName, this.dosage, required this.scheduledAt, this.status, this.confirmedAt}): super._();
  factory _HistoryEntry.fromJson(Map<String, dynamic> json) => _$HistoryEntryFromJson(json);

@override final  int reminderId;
@override final  String medicineName;
@override final  String? dosage;
@override final  DateTime scheduledAt;
@override final  ConfirmationState? status;
@override final  DateTime? confirmedAt;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryEntryCopyWith<_HistoryEntry> get copyWith => __$HistoryEntryCopyWithImpl<_HistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryEntry&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reminderId,medicineName,dosage,scheduledAt,status,confirmedAt);

@override
String toString() {
  return 'HistoryEntry(reminderId: $reminderId, medicineName: $medicineName, dosage: $dosage, scheduledAt: $scheduledAt, status: $status, confirmedAt: $confirmedAt)';
}


}

/// @nodoc
abstract mixin class _$HistoryEntryCopyWith<$Res> implements $HistoryEntryCopyWith<$Res> {
  factory _$HistoryEntryCopyWith(_HistoryEntry value, $Res Function(_HistoryEntry) _then) = __$HistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 int reminderId, String medicineName, String? dosage, DateTime scheduledAt, ConfirmationState? status, DateTime? confirmedAt
});




}
/// @nodoc
class __$HistoryEntryCopyWithImpl<$Res>
    implements _$HistoryEntryCopyWith<$Res> {
  __$HistoryEntryCopyWithImpl(this._self, this._then);

  final _HistoryEntry _self;
  final $Res Function(_HistoryEntry) _then;

/// Create a copy of HistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reminderId = null,Object? medicineName = null,Object? dosage = freezed,Object? scheduledAt = null,Object? status = freezed,Object? confirmedAt = freezed,}) {
  return _then(_HistoryEntry(
reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int,medicineName: null == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConfirmationState?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
