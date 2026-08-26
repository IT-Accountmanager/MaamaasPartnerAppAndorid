////package com.example.maamaaspartner
////
////import io.flutter.embedding.android.FlutterActivity
////
////class MainActivity : FlutterActivity()
//
//
//
//package com.maamaas.partner
//
//import android.annotation.SuppressLint
//import android.content.Intent
//import android.net.Uri
//import android.os.Bundle
//import android.os.PowerManager
//import android.provider.Settings
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity: FlutterActivity() {
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        requestIgnoreBatteryOptimizations()
//    }
//
//    @SuppressLint("BatteryLife")
//    private fun requestIgnoreBatteryOptimizations() {
//        try {
//            val pm = getSystemService(POWER_SERVICE) as PowerManager
//            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
//                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
//                intent.data = Uri.parse("package:$packageName")
//                startActivity(intent)
//            }
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
//    }
//}


package com.maamaas.partner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.maamaas.partner/ring"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startRing" -> {
                        OrderRingService.start(this)
                        result.success(true)
                    }
                    "stopRing" -> {
                        OrderRingService.stop(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}