package com.example.memo_care

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receives BOOT_COMPLETED and QUICKBOOT_POWERON broadcasts.
 *
 * Starts [AlarmReschedulerService] to reschedule all pending
 * medication alarms via a headless Flutter engine.
 */
class BootCompletedReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "MemoCare.BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            Log.i(TAG, "Boot completed — scheduling alarm reschedule")
            AlarmReschedulerService.enqueue(context, "boot_completed")
        }
    }
}
