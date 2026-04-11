// E2E-style VM tests: full [HistoryExportService.exportPdf] (incl. Printing.sharePdf)
// and [CaregiverService.sendTestAlert], with platform channels mocked so nothing
// throws. Uses [kTraceVerificationCaregiverPhone] (+8527436117).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart';
import 'package:memo_care/core/platform/caregiver_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/history/application/history_export_service.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:memo_care/features/settings/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/trace_verification_fixtures.dart';

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

const MethodChannel _kPrintingChannel = MethodChannel('net.nfet.printing');
const MethodChannel _kConnectivityChannel =
    MethodChannel('dev.fluttercommunity.plus/connectivity');
const MethodChannel _kUrlLauncherChannel =
    MethodChannel('plugins.flutter.io/url_launcher');

void _mockPrintingSharePdf() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kPrintingChannel, (call) async {
    if (call.method == 'sharePdf') {
      return 1;
    }
    return null;
  });
}

void _mockConnectivityWifi() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kConnectivityChannel, (call) async {
    if (call.method == 'check') {
      return <String>['wifi'];
    }
    return null;
  });
}

void _mockUrlLauncherSuccess() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kUrlLauncherChannel, (call) async {
    switch (call.method) {
      case 'canLaunch':
        return true;
      case 'launch':
        return true;
      default:
        return null;
    }
  });
}

void _clearChannelMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kPrintingChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kConnectivityChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kUrlLauncherChannel, null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(_clearChannelMocks);

  group('HistoryExportService.exportPdf (full path)', () {
    test('completes without exception (Printing.sharePdf mocked)', () async {
      _mockPrintingSharePdf();

      final sample = traceVerificationSampleHistoryExport();

      final entries = [
        HistoryEntry(
          reminderId: 901,
          medicineName: 'TraceExport Med',
          dosage: '500 mg',
          scheduledAt: sample.scheduledAtUtc,
          status: ConfirmationState.done,
          confirmedAt: sample.scheduledAtUtc.add(const Duration(minutes: 3)),
        ),
      ];

      final logs = await _captureLogs(
        () => traceAsync(
          'ui',
          'HistoryScreen.exportPdf',
          () => HistoryExportService.exportPdf(
            entries: entries,
            weekStart: sample.weekStart,
            patientName: 'Trace Verification',
          ),
        ),
      );

      expect(
        logs,
        containsAll(<String>[
          '$kTracePrefix ▸ enter ui::HistoryScreen.exportPdf',
          '$kTracePrefix ▸ exit  ui::HistoryScreen.exportPdf',
        ]),
      );
      expect(
        logs.where((l) => l.contains('ui::HistoryScreen.exportPdf')),
        everyElement(isNot(contains('error='))),
      );
    });
  });

  group('CaregiverService.sendTestAlert', () {
    test('completes without exception (connectivity + url_launcher mocked)', () async {
      _mockConnectivityWifi();
      _mockUrlLauncherSuccess();

      await expectLater(
        CaregiverService.sendTestAlert(
          phoneNumber: kTraceVerificationCaregiverPhone,
        ),
        completion(isTrue),
      );
    });

    test('paired ui::SettingsScreen.sendTestAlert trace (same wrap as Settings)', () async {
      _mockConnectivityWifi();
      _mockUrlLauncherSuccess();

      final logs = await _captureLogs(
        () => traceAsync(
          'ui',
          'SettingsScreen.sendTestAlert',
          () => CaregiverService.sendTestAlert(
            phoneNumber: kTraceVerificationCaregiverPhone,
          ),
        ),
      );

      expect(
        logs,
        containsAll(<String>[
          '$kTracePrefix ▸ enter ui::SettingsScreen.sendTestAlert',
          '$kTracePrefix ▸ exit  ui::SettingsScreen.sendTestAlert',
        ]),
      );
      expect(
        logs.where((l) => l.contains('ui::SettingsScreen.sendTestAlert')),
        everyElement(isNot(contains('error='))),
      );
    });
  });

  group('SettingsRepository + caregiver phone', () {
    test('setCaregiverPhone accepts trace verification number', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);
      addTearDown(repo.dispose);

      await expectLater(
        repo.setCaregiverPhone(kTraceVerificationCaregiverPhone),
        completes,
      );
      expect(repo.getCaregiverPhone(), kTraceVerificationCaregiverPhone);

      await repo.update(
        repo.current.copyWith(caregiverPhone: kTraceVerificationCaregiverPhone),
      );
      expect(repo.getCaregiverPhone(), kTraceVerificationCaregiverPhone);
    });
  });
}
