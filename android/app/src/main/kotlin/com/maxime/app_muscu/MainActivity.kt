package com.maxime.app_muscu

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity plutôt que FlutterActivity (D36) : exigé par le
// paquet `health` sur Android 14+ pour `registerForActivityResult` lors de
// la demande d'autorisation Health Connect.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Canal « appmuscu/screen » (lib/core/platform/screen_awake.dart) :
        // garder l'écran allumé pendant une séance (ST-04).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "appmuscu/screen")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "keepOn" -> {
                        val flag = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        if (call.arguments == true) {
                            window.addFlags(flag)
                        } else {
                            window.clearFlags(flag)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
