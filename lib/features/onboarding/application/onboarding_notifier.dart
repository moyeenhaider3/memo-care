import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';

/// Manages onboarding wizard state across all steps.
///
/// Pure state management — no side effects (no DB writes, no
/// permission requests). The review/completion step reads
/// this state and calls `TemplateService` / `PermissionService`
/// as needed.
///
/// `keepAlive` so state persists across step navigations.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Select a health condition (e.g., `'diabetes'`).
  void selectCondition(String condition) {
    state = state.copyWith(
      selectedCondition: condition,
      // Reset template selection when condition changes.
      selectedTemplateId: null,
      useTemplate: false,
    );
  }

  /// Select a template pack by ID. Sets `useTemplate` to
  /// `true`.
  void selectTemplate(String templateId) {
    state = state.copyWith(
      selectedTemplateId: templateId,
      useTemplate: true,
    );
  }

  /// Skip the template and go manual. Clears any template
  /// selection.
  void skipTemplate() {
    state = state.copyWith(
      selectedTemplateId: null,
      useTemplate: false,
    );
  }

  /// Set a meal anchor default time.
  ///
  /// [mealType] is `'breakfast'`, `'lunch'`, or `'dinner'`.
  /// [minutesFromMidnight] is the time in minutes
  /// (e.g., 480 = 08:00).
  void setMealAnchor(String mealType, int minutesFromMidnight) {
    state = state.copyWith(
      mealAnchorDefaults: {
        ...state.mealAnchorDefaults,
        mealType: minutesFromMidnight,
      },
    );
  }

  /// Add a custom medicine entry.
  void addCustomMedicine(CustomMedicineEntry medicine) {
    state = state.copyWith(
      customMedicines: [...state.customMedicines, medicine],
    );
  }

  /// Remove a custom medicine by index.
  void removeCustomMedicine(int index) {
    final updated = [...state.customMedicines]..removeAt(index);
    state = state.copyWith(customMedicines: updated);
  }

  /// Update a custom medicine at the given index.
  void updateCustomMedicine(
    int index,
    CustomMedicineEntry medicine,
  ) {
    final updated = [...state.customMedicines];
    updated[index] = medicine;
    state = state.copyWith(customMedicines: updated);
  }

  /// Navigate to a specific step.
  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// Mark permissions as granted.
  void setPermissionsGranted({required bool granted}) {
    state = state.copyWith(permissionsGranted: granted);
  }

  /// Set user profile type ('elderly', 'adult', 'parent').
  void setProfileType(String type) {
    state = state.copyWith(profileType: type);
  }

  /// Set caregiver phone number.
  void setCaregiverPhone(String phone) {
    state = state.copyWith(caregiverPhone: phone);
  }

  /// Mark onboarding as complete and persist to SharedPreferences.
  void completeOnboarding() {
    ref.read(sharedPreferencesProvider).setBool('onboarding_complete', true);
    state = state.copyWith(
      currentStep: OnboardingStep.complete,
      isComplete: true,
    );
  }

  /// Reset all onboarding state (for testing or
  /// re-onboarding).
  void reset() {
    state = const OnboardingState();
  }
}

/// Provides the [OnboardingNotifier]. Keep-alive so state
/// persists across step navigations.
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
