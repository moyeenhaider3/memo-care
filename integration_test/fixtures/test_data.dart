import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/reminder_chain.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

// ── Test medicines ─────────────────────────────────────

/// Named medicine/dose pairs for consistent test data.
abstract final class TestMedicines {
  static const metformin = ('Metformin', '500 mg');
  static const insulin = ('Insulin', '10 units');
  static const amlodipine = ('Amlodipine', '5 mg');
  static const aspirin = ('Aspirin', '75 mg');
  static const omeprazole = ('Omeprazole', '20 mg');
}

// ── Test anchors ───────────────────────────────────────

/// Factory methods for meal anchor configurations.
abstract final class TestAnchors {
  /// Standard anchors: breakfast 08:00, lunch 13:00,
  /// dinner 20:00.
  static List<MealAnchor> defaultAnchors() => const [
    MealAnchor(
      id: 1,
      mealType: 'breakfast',
      defaultTimeMinutes: 480,
    ),
    MealAnchor(
      id: 2,
      mealType: 'lunch',
      defaultTimeMinutes: 780,
    ),
    MealAnchor(
      id: 3,
      mealType: 'dinner',
      defaultTimeMinutes: 1200,
    ),
  ];

  /// Early anchors: breakfast 06:00, lunch 11:00,
  /// dinner 18:00.
  static List<MealAnchor> earlyAnchors() => const [
    MealAnchor(
      id: 4,
      mealType: 'breakfast',
      defaultTimeMinutes: 360,
    ),
    MealAnchor(
      id: 5,
      mealType: 'lunch',
      defaultTimeMinutes: 660,
    ),
    MealAnchor(
      id: 6,
      mealType: 'dinner',
      defaultTimeMinutes: 1080,
    ),
  ];
}

// ── Test reminders ─────────────────────────────────────

/// Factory methods for individual reminder entries.
abstract final class TestReminders {
  /// Metformin — after-meal type.
  static const metformin = Reminder(
    id: 1,
    chainId: 1,
    medicineName: 'Metformin',
    medicineType: MedicineType.afterMeal,
    dosage: '500 mg',
  );

  /// Insulin — before-meal type.
  static const insulin = Reminder(
    id: 2,
    chainId: 1,
    medicineName: 'Insulin',
    medicineType: MedicineType.beforeMeal,
    dosage: '10 units',
  );

  /// Fixed-time reminder at 10:00 AM.
  static Reminder fixedTime() => Reminder(
    id: 3,
    chainId: 2,
    medicineName: 'Amlodipine',
    medicineType: MedicineType.fixedTime,
    dosage: '5 mg',
    scheduledAt: DateTime(2025, 1, 1, 10),
  );

  /// Dose-gap reminder — 4-hour interval.
  static const doseGap = Reminder(
    id: 4,
    chainId: 3,
    medicineName: 'Aspirin',
    medicineType: MedicineType.doseGap,
    dosage: '75 mg',
    gapHours: 4,
  );
}

// ── Test chains ────────────────────────────────────────

/// Factory methods for pre-built chain configurations.
abstract final class TestChains {
  /// Simple 1-node chain (fixed time, no dependencies).
  static ({ReminderChain chain, List<Reminder> reminders}) simpleChain() {
    final chain = ReminderChain(
      id: 2,
      name: 'Simple Fixed Time',
      createdAt: DateTime(2025),
    );
    final reminders = [TestReminders.fixedTime()];
    return (chain: chain, reminders: reminders);
  }

  /// Diabetic morning chain: insulin → metformin
  /// (2-node chain with edge).
  static ({
    ReminderChain chain,
    List<Reminder> reminders,
    List<ChainEdge> edges,
  })
  diabeticMorningChain() {
    final chain = ReminderChain(
      id: 1,
      name: 'Diabetic Morning Routine',
      createdAt: DateTime(2025),
    );
    const reminders = [
      TestReminders.insulin,
      TestReminders.metformin,
    ];
    const edges = [
      ChainEdge(
        id: 1,
        chainId: 1,
        sourceId: 2, // insulin
        targetId: 1, // metformin
      ),
    ];
    return (
      chain: chain,
      reminders: reminders,
      edges: edges,
    );
  }

  /// Complex 5-node chain with branching for cascade
  /// depth testing.
  static ({
    ReminderChain chain,
    List<Reminder> reminders,
    List<ChainEdge> edges,
  })
  complexChain() {
    final chain = ReminderChain(
      id: 3,
      name: 'Complex Morning Routine',
      createdAt: DateTime(2025),
    );
    const reminders = [
      Reminder(
        id: 10,
        chainId: 3,
        medicineName: 'Omeprazole',
        medicineType: MedicineType.emptyStomach,
        dosage: '20 mg',
      ),
      Reminder(
        id: 11,
        chainId: 3,
        medicineName: 'Insulin',
        medicineType: MedicineType.beforeMeal,
        dosage: '10 units',
      ),
      Reminder(
        id: 12,
        chainId: 3,
        medicineName: 'Metformin',
        medicineType: MedicineType.afterMeal,
        dosage: '500 mg',
      ),
      Reminder(
        id: 13,
        chainId: 3,
        medicineName: 'Aspirin',
        medicineType: MedicineType.afterMeal,
        dosage: '75 mg',
      ),
      Reminder(
        id: 14,
        chainId: 3,
        medicineName: 'Amlodipine',
        medicineType: MedicineType.fixedTime,
        dosage: '5 mg',
      ),
    ];
    // DAG: Omeprazole → Insulin → Metformin
    //                  → Aspirin
    //      Amlodipine (isolated)
    const edges = [
      ChainEdge(
        id: 10,
        chainId: 3,
        sourceId: 10,
        targetId: 11,
      ),
      ChainEdge(
        id: 11,
        chainId: 3,
        sourceId: 11,
        targetId: 12,
      ),
      ChainEdge(
        id: 12,
        chainId: 3,
        sourceId: 11,
        targetId: 13,
      ),
    ];
    return (
      chain: chain,
      reminders: reminders,
      edges: edges,
    );
  }
}
