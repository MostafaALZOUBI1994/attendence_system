package com.example.attendence_system

import android.content.Intent
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class CarHomeService : CarAppService() {
    companion object {
        const val CHANNEL = "com.example.attendence_system/car"
    }

    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()
        // 1) Spin up a headless FlutterEngine
        flutterEngine = FlutterEngine(this).apply {
            // Register ALL your plugins (so MethodChannel on this engine works)
            GeneratedPluginRegistrant.registerWith(this)
            // Start running Dart code
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
        }
    }

    // 2) Allow DHU as a valid host (dev mode)
    override fun createHostValidator(): HostValidator =
        HostValidator.ALLOW_ALL_HOSTS_VALIDATOR

    // 3) Launch your single-screen session
    override fun onCreateSession(): Session = object : Session() {
        override fun onCreateScreen(intent: Intent) =
            CheckInScreen(carContext, flutterEngine)
    }
}
