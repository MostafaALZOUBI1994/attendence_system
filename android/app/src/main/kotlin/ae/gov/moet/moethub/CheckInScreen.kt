package ae.gov.moet.moethub

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.car.app.CarToast
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CheckInScreen(
    carContext: CarContext,
    private val flutterEngine: FlutterEngine
) : Screen(carContext) {

    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CarHomeService.CHANNEL
    )

    override fun onGetTemplate(): Template {
        val punchIcon = CarIcon.Builder(
            IconCompat.createWithResource(carContext, R.drawable.ic_checkin)
        ).build()

        val punchAction = Action.Builder()
            .setTitle("Punch In")
            .setIcon(punchIcon)
            .setOnClickListener {
                methodChannel.invokeMethod("checkIn", null)
                CarToast.makeText(carContext, "Sending Punch In...", CarToast.LENGTH_SHORT).show()
            }
            .build()

        val row = Row.Builder()
            .setTitle("Check In")
            .addAction(punchAction)
            .build()

        val pane = Pane.Builder().addRow(row).build()

        return PaneTemplate.Builder(pane)
            .setTitle("Attendance")
            .setHeaderAction(Action.APP_ICON)
            .build()
    }
}