package com.belivuk.balkan_radio

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    // Android 13+ hides the media notification (and its play/pause buttons) until the user
    // grants POST_NOTIFICATIONS; playback itself works without it.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
        }
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canRequestPackageInstalls" ->
                        result.success(ApkUpdater.canRequestInstall(this))
                    "requestInstallPermission" -> {
                        openInstallPermission()
                        result.success(true)
                    }
                    "enqueueDownload" -> {
                        val url = call.argument<String>("url").orEmpty()
                        val name = call.argument<String>("fileName").orEmpty()
                        if (url.isEmpty() || name.isEmpty()) {
                            result.error("bad_args", "url and fileName are required", null)
                        } else {
                            result.success(ApkUpdater.enqueue(this, url, name))
                        }
                    }
                    "downloadStatus" -> {
                        val id = call.argument<Number>("id")?.toLong() ?: -1L
                        val name = call.argument<String>("fileName").orEmpty()
                        val (state, path) = ApkUpdater.status(this, id, name)
                        result.success(mapOf("state" to state, "path" to path))
                    }
                    "installApk" -> {
                        val path = call.argument<String>("path").orEmpty()
                        if (path.isEmpty()) result.success(false)
                        else result.success(ApkUpdater.install(this, path))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Android 8+ hides the "install unknown apps" toggle until asked for. */
    private fun openInstallPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        try {
            startActivity(
                Intent(
                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:$packageName"),
                ),
            )
        } catch (e: Exception) {
            startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES))
        }
    }

    companion object {
        private const val CHANNEL = "balkan_radio/update"
    }
}
