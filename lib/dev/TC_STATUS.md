# TC status sheet (MemoCare dev harness)

Run the harness:

```bash
flutter run -t lib/dev/dev_main.dart
```

Read the **terminal** output: `✅ PASS`, `❌ FAIL`, `⚠️ MANUAL`, `🔶 SKIPPED`, and the final **MEMOCARE TEST RUN SUMMARY**.

This file is a **template** for recording human follow-up. The authoritative machine-readable list is `tc_method_map.dart` (205 entries). Update the **Status** column after each QA pass.

## Legend

| Status | Meaning |
|--------|---------|
| 🔲 Not Run | Harness not executed or not yet reviewed |
| ✅ Pass | Log showed PASS for auto checks, or manual step confirmed |
| ❌ Fail | Log showed FAIL or manual step failed |
| ⚠️ Manual Pending | Requires device/UI (navigation, permissions, rotation) |

| TC | Screen | Method / provider (see `tc_method_map.dart`) | Auto-Verifiable | Status | Notes |
|----|--------|-----------------------------------------------|-----------------|--------|-------|
| TC-001 | App Shell | `AppShell` / bottom nav | ⚠️ Visual | 🔲 Not Run | Tap tabs on device |
| TC-009 | App Shell | Route constants / redirect | ✅ Yes | 🔲 Not Run | Harness checks paths |
| TC-046 | Home | `dailyScheduleNotifierProvider` | ✅ Yes | 🔲 Not Run | Counts after seed |
| TC-085 | History | `historyNotifierProvider` | ✅ Yes | 🔲 Not Run | Items after seed |
| TC-110 | Profile | `settingsRepository.getCaregiverPhone` | ✅ Yes | 🔲 Not Run | Seeded E.164 |
| TC-128 | Add Reminder | `AddReminderState.isValid` | ✅ Yes | 🔲 Not Run | Empty name |
| TC-149 | Templates | `kTemplatePacks` | ✅ Yes | 🔲 Not Run | Pack count |
| TC-160 | Chain | `chainContextProvider` | ✅ Yes | 🔲 Not Run | Middle reminder |
| TC-174 | Alarm | Caregiver + reminder id | ⚠️ Mixed | 🔲 Not Run | Open `/alarm/:id` manually |
| TC-189 | Kids | `kidsModeNotifierProvider` | ✅ Yes | 🔲 Not Run | Child name Ali |

*(Add remaining TC-002…TC-205 rows from `tc_method_map.dart` as needed for your spreadsheet.)*

## Harness files

| File | Role |
|------|------|
| `lib/dev/dev_main.dart` | Entry point: bootstrap + `TestDataSeeder.seedAll` + delayed `MasterTestRunner` |
| `lib/dev/test_data_seeder.dart` | Drift clears + inserts, SharedPreferences, notifier seed |
| `lib/dev/harness_seed_context.dart` | Seeded IDs for runners |
| `lib/dev/harness_log.dart` | Terminal log + counters |
| `lib/dev/harness_runners.dart` | Provider/API checks per screen group |
| `lib/dev/master_test_runner.dart` | Runs all runners + summary |
| `lib/dev/tc_method_map.dart` | `TcDefinition` for TC-001–TC-205 |
| `lib/dev/runners/*_test_runner.dart` | Thin wrappers (same as `HarnessRunners` sections) |

## Rules

- **No** `flutter_test` / **no** `assert()` in harness code (use logs).
- Production `lib/` must **not** import `lib/dev/` (only `dev_main.dart` entry is used for harness runs).
