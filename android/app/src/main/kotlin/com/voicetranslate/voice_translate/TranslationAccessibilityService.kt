package com.voicetranslate.voice_translate

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class TranslationAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "TranslationA11y"
        var isServiceRunning = false
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        Log.d(TAG, "Accessibility service connected")

        val intent = Intent("VOICE_TRANSLATE_SERVICE_CONNECTED")
        sendBroadcast(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // We primarily use this service to keep our app running in the background.
        // The actual speech recognition is handled by the Flutter layer.
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted")
    }

    override fun onUnbind(intent: Intent?): Boolean {
        isServiceRunning = false
        Log.d(TAG, "Accessibility service unbinding")
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        isServiceRunning = false
        super.onDestroy()
    }
}
