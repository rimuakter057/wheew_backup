package me.platechat.app

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.platechat/voice_intent"
    private var methodChannel: MethodChannel? = null

    // Stores the raw voice command string until Flutter is ready to receive it
    private var pendingVoiceText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                // Flutter asks: "do you have a pending voice command?"
                "checkPendingIntent" -> {
                    val pending = pendingVoiceText
                    if (!pending.isNullOrBlank()) {
                        // Send the voice command to Flutter
                        methodChannel?.invokeMethod("onVoiceIntent", pending)
                        pendingVoiceText = null
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // If the app was launched by a voice/deep-link intent, flush it now
        flushPendingIntentToFlutter()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        parseVoiceIntent(intent)
    }

    /**
     * Called when app is already running and receives a new intent
     * (e.g. Google Assistant triggers it while app is in background)
     */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        parseVoiceIntent(intent)
        // If Flutter engine is already up, flush immediately
        flushPendingIntentToFlutter()
    }

    /**
     * Parse the incoming Intent and convert it to a raw voice command string.
     *
     * Supported formats:
     *   1. Deep link: platechat://send?to=John&msg=Hello
     *   2. Deep link: platechat://chat?to=John
     *   3. Android ACTION_SEND text/plain (share sheet / Assistant)
     *   4. App Actions shortcut extras (to / msg keys)
     */
    private fun parseVoiceIntent(intent: Intent?) {
        if (intent == null) return

        // ── Hands-Free Assistant Launch Detection ────────────────────
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val ref = referrer
            if (ref != null) {
                val refStr = ref.toString().lowercase()
                if (refStr.contains("googlequicksearchbox") || 
                    refStr.contains("assistant") || 
                    refStr.contains("google")) {
                    pendingVoiceText = "trigger_voice_mode"
                    return
                }
            }
        }

        val data = intent.data

        // ── Format 1 & 2: Custom deep link ──────────────────────────
        if (data?.scheme == "platechat") {
            val to  = data.getQueryParameter("to")?.trim()  ?: ""
            val msg = data.getQueryParameter("msg")?.trim() ?: ""

            when (data.host) {
                "send" -> {
                    if (to.isNotEmpty()) {
                        pendingVoiceText = if (msg.isNotEmpty())
                            "send $msg to $to"
                        else
                            "message $to"
                    }
                }
                "chat" -> {
                    if (to.equals("voice", ignoreCase = true) || to.equals("assistant", ignoreCase = true)) {
                        pendingVoiceText = "trigger_voice_mode"
                    } else if (to.isNotEmpty()) {
                        pendingVoiceText = "open chat with $to"
                    }
                }
                "search" -> {
                    val query = data.getQueryParameter("query")?.trim() ?: ""
                    if (query.isNotEmpty()) {
                        pendingVoiceText = query
                    }
                }
            }
            return
        }

        // ── Format 3: ACTION_SEND text/plain ────────────────────────
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
            if (!text.isNullOrBlank()) {
                pendingVoiceText = text
            }
            return
        }

        // ── Format 4: App Actions shortcut extras ────────────────────
        val to  = intent.getStringExtra("to")?.trim()
        val msg = intent.getStringExtra("msg")?.trim()
        if (!to.isNullOrBlank()) {
            pendingVoiceText = if (!msg.isNullOrBlank())
                "send $msg to $to"
            else
                "message $to"
        }
    }

    /**
     * Push any stored pending intent to Flutter via MethodChannel.
     * Safe to call multiple times — clears after sending.
     */
    private fun flushPendingIntentToFlutter() {
        val pending = pendingVoiceText ?: return
        val channel = methodChannel   ?: return   // Flutter not ready yet

        pendingVoiceText = null
        channel.invokeMethod("onVoiceIntent", pending)
    }
}
