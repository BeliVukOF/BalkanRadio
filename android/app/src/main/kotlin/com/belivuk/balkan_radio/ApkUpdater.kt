package com.belivuk.balkan_radio

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import java.io.File

/**
 * Silent update. DownloadManager is a system service, so the APK keeps
 * downloading even if the app is backgrounded or killed; Dart polls
 * [status] until the file lands and then calls [install].
 *
 * Android has no self-install API: the system installer dialog always shows.
 * That is a platform limit, not a choice made here.
 */
object ApkUpdater {
    const val OK = "ok"
    const val RUNNING = "running"
    const val FAILED = "failed"

    /** False when the user has never allowed this app to install packages. */
    fun canRequestInstall(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            context.packageManager.canRequestPackageInstalls()

    /** Returns the download id, or -1 when the request was refused. */
    fun enqueue(context: Context, url: String, fileName: String): Long = try {
        val request = DownloadManager.Request(Uri.parse(url))
            .setTitle("Balkan Radio")
            .setNotificationVisibility(
                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED,
            )
            .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
            .setAllowedOverMetered(true)
            .setAllowedOverRoaming(true)
        val manager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        manager.enqueue(request)
    } catch (e: Exception) {
        -1
    }

    /** OK plus the file path, RUNNING while it downloads, FAILED on any error. */
    fun status(context: Context, id: Long, fileName: String): Pair<String, String?> {
        val manager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        var outcome = FAILED
        manager.query(DownloadManager.Query().setFilterById(id)).use { cursor ->
            if (!cursor.moveToFirst()) return FAILED to null
            outcome = when (
                cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
            ) {
                DownloadManager.STATUS_SUCCESSFUL -> OK
                DownloadManager.STATUS_RUNNING,
                DownloadManager.STATUS_PENDING,
                DownloadManager.STATUS_PAUSED,
                -> RUNNING
                else -> FAILED
            }
        }
        if (outcome != OK) return outcome to null
        val file = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            fileName,
        )
        return if (file.exists() && file.length() > 0) OK to file.absolutePath
        else FAILED to null
    }

    /**
     * Hands the APK to the system installer. The user must tap confirm -
     * Android requires it and no app can skip that step.
     */
    fun install(context: Context, path: String): Boolean = try {
        val uri = FileProvider.getUriForFile(
            context, "${context.packageName}.fileprovider", File(path),
        )
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(
                android.content.Intent.FLAG_ACTIVITY_NEW_TASK or
                    android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        context.startActivity(intent)
        true
    } catch (e: Exception) {
        false
    }
}
