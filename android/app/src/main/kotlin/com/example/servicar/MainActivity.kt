package com.example.servicar

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val dialerChannelName = "servicar/dialer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, dialerChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openDialer" -> {
                        val number = call.argument<String>("number")
                        if (number.isNullOrBlank()) {
                            result.error("INVALID_NUMBER", "Phone number is empty", null)
                        } else {
                            try {
                                startActivity(
                                    Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number"))
                                )
                                result.success(null)
                            } catch (e: Exception) {
                                result.error(
                                    "DIALER_UNAVAILABLE",
                                    e.message ?: "No dialer available",
                                    null,
                                )
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
