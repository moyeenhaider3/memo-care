package com.example.memo_care

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receives MY_PACKAGE_REPLACED broadcast after app update.
 *
 * Some devices clear AlarmManager alarms on app update.
 * Triggers rescheduling to restore all pending alarms.
 */
class PackageReplacedReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "MemoCare.UpdateReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            Log.i(TAG, "App updated — scheduling alarm reschedule")
            AlarmReschedulerService.enqueue(context, "package_replaced")
        }
    }
}
