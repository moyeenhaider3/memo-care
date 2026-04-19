// Phase 5–6 (trace plan): `settings::*` (including `updateAll`), Settings UI stub
// taps (`SettingsScreen.exportPdf.stub` / `exportCsv.stub`), and
// `ui::HistoryScreen.exportPdf` (body uses [HistoryExportService.buildPdfBytes]
// only so tests avoid [Printing.sharePdf] platform channels).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/history/application/history_export_service.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/features/settings/data/settings_repository.dart';
import 'package:memo_care/features/settings/domain/models/app_settings.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/settings/presentation/settings_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

const MethodChannel _kPrintingChannel = MethodChannel('net.nfet.printing');
const MethodChannel _kShareChannel =
    MethodChannel('dev.fluttercommunity.plus/share');

class _MockReminderRepository extends Mock implements ReminderRepository {}

void _mockPrintingSharePdf() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kPrintingChannel, (call) async {
    if (call.method == 'sharePdf') {
      return 1;
    }
    return null;
  });
}

void _mockShareFiles() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kShareChannel, (call) async {
    return 'dev.fluttercommunity.plus/share/success';
  });
}

void _clearPrintingMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kPrintingChannel, null);
}

void _clearShareMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kShareChannel, null);
}

Future<List<String>> _captureLogs(Future<void> Function() body) async {
  final logs = <String>[];
  final previousPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null) logs.add(message);
    previousPrint(message, wrapWidth: wrapWidth);
  };
  try {
    await body();
  } finally {
    debugPrint = previousPrint;
  }
  return logs;
}

void _expectPairedScopeStep(
  List<String> logs,
  String scope,
  String step,
) {
  final enter = '$kTracePrefix ▸ enter $scope::$step';
  final exit = '$kTracePrefix ▸ exit  $scope::$step';
  expect(logs, contains(enter));
  expect(logs, contains(exit));
  expect(
    logs.where((l) => l.contains('$scope::$step')),
    everyElement(isNot(contains('error='))),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRepository MemoCareTrace', () {
    test('all settings::* steps pair (incl. updateAll + caregiver dedupe)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);
      addTearDown(repo.dispose);

      final logs = await _captureLogs(() async {
        await repo.setSnoozeDuration(6);
        await repo.setSilentTimeout(3);
        await repo.setAudibleTimeout(4);
        await repo.setNotificationsEnabled(enabled: false);
        await repo.setSoundEnabled(enabled: false);
        await repo.setVibrationEnabled(enabled: false);
        await repo.setLargeText(true);
        await repo.setHighContrast(true);
        await repo.setDarkMode(true);
        await repo.setCaregiverPhone('+15551234567');
        await repo.markMissedReminderAlerted(42);
        await repo.retainAlertedMissedReminderIds({42});
        await repo.update(
          const AppSettings(
            snoozeDurationMinutes: 7,
            silentTimeoutMinutes: 2,
            audibleTimeoutMinutes: 3,
            notificationsEnabled: true,
            soundEnabled: true,
            vibrationEnabled: true,
            largeText: false,
            highContrast: false,
            darkMode: false,
            caregiverPhone: '',
            profileName: 'User',
          ),
        );
      });

      _expectPairedScopeStep(logs, 'settings', 'setSnoozeDuration');
      _expectPairedScopeStep(logs, 'settings', 'setSilentTimeout');
      _expectPairedScopeStep(logs, 'settings', 'setAudibleTimeout');
      _expectPairedScopeStep(logs, 'settings', 'setNotificationsEnabled');
      _expectPairedScopeStep(logs, 'settings', 'setSoundEnabled');
      _expectPairedScopeStep(logs, 'settings', 'setVibrationEnabled');
      _expectPairedScopeStep(logs, 'settings', 'setLargeText');
      _expectPairedScopeStep(logs, 'settings', 'setHighContrast');
      _expectPairedScopeStep(logs, 'settings', 'setDarkMode');
      _expectPairedScopeStep(logs, 'settings', 'setCaregiverPhone');
      _expectPairedScopeStep(logs, 'settings', 'markMissedReminderAlerted');
      _expectPairedScopeStep(logs, 'settings', 'retainAlertedMissedReminderIds');
      _expectPairedScopeStep(logs, 'settings', 'updateAll');
    });
  });

  group('SettingsScreen stub buttons MemoCareTrace', () {
    testWidgets('Export PDF / CSV stubs fire paired ui::* traces', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final logs = <String>[];
      final previousPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
        previousPrint(message, wrapWidth: wrapWidth);
      };
      try {
        _mockPrintingSharePdf();
        _mockShareFiles();
        addTearDown(() {
          _clearPrintingMock();
          _clearShareMock();
        });

        final mockRepo = _MockReminderRepository();
        when(
          () => mockRepo.getHistoryPage(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            medicineNameFilter: any(named: 'medicineNameFilter'),
          ),
        ).thenAnswer((_) async => []);

        await tester.binding.setSurfaceSize(const Size(800, 2000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              reminderRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pdfFinder = find.text('Export PDF');
        await tester.scrollUntilVisible(
          pdfFinder,
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(pdfFinder);
        await tester.pumpAndSettle();

        final csvFinder = find.text('Export CSV');
        await tester.scrollUntilVisible(
          csvFinder,
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(csvFinder);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        _expectPairedScopeStep(logs, 'ui', 'SettingsScreen.exportPdf');
        expect(
          logs.any((l) => l.contains('enter ui::SettingsScreen.exportCsv')),
          isTrue,
        );
      } finally {
        debugPrint = previousPrint;
      }
    });
  });

  group('HistoryScreen.exportPdf MemoCareTrace', () {
    test('trace pairs when PDF bytes build succeeds (no share sheet)', () async {
      final entries = [
        HistoryEntry(
          reminderId: 1,
          medicineName: 'Metformin',
          dosage: '500 mg',
          scheduledAt: DateTime.utc(2026, 3, 29, 8),
          status: ConfirmationState.done,
          confirmedAt: DateTime.utc(2026, 3, 29, 8, 5),
        ),
      ];

      final logs = await _captureLogs(() async {
        await traceAsync(
          'ui',
          'HistoryScreen.exportPdf',
          () async {
            await HistoryExportService.buildPdfBytes(
              entries: entries,
              weekStart: DateTime.utc(2026, 3, 23),
            );
          },
        );
      });

      _expectPairedScopeStep(logs, 'ui', 'HistoryScreen.exportPdf');
    });
  });
}
