package com.example.attendence_system

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.core.graphics.drawable.IconCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class CheckInScreen(
    carContext: CarContext,
    private val flutterEngine: FlutterEngine
) : Screen(carContext) {

    override fun onGetTemplate(): Template {
        // 1. Create a CarIcon from your drawable resource
        val punchIcon = CarIcon.Builder(
            IconCompat.createWithResource(carContext, R.drawable.ic_checkin)
        ).build()  // :contentReference[oaicite:0]{index=0}

        // 2. Build your Action with title, icon, and click handler
        val punchAction = Action.Builder()
            .setIcon(punchIcon)           // <- mandatory for custom actions
            .setTitle("Punch In")
            .setOnClickListener {
                MethodChannel(
                    flutterEngine.dartExecutor.binaryMessenger,
                    CarHomeService.CHANNEL
                ).invokeMethod("checkIn", null)
            }
            .build()

        // 3. Layout your row/pane as before
        val row = Row.Builder()
            .setTitle("Check In")
            .addAction(punchAction)
            .build()

        val pane = Pane.Builder()
            .addRow(row)
            .build()

        return PaneTemplate.Builder(pane)
            .setTitle("Attendance")
            .setHeaderAction(Action.APP_ICON)
            .build()
    }
}
