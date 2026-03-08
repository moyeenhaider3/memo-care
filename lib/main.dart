import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/core/providers/tts_providers.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AndroidAlarmManager before any scheduling.
  await AlarmScheduler.initialize();

  // Initialize SharedPreferences before any provider reads it.
  final prefs = await SharedPreferences.getInstance();

  // Pre-initialize TTS to avoid 300-800ms cold-start
  // delay on first speech request (PITFALLS.md §4).
  final ttsService = TTSService();
  try {
    await ttsService.initialize();
  } on Exception catch (e) {
    debugPrint(
      'TTS pre-initialization failed (non-fatal): $e',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        ttsServiceProvider.overrideWithValue(ttsService),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MemoCareApp(),
    ),
  );
}
