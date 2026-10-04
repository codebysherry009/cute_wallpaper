package pro.arbaglobal.cutewallpaperskawaii

import android.Manifest
import android.app.WallpaperManager
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "com.brightapps.cutewall/native"
    private val executor = Executors.newSingleThreadExecutor()
    private val storagePermissionCode = 4201

    // Holds a saveToGallery call while we wait for the storage permission
    // dialog result on Android 9 and below.
    private var pendingSave: Triple<ByteArray, String, String>? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val target = call.argument<Int>("target") ?: 3
                        if (bytes == null) {
                            result.error("NO_DATA", "Image data missing", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                setWallpaper(bytes, target)
                                runOnUiThread { result.success(true) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("SET_FAILED", e.message ?: "Could not set wallpaper", null)
                                }
                            }
                        }
                    }
                    "saveToGallery" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val name = call.argument<String>("name") ?: "CuteWall.jpg"
                        val mime = call.argument<String>("mime") ?: "image/jpeg"
                        if (bytes == null) {
                            result.error("NO_DATA", "Image data missing", null)
                            return@setMethodCallHandler
                        }
                        requestSaveToGallery(bytes, name, mime, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestSaveToGallery(
        bytes: ByteArray,
        name: String,
        mime: String,
        result: MethodChannel.Result,
    ) {
        // Android 10+ (scoped storage) writes through MediaStore and needs no
        // storage permission at all.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            runSave(bytes, name, mime, result)
            return
        }

        // Android 9 and below: WRITE_EXTERNAL_STORAGE must be granted first.
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
        ) == PackageManager.PERMISSION_GRANTED

        if (granted) {
            runSave(bytes, name, mime, result)
        } else {
            pendingSave = Triple(bytes, name, mime)
            pendingResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                storagePermissionCode,
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != storagePermissionCode) return

        val save = pendingSave
        val result = pendingResult
        pendingSave = null
        pendingResult = null

        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (save == null || result == null) return
        if (granted) {
            runSave(save.first, save.second, save.third, result)
        } else {
            result.error("PERMISSION_DENIED", "Storage permission is needed to save wallpapers", null)
        }
    }

    private fun runSave(bytes: ByteArray, name: String, mime: String, result: MethodChannel.Result) {
        executor.execute {
            try {
                saveToGallery(bytes, name, mime)
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread {
                    result.error("SAVE_FAILED", e.message ?: "Could not save image", null)
                }
            }
        }
    }

    private fun setWallpaper(bytes: ByteArray, target: Int) {
        val manager = WallpaperManager.getInstance(applicationContext)
        val stream = ByteArrayInputStream(bytes)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val flags = when (target) {
                1 -> WallpaperManager.FLAG_SYSTEM
                2 -> WallpaperManager.FLAG_LOCK
                else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
            }
            manager.setStream(stream, null, true, flags)
        } else {
            manager.setStream(stream)
        }
    }

    private fun saveToGallery(bytes: ByteArray, name: String, mime: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, name)
                put(MediaStore.Images.Media.MIME_TYPE, mime)
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CuteWall")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Could not create file")
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("Could not write file")
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } else {
            // Legacy path for Android 9 and below (needs WRITE_EXTERNAL_STORAGE,
            // requested in requestSaveToGallery before this runs).
            @Suppress("DEPRECATION")
            val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val dir = File(picturesDir, "CuteWall")
            if (!dir.exists() && !dir.mkdirs()) {
                throw IllegalStateException("Could not create folder")
            }
            val file = File(dir, name)
            FileOutputStream(file).use { it.write(bytes) }
            MediaScannerConnection.scanFile(applicationContext, arrayOf(file.absolutePath), arrayOf(mime), null)
        }
    }
}
