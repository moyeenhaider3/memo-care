import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

part 'onboarding_state.freezed.dart';

/// Steps in the onboarding wizard.
///
/// Maps 1:1 to GoRouter sub-routes in the onboarding flow.
enum OnboardingStep {
  /// Select a health condition.
  condition,

  /// Choose a template pack or skip.
  template,

  /// Set default meal anchor times.
  anchors,

  /// Add or edit medicines.
  medicines,

  /// Review all selections before committing.
  review,

  /// Request required permissions.
  permissions,

  /// Onboarding finished.
  complete,
}

/// A user-entered medicine during onboarding.
///
/// Not a database entity — converted to a real `Reminder`
/// during onboarding completion. Used for both manual path
/// and template customization.
class CustomMedicineEntry {
  /// Creates a [CustomMedicineEntry].
  const CustomMedicineEntry({
    required this.name,
    required this.medicineType,
    this.dosage,
    this.timeMinutes,
    this.anchorMeal,
  });

  /// Medicine display name.
  final String name;

  /// How this medicine relates to meals/timing.
  final MedicineType medicineType;

  /// Dosage text, e.g. `'500mg'`.
  final String? dosage;

  /// Scheduled time in minutes from midnight (for fixedTime).
  final int? timeMinutes;

  /// Meal anchor key: `'breakfast'`, `'lunch'`, `'dinner'`.
  final String? anchorMeal;

  /// Returns a copy with the specified fields replaced.
  CustomMedicineEntry copyWith({
    String? name,
    MedicineType? medicineType,
    String? dosage,
    int? timeMinutes,
    String? anchorMeal,
  }) {
    return CustomMedicineEntry(
      name: name ?? this.name,
      medicineType: medicineType ?? this.medicineType,
      dosage: dosage ?? this.dosage,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      anchorMeal: anchorMeal ?? this.anchorMeal,
    );
  }
}

/// Immutable state for the onboarding wizard.
///
/// Captures all user selections across the multi-step flow.
/// Read by the review step to either instantiate a template
/// or create manual reminders.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    /// Current wizard step.
    @Default(OnboardingStep.condition) OnboardingStep currentStep,

    /// User-selected condition key (e.g., `'diabetes'`).
    String? selectedCondition,

    /// ID of the selected template pack (null if manual path).
    String? selectedTemplateId,

    /// Whether the user chose the template path (vs manual).
    @Default(false) bool useTemplate,

    /// Meal anchor default times: mealType → minutes from
    /// midnight. E.g., `{'breakfast': 480, 'lunch': 780}`.
    @Default({}) Map<String, int> mealAnchorDefaults,

    /// Custom/edited medicine entries.
    @Default([]) List<CustomMedicineEntry> customMedicines,

    /// Whether required permissions have been granted.
    @Default(false) bool permissionsGranted,

    /// Whether onboarding is complete.
    @Default(false) bool isComplete,

    /// User profile type: 'elderly', 'adult', or 'parent'.
    String? profileType,

    /// Phone number for caregiver invitation (empty = skipped).
    @Default('') String caregiverPhone,
  }) = _OnboardingState;
}
