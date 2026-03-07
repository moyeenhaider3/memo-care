import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// All available template packs.
const List<TemplatePack> kTemplatePacks = [
  kDiabeticPack,
  kBloodPressurePack,
  kSchoolMorningPack,
];

/// TMPL-01: Diabetic Pack.
///
/// Creates 3 parallel sub-chains (one per meal), each with:
///   insulin (beforeMeal) → metformin (afterMeal)
///
/// Chain structure:
/// ```text
///   [0] Breakfast Insulin → [1] Breakfast Metformin
///   [2] Lunch Insulin     → [3] Lunch Metformin
///   [4] Dinner Insulin    → [5] Dinner Metformin
/// ```
const kDiabeticPack = TemplatePack(
  id: 'diabetic_pack',
  name: 'Diabetic Pack',
  description:
      'Insulin + Metformin linked to breakfast, lunch, and dinner',
  condition: 'diabetes',
  medicines: [
    // Breakfast pair
    TemplateMedicine(
      name: 'Insulin',
      medicineType: MedicineType.beforeMeal,
      defaultDosage: '10 units',
      chainPosition: 0,
      anchorMeal: TemplateMealType.breakfast,
    ),
    TemplateMedicine(
      name: 'Metformin',
      medicineType: MedicineType.afterMeal,
      defaultDosage: '500mg',
      chainPosition: 1,
      anchorMeal: TemplateMealType.breakfast,
    ),
    // Lunch pair
    TemplateMedicine(
      name: 'Insulin',
      medicineType: MedicineType.beforeMeal,
      defaultDosage: '10 units',
      chainPosition: 2,
      anchorMeal: TemplateMealType.lunch,
    ),
    TemplateMedicine(
      name: 'Metformin',
      medicineType: MedicineType.afterMeal,
      defaultDosage: '500mg',
      chainPosition: 3,
      anchorMeal: TemplateMealType.lunch,
    ),
    // Dinner pair
    TemplateMedicine(
      name: 'Insulin',
      medicineType: MedicineType.beforeMeal,
      defaultDosage: '10 units',
      chainPosition: 4,
      anchorMeal: TemplateMealType.dinner,
    ),
    TemplateMedicine(
      name: 'Metformin',
      medicineType: MedicineType.afterMeal,
      defaultDosage: '500mg',
      chainPosition: 5,
      anchorMeal: TemplateMealType.dinner,
    ),
  ],
  edges: [
    TemplateEdge(sourceIndex: 0, targetIndex: 1),
    TemplateEdge(sourceIndex: 2, targetIndex: 3),
    TemplateEdge(sourceIndex: 4, targetIndex: 5),
  ],
);

/// TMPL-02: Blood Pressure Pack.
///
/// Simple morning → evening chain for BP medication.
///
/// Chain structure:
/// ```text
///   [0] Morning BP Med (08:00) → [1] Evening BP Med (20:00)
/// ```
const kBloodPressurePack = TemplatePack(
  id: 'blood_pressure_pack',
  name: 'Blood Pressure Pack',
  description: 'Morning and evening blood pressure medication',
  condition: 'blood_pressure',
  medicines: [
    TemplateMedicine(
      name: 'BP Medicine (Morning)',
      medicineType: MedicineType.fixedTime,
      chainPosition: 0,
      defaultTimeMinutes: 480,
    ),
    TemplateMedicine(
      name: 'BP Medicine (Evening)',
      medicineType: MedicineType.fixedTime,
      chainPosition: 1,
      defaultTimeMinutes: 1200,
    ),
  ],
  edges: [
    TemplateEdge(sourceIndex: 0, targetIndex: 1),
  ],
);

/// TMPL-03: School Morning Pack.
///
/// Linear chain for a child's morning routine with medication.
///
/// Chain structure:
/// ```text
///   [0] Wake-up (06:30) → [1] Breakfast (07:00)
///     → [2] Medicine (afterMeal) → [3] Leave (08:00)
/// ```
const kSchoolMorningPack = TemplatePack(
  id: 'school_morning_pack',
  name: 'School Morning Pack',
  description:
      'Wake-up → breakfast → medicine → leave for school',
  condition: 'school_morning',
  medicines: [
    TemplateMedicine(
      name: 'Wake Up',
      medicineType: MedicineType.fixedTime,
      chainPosition: 0,
      defaultTimeMinutes: 390,
    ),
    TemplateMedicine(
      name: 'Breakfast',
      medicineType: MedicineType.fixedTime,
      chainPosition: 1,
      defaultTimeMinutes: 420,
    ),
    TemplateMedicine(
      name: 'Medicine',
      medicineType: MedicineType.afterMeal,
      chainPosition: 2,
      anchorMeal: TemplateMealType.breakfast,
    ),
    TemplateMedicine(
      name: 'Leave for School',
      medicineType: MedicineType.fixedTime,
      chainPosition: 3,
      defaultTimeMinutes: 480,
    ),
  ],
  edges: [
    TemplateEdge(sourceIndex: 0, targetIndex: 1),
    TemplateEdge(sourceIndex: 1, targetIndex: 2),
    TemplateEdge(sourceIndex: 2, targetIndex: 3),
  ],
);
