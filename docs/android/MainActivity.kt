// COPY EVERYTHING BELOW THIS LINE into your MainActivity.kt,
// under the "package ..." line that is already at the top of that file.

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * TruthArmor's Android activity.
 * Adds "Share → TruthArmor": other apps can share a message, link, or
 * screenshot to TruthArmor. A shared screenshot is copied to a private
 * temporary file, read on the device, and then deleted by the app.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingShare: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "trutharmor/share").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialShare") {
                    result.success(pendingShare)
                    pendingShare = null
                } else {
                    result.notImplemented()
                }
            }
        }
        pendingShare = readShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val share = readShare(intent) ?: return
        channel?.invokeMethod("onShare", share)
    }

    private fun readShare(intent: Intent?): Map<String, String>? {
        if (intent == null || intent.action != Intent.ACTION_SEND) return null
        val type = intent.type ?: ""
        var result: Map<String, String>? = null
        if (type.startsWith("image/")) {
            val path = sharedImageUri(intent)?.let { copyToCache(it) }
            if (path != null) result = mapOf("imagePath" to path)
        } else {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)
            val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            if (!text.isNullOrBlank()) {
                val full = if (!subject.isNullOrBlank() && !text.contains(subject)) "$subject\n$text" else text
                result = mapOf("text" to full)
            }
        }
        // Mark it as handled so turning the phone doesn't share it twice.
        intent.action = Intent.ACTION_MAIN
        return result
    }

    @Suppress("DEPRECATION")
    private fun sharedImageUri(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri
        }

    private fun copyToCache(uri: Uri): String? {
        return try {
            val dir = File(cacheDir, "shared")
            dir.mkdirs()
            dir.listFiles()?.forEach { it.delete() } // Remove any old copies.
            val file = File(dir, "shared_${System.currentTimeMillis()}.jpg")
            val input = contentResolver.openInputStream(uri) ?: return null
            input.use { inp -> file.outputStream().use { out -> inp.copyTo(out) } }
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }
}
