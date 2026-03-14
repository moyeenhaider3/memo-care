// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

/// Current wizard step.
 OnboardingStep get currentStep;/// User-selected condition key (e.g., `'diabetes'`).
 String? get selectedCondition;/// ID of the selected template pack (null if manual path).
 String? get selectedTemplateId;/// Whether the user chose the template path (vs manual).
 bool get useTemplate;/// Meal anchor default times: mealType → minutes from
/// midnight. E.g., `{'breakfast': 480, 'lunch': 780}`.
 Map<String, int> get mealAnchorDefaults;/// Custom/edited medicine entries.
 List<CustomMedicineEntry> get customMedicines;/// Whether required permissions have been granted.
 bool get permissionsGranted;/// Whether onboarding is complete.
 bool get isComplete;/// User profile type: 'elderly', 'adult', or 'parent'.
 String? get profileType;/// Phone number for caregiver invitation (empty = skipped).
 String get caregiverPhone;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.selectedCondition, selectedCondition) || other.selectedCondition == selectedCondition)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.useTemplate, useTemplate) || other.useTemplate == useTemplate)&&const DeepCollectionEquality().equals(other.mealAnchorDefaults, mealAnchorDefaults)&&const DeepCollectionEquality().equals(other.customMedicines, customMedicines)&&(identical(other.permissionsGranted, permissionsGranted) || other.permissionsGranted == permissionsGranted)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.caregiverPhone, caregiverPhone) || other.caregiverPhone == caregiverPhone));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,selectedCondition,selectedTemplateId,useTemplate,const DeepCollectionEquality().hash(mealAnchorDefaults),const DeepCollectionEquality().hash(customMedicines),permissionsGranted,isComplete,profileType,caregiverPhone);

@override
String toString() {
  return 'OnboardingState(currentStep: $currentStep, selectedCondition: $selectedCondition, selectedTemplateId: $selectedTemplateId, useTemplate: $useTemplate, mealAnchorDefaults: $mealAnchorDefaults, customMedicines: $customMedicines, permissionsGranted: $permissionsGranted, isComplete: $isComplete, profileType: $profileType, caregiverPhone: $caregiverPhone)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 OnboardingStep currentStep, String? selectedCondition, String? selectedTemplateId, bool useTemplate, Map<String, int> mealAnchorDefaults, List<CustomMedicineEntry> customMedicines, bool permissionsGranted, bool isComplete, String? profileType, String caregiverPhone
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? selectedCondition = freezed,Object? selectedTemplateId = freezed,Object? useTemplate = null,Object? mealAnchorDefaults = null,Object? customMedicines = null,Object? permissionsGranted = null,Object? isComplete = null,Object? profileType = freezed,Object? caregiverPhone = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as OnboardingStep,selectedCondition: freezed == selectedCondition ? _self.selectedCondition : selectedCondition // ignore: cast_nullable_to_non_nullable
as String?,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,useTemplate: null == useTemplate ? _self.useTemplate : useTemplate // ignore: cast_nullable_to_non_nullable
as bool,mealAnchorDefaults: null == mealAnchorDefaults ? _self.mealAnchorDefaults : mealAnchorDefaults // ignore: cast_nullable_to_non_nullable
as Map<String, int>,customMedicines: null == customMedicines ? _self.customMedicines : customMedicines // ignore: cast_nullable_to_non_nullable
as List<CustomMedicineEntry>,permissionsGranted: null == permissionsGranted ? _self.permissionsGranted : permissionsGranted // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,profileType: freezed == profileType ? _self.profileType : profileType // ignore: cast_nullable_to_non_nullable
as String?,caregiverPhone: null == caregiverPhone ? _self.caregiverPhone : caregiverPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OnboardingStep currentStep,  String? selectedCondition,  String? selectedTemplateId,  bool useTemplate,  Map<String, int> mealAnchorDefaults,  List<CustomMedicineEntry> customMedicines,  bool permissionsGranted,  bool isComplete,  String? profileType,  String caregiverPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.currentStep,_that.selectedCondition,_that.selectedTemplateId,_that.useTemplate,_that.mealAnchorDefaults,_that.customMedicines,_that.permissionsGranted,_that.isComplete,_that.profileType,_that.caregiverPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OnboardingStep currentStep,  String? selectedCondition,  String? selectedTemplateId,  bool useTemplate,  Map<String, int> mealAnchorDefaults,  List<CustomMedicineEntry> customMedicines,  bool permissionsGranted,  bool isComplete,  String? profileType,  String caregiverPhone)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.currentStep,_that.selectedCondition,_that.selectedTemplateId,_that.useTemplate,_that.mealAnchorDefaults,_that.customMedicines,_that.permissionsGranted,_that.isComplete,_that.profileType,_that.caregiverPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OnboardingStep currentStep,  String? selectedCondition,  String? selectedTemplateId,  bool useTemplate,  Map<String, int> mealAnchorDefaults,  List<CustomMedicineEntry> customMedicines,  bool permissionsGranted,  bool isComplete,  String? profileType,  String caregiverPhone)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.currentStep,_that.selectedCondition,_that.selectedTemplateId,_that.useTemplate,_that.mealAnchorDefaults,_that.customMedicines,_that.permissionsGranted,_that.isComplete,_that.profileType,_that.caregiverPhone);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState implements OnboardingState {
  const _OnboardingState({this.currentStep = OnboardingStep.condition, this.selectedCondition, this.selectedTemplateId, this.useTemplate = false, final  Map<String, int> mealAnchorDefaults = const {}, final  List<CustomMedicineEntry> customMedicines = const [], this.permissionsGranted = false, this.isComplete = false, this.profileType, this.caregiverPhone = ''}): _mealAnchorDefaults = mealAnchorDefaults,_customMedicines = customMedicines;
  

/// Current wizard step.
@override@JsonKey() final  OnboardingStep currentStep;
/// User-selected condition key (e.g., `'diabetes'`).
@override final  String? selectedCondition;
/// ID of the selected template pack (null if manual path).
@override final  String? selectedTemplateId;
/// Whether the user chose the template path (vs manual).
@override@JsonKey() final  bool useTemplate;
/// Meal anchor default times: mealType → minutes from
/// midnight. E.g., `{'breakfast': 480, 'lunch': 780}`.
 final  Map<String, int> _mealAnchorDefaults;
/// Meal anchor default times: mealType → minutes from
/// midnight. E.g., `{'breakfast': 480, 'lunch': 780}`.
@override@JsonKey() Map<String, int> get mealAnchorDefaults {
  if (_mealAnchorDefaults is EqualUnmodifiableMapView) return _mealAnchorDefaults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mealAnchorDefaults);
}

/// Custom/edited medicine entries.
 final  List<CustomMedicineEntry> _customMedicines;
/// Custom/edited medicine entries.
@override@JsonKey() List<CustomMedicineEntry> get customMedicines {
  if (_customMedicines is EqualUnmodifiableListView) return _customMedicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customMedicines);
}

/// Whether required permissions have been granted.
@override@JsonKey() final  bool permissionsGranted;
/// Whether onboarding is complete.
@override@JsonKey() final  bool isComplete;
/// User profile type: 'elderly', 'adult', or 'parent'.
@override final  String? profileType;
/// Phone number for caregiver invitation (empty = skipped).
@override@JsonKey() final  String caregiverPhone;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.selectedCondition, selectedCondition) || other.selectedCondition == selectedCondition)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.useTemplate, useTemplate) || other.useTemplate == useTemplate)&&const DeepCollectionEquality().equals(other._mealAnchorDefaults, _mealAnchorDefaults)&&const DeepCollectionEquality().equals(other._customMedicines, _customMedicines)&&(identical(other.permissionsGranted, permissionsGranted) || other.permissionsGranted == permissionsGranted)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.profileType, profileType) || other.profileType == profileType)&&(identical(other.caregiverPhone, caregiverPhone) || other.caregiverPhone == caregiverPhone));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,selectedCondition,selectedTemplateId,useTemplate,const DeepCollectionEquality().hash(_mealAnchorDefaults),const DeepCollectionEquality().hash(_customMedicines),permissionsGranted,isComplete,profileType,caregiverPhone);

@override
String toString() {
  return 'OnboardingState(currentStep: $currentStep, selectedCondition: $selectedCondition, selectedTemplateId: $selectedTemplateId, useTemplate: $useTemplate, mealAnchorDefaults: $mealAnchorDefaults, customMedicines: $customMedicines, permissionsGranted: $permissionsGranted, isComplete: $isComplete, profileType: $profileType, caregiverPhone: $caregiverPhone)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 OnboardingStep currentStep, String? selectedCondition, String? selectedTemplateId, bool useTemplate, Map<String, int> mealAnchorDefaults, List<CustomMedicineEntry> customMedicines, bool permissionsGranted, bool isComplete, String? profileType, String caregiverPhone
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? selectedCondition = freezed,Object? selectedTemplateId = freezed,Object? useTemplate = null,Object? mealAnchorDefaults = null,Object? customMedicines = null,Object? permissionsGranted = null,Object? isComplete = null,Object? profileType = freezed,Object? caregiverPhone = null,}) {
  return _then(_OnboardingState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as OnboardingStep,selectedCondition: freezed == selectedCondition ? _self.selectedCondition : selectedCondition // ignore: cast_nullable_to_non_nullable
as String?,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,useTemplate: null == useTemplate ? _self.useTemplate : useTemplate // ignore: cast_nullable_to_non_nullable
as bool,mealAnchorDefaults: null == mealAnchorDefaults ? _self._mealAnchorDefaults : mealAnchorDefaults // ignore: cast_nullable_to_non_nullable
as Map<String, int>,customMedicines: null == customMedicines ? _self._customMedicines : customMedicines // ignore: cast_nullable_to_non_nullable
as List<CustomMedicineEntry>,permissionsGranted: null == permissionsGranted ? _self.permissionsGranted : permissionsGranted // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,profileType: freezed == profileType ? _self.profileType : profileType // ignore: cast_nullable_to_non_nullable
as String?,caregiverPhone: null == caregiverPhone ? _self.caregiverPhone : caregiverPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
