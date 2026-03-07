package com.example.memo_care

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader

/**
 * Shared service that starts a headless FlutterEngine to run
 * the Dart [rescheduleAlarmsOnBoot] entry point.
 *
 * Called by both [BootCompletedReceiver] and
 * [PackageReplacedReceiver].
 */
object AlarmReschedulerService {
    private const val TAG = "MemoCare.Rescheduler"
    private var flutterEngine: FlutterEngine? = null

    fun enqueue(context: Context, reason: String) {
        Log.i(TAG, "Rescheduling alarms (reason: $reason)")

        try {
            val loader = FlutterLoader()
            loader.startInitialization(context.applicationContext)
            loader.ensureInitializationComplete(
                context.applicationContext,
                null
            )

            val engine = FlutterEngine(context.applicationContext)
            flutterEngine = engine

            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "rescheduleAlarmsOnBoot"
                )
            )

            Log.i(TAG, "Headless Flutter engine started")
        } catch (e: Exception) {
            Log.e(
                TAG,
                "Failed to start rescheduler: ${e.message}",
                e
            )
        }
    }

    fun destroy() {
        flutterEngine?.destroy()
        flutterEngine = null
    }
}
