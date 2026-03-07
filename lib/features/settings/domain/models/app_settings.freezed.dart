// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

/// Snooze duration in minutes (VIEW-05, ESCL-02).
 int get snoozeDurationMinutes;/// Silent tier timeout in minutes before escalating
/// to audible (ESCL-02).
 int get silentTimeoutMinutes;/// Audible tier timeout in minutes before escalating
/// to full-screen (ESCL-02).
 int get audibleTimeoutMinutes;/// Whether notifications are enabled globally.
 bool get notificationsEnabled;/// Whether alarm sound is enabled.
 bool get soundEnabled;/// Whether vibration is enabled.
 bool get vibrationEnabled;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.snoozeDurationMinutes, snoozeDurationMinutes) || other.snoozeDurationMinutes == snoozeDurationMinutes)&&(identical(other.silentTimeoutMinutes, silentTimeoutMinutes) || other.silentTimeoutMinutes == silentTimeoutMinutes)&&(identical(other.audibleTimeoutMinutes, audibleTimeoutMinutes) || other.audibleTimeoutMinutes == audibleTimeoutMinutes)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,snoozeDurationMinutes,silentTimeoutMinutes,audibleTimeoutMinutes,notificationsEnabled,soundEnabled,vibrationEnabled);

@override
String toString() {
  return 'AppSettings(snoozeDurationMinutes: $snoozeDurationMinutes, silentTimeoutMinutes: $silentTimeoutMinutes, audibleTimeoutMinutes: $audibleTimeoutMinutes, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 int snoozeDurationMinutes, int silentTimeoutMinutes, int audibleTimeoutMinutes, bool notificationsEnabled, bool soundEnabled, bool vibrationEnabled
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? snoozeDurationMinutes = null,Object? silentTimeoutMinutes = null,Object? audibleTimeoutMinutes = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? vibrationEnabled = null,}) {
  return _then(_self.copyWith(
snoozeDurationMinutes: null == snoozeDurationMinutes ? _self.snoozeDurationMinutes : snoozeDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,silentTimeoutMinutes: null == silentTimeoutMinutes ? _self.silentTimeoutMinutes : silentTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,audibleTimeoutMinutes: null == audibleTimeoutMinutes ? _self.audibleTimeoutMinutes : audibleTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int snoozeDurationMinutes,  int silentTimeoutMinutes,  int audibleTimeoutMinutes,  bool notificationsEnabled,  bool soundEnabled,  bool vibrationEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.snoozeDurationMinutes,_that.silentTimeoutMinutes,_that.audibleTimeoutMinutes,_that.notificationsEnabled,_that.soundEnabled,_that.vibrationEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int snoozeDurationMinutes,  int silentTimeoutMinutes,  int audibleTimeoutMinutes,  bool notificationsEnabled,  bool soundEnabled,  bool vibrationEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.snoozeDurationMinutes,_that.silentTimeoutMinutes,_that.audibleTimeoutMinutes,_that.notificationsEnabled,_that.soundEnabled,_that.vibrationEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int snoozeDurationMinutes,  int silentTimeoutMinutes,  int audibleTimeoutMinutes,  bool notificationsEnabled,  bool soundEnabled,  bool vibrationEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.snoozeDurationMinutes,_that.silentTimeoutMinutes,_that.audibleTimeoutMinutes,_that.notificationsEnabled,_that.soundEnabled,_that.vibrationEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.snoozeDurationMinutes = 5, this.silentTimeoutMinutes = 2, this.audibleTimeoutMinutes = 3, this.notificationsEnabled = true, this.soundEnabled = true, this.vibrationEnabled = true});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

/// Snooze duration in minutes (VIEW-05, ESCL-02).
@override@JsonKey() final  int snoozeDurationMinutes;
/// Silent tier timeout in minutes before escalating
/// to audible (ESCL-02).
@override@JsonKey() final  int silentTimeoutMinutes;
/// Audible tier timeout in minutes before escalating
/// to full-screen (ESCL-02).
@override@JsonKey() final  int audibleTimeoutMinutes;
/// Whether notifications are enabled globally.
@override@JsonKey() final  bool notificationsEnabled;
/// Whether alarm sound is enabled.
@override@JsonKey() final  bool soundEnabled;
/// Whether vibration is enabled.
@override@JsonKey() final  bool vibrationEnabled;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.snoozeDurationMinutes, snoozeDurationMinutes) || other.snoozeDurationMinutes == snoozeDurationMinutes)&&(identical(other.silentTimeoutMinutes, silentTimeoutMinutes) || other.silentTimeoutMinutes == silentTimeoutMinutes)&&(identical(other.audibleTimeoutMinutes, audibleTimeoutMinutes) || other.audibleTimeoutMinutes == audibleTimeoutMinutes)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,snoozeDurationMinutes,silentTimeoutMinutes,audibleTimeoutMinutes,notificationsEnabled,soundEnabled,vibrationEnabled);

@override
String toString() {
  return 'AppSettings(snoozeDurationMinutes: $snoozeDurationMinutes, silentTimeoutMinutes: $silentTimeoutMinutes, audibleTimeoutMinutes: $audibleTimeoutMinutes, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 int snoozeDurationMinutes, int silentTimeoutMinutes, int audibleTimeoutMinutes, bool notificationsEnabled, bool soundEnabled, bool vibrationEnabled
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? snoozeDurationMinutes = null,Object? silentTimeoutMinutes = null,Object? audibleTimeoutMinutes = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? vibrationEnabled = null,}) {
  return _then(_AppSettings(
snoozeDurationMinutes: null == snoozeDurationMinutes ? _self.snoozeDurationMinutes : snoozeDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,silentTimeoutMinutes: null == silentTimeoutMinutes ? _self.silentTimeoutMinutes : silentTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,audibleTimeoutMinutes: null == audibleTimeoutMinutes ? _self.audibleTimeoutMinutes : audibleTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
