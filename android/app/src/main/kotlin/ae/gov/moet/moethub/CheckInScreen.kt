package ae.gov.moet.moethub

import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.car.app.CarToast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CheckInScreen(
    carContext: CarContext,
    private val flutterEngine: FlutterEngine
) : Screen(carContext) {

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CarHomeService.CHANNEL // "ae.gov.moet.moethub/car"
    )

    override fun onGetTemplate(): Template {
        Log.i("MOETHUB", "CheckInScreen.onGetTemplate()")

        return try {
            // Template-level action (ActionStrip) – allowed in PaneTemplate
            val checkInAction = Action.Builder()
                .setTitle("Check-in")
                .setOnClickListener {
                    CarToast.makeText(carContext, "Checking in…", CarToast.LENGTH_SHORT).show()
                    channel.invokeMethod("checkIn", null, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val ok = (result as? Boolean) == true
                            val msg = if (ok) "Checked-in!" else "Check-in failed"
                            CarToast.makeText(carContext, msg, CarToast.LENGTH_SHORT).show()
                        }
                        override fun error(code: String, message: String?, details: Any?) {
                            CarToast.makeText(carContext, "Check-in failed", CarToast.LENGTH_SHORT).show()
                        }
                        override fun notImplemented() {
                            CarToast.makeText(carContext, "Check-in unavailable", CarToast.LENGTH_SHORT).show()
                        }
                    })
                }
                .build()

            val row = Row.Builder()
                .setTitle("Tap Check-in in the bar")
                .build()

            val pane = Pane.Builder()
                .addRow(row)                  // ✅ no Row actions inside Pane
                .build()

            PaneTemplate.Builder(pane)
                .setTitle("Attendance")
                .setHeaderAction(Action.APP_ICON)
                .setActionStrip(               // ✅ put actions here
                    ActionStrip.Builder().addAction(checkInAction).build()
                )
                .build()

        } catch (t: Throwable) {
            Log.e("MOETHUB", "Template build failed", t)
            MessageTemplate.Builder("Error loading screen")
                .setHeaderAction(Action.APP_ICON)
                .addAction(Action.Builder().setTitle("Retry").setOnClickListener { invalidate() }.build())
                .build()
        }
    }
}
