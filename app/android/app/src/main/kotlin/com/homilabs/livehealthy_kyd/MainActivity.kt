package com.homilabs.livehealthy_kyd

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * "Track it" support: opens a sibling LiveHealthy app when it's installed.
 * Only the package names listed in the manifest's <queries> block are
 * visible (Android 11+), and the Dart side only ever asks for those two.
 */
class MainActivity : FlutterActivity() {
    private val allowedPackages = setOf(
        "com.homilabs.livehealthy_vitals",
        "com.homilabs.medicine_reminder",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "livehealthy_kyd/apps")
            .setMethodCallHandler { call, result ->
                val pkg = call.argument<String>("package")
                if (pkg == null || pkg !in allowedPackages) {
                    result.error("bad_package", "Package not allowed", null)
                    return@setMethodCallHandler
                }
                val launch = packageManager.getLaunchIntentForPackage(pkg)
                when (call.method) {
                    "isInstalled" -> result.success(launch != null)
                    "open" -> {
                        if (launch == null) {
                            result.success(false)
                        } else {
                            startActivity(launch)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
