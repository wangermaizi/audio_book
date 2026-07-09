package com.wangermazi.audiobook.audio_book

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val updateChannel = "com.wangermazi.audiobook.audio_book/update"
    private val shareChannel = "com.wangermazi.audiobook.audio_book/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, updateChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("INVALID_PATH", "APK path is empty", null)
                            return@setMethodCallHandler
                        }
                        try {
                            installApk(path)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("INSTALL_FAILED", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val title = call.argument<String>("title").orEmpty()
                        val content = call.argument<String>("content").orEmpty()
                        if (content.isBlank()) {
                            result.error("INVALID_CONTENT", "Share content is empty", null)
                            return@setMethodCallHandler
                        }
                        try {
                            shareText(title, content)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("SHARE_FAILED", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun installApk(path: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !packageManager.canRequestPackageInstalls()) {
            val permissionIntent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(permissionIntent)
            return
        }

        val apkFile = File(path)
        val apkUri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            apkFile,
        )
        val installIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(apkUri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(installIntent)
    }

    private fun shareText(title: String, content: String) {
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_SUBJECT, title)
            putExtra(Intent.EXTRA_TEXT, content)
        }
        val chooser = Intent.createChooser(sendIntent, if (title.isBlank()) "分享" else title).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(chooser)
    }
}
