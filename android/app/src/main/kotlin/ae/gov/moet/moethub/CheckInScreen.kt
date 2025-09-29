package ae.gov.moet.moethub

import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.car.app.CarToast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

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

        val greeting = greetingForNow() // "Good morning ☀️", etc.

        val checkInAction = Action.Builder()
            .setTitle("Check-in 🫆") // centered button text (emoji OK)
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

        // MessageTemplate puts the message at the top and actions centered at the bottom.
        return MessageTemplate.Builder(greeting)   // e.g., "Good morning ☀️"
            .setHeaderAction(Action.APP_ICON)
            .addAction(checkInAction)              // centered primary button
            .build()
    }

    private fun greetingForNow(): String {
        val h = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return when (h) {
            in 5..11 -> "Good morning ☀️"
            in 12..16 -> "Good afternoon 🌤️"
            in 17..21 -> "Good evening 🌇"
            else -> "Good night 🌙"
        }
    }
}

