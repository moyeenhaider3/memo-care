import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// TMPL-08: Ramadan Medicine Pack.
const kRamadanMedicinePack = TemplatePack(
  id: 'ramadan_medicine_pack',
  name: 'Ramadan Medicine Pack',
  description: 'Sehri and iftar medicine routine with taraweeh reminder',
  condition: 'ramadan',
  medicines: [
    TemplateMedicine(
      name: 'Pre-Sehri Medicine',
      medicineType: MedicineType.beforeMeal,
      chainPosition: 0,
      defaultDosage: '1 tablet',
      anchorMeal: TemplateMealType.breakfast,
    ),
    TemplateMedicine(
      name: 'Iftar Medicine',
      medicineType: MedicineType.afterMeal,
      chainPosition: 1,
      defaultDosage: '1 tablet',
      anchorMeal: TemplateMealType.dinner,
    ),
    TemplateMedicine(
      name: 'Taraweeh Reminder',
      medicineType: MedicineType.fixedTime,
      chainPosition: 2,
      defaultTimeMinutes: 1230,
    ),
  ],
  edges: [
    TemplateEdge(sourceIndex: 0, targetIndex: 1),
    TemplateEdge(sourceIndex: 1, targetIndex: 2),
  ],
);
