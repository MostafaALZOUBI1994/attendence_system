package ae.gov.moet.moethub

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.CarToast
import androidx.car.app.model.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class RouterScreen(
    carContext: CarContext,
    private val flutterEngine: FlutterEngine
) : Screen(carContext) {

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CarHomeService.CHANNEL
    )

    private enum class State { UNKNOWN, AUTH, MOOD, MAIN }

    private var state: State = State.UNKNOWN
    private val handler = Handler(Looper.getMainLooper())
    private var busy = false
    private var lastCheckInText: String = "--:--"

    // Same moods order/labels as CarPlay
    private val moods = linkedMapOf(
        "Happy" to "😀",
        "Neutral" to "😐",
        "Sad" to "😢",
        "Angry" to "😡"
    )

    init {
        // Probe the Dart isolate first; then sync. Also schedule a couple retries.
        pingThen { sync() }
        resyncSoon(500)
        resyncSoon(1200)
    }

    private fun resyncSoon(delayMs: Long = 250) {
        handler.postDelayed({ pingThen { sync() } }, delayMs)
    }

    // ---------- Template rendering ----------
    override fun onGetTemplate(): Template {
        Log.i("MOETHUB", "RouterScreen.onGetTemplate() state=$state")
        if (state == State.UNKNOWN) resyncSoon(300)

        return when (state) {
            State.AUTH -> authTemplate()
            State.MOOD -> moodTemplate()
            State.MAIN -> mainTemplate()
            else       -> loadingTemplate()
        }
    }

    private fun loadingTemplate(): Template =
        MessageTemplate.Builder("Loading…")
            .setHeaderAction(Action.APP_ICON)
            .build()

    private fun authTemplate(): Template =
        MessageTemplate.Builder("Open the app on your phone and sign in.")
            .setHeaderAction(Action.APP_ICON)
            .setTitle("Sign in required")
            .build()

    private fun moodTemplate(): Template {
        val listBuilder = ItemList.Builder()
        moods.forEach { (label, emoji) ->
            listBuilder.addItem(
                Row.Builder()
                    .setTitle("$emoji $label")
                    .setOnClickListener {
                        if (busy) return@setOnClickListener
                        busy = true
                        carToast("Saving mood…")
                        invokeBool("checkInWithMood", mapOf("mood" to label)) { ok ->
                            carToast(if (ok == true) "Mood saved" else "Failed to save mood")
                            busy = false
                            sync()
                        }
                    }
                    .build()
            )
        }

        return ListTemplate.Builder()
            .setHeaderAction(Action.APP_ICON)
            .setTitle("Select Mood")
            .setSingleList(listBuilder.build())
            .build()
    }

    private fun mainTemplate(): Template {
        val checkInAction = Action.Builder()
            .setTitle("Check-in 🫆") // centered primary action
            .setOnClickListener {
                if (busy) return@setOnClickListener
                busy = true
                carToast("Checking in…")
                invokeBool("checkIn", null) { ok ->
                    carToast(if (ok == true) "Checked in" else "Check-in failed")
                    busy = false
                    sync() // refresh "Last Check-in"
                }
            }
            .build()

        val msg = "Last Check-in 🫆: $lastCheckInText"
        return MessageTemplate.Builder(msg)
            .setHeaderAction(Action.APP_ICON)
            .addAction(checkInAction)
            .build()
    }

    // ---------- State sync from Dart ----------
    private fun sync() {
        invokeBool("isLoggedIn", null) { loggedIn ->
            if (loggedIn == null) {
                state = State.UNKNOWN
                invalidate()
                resyncSoon(300)
                return@invokeBool
            }
            if (!loggedIn) {
                state = State.AUTH
                invalidate()
                return@invokeBool
            }

            invokeBool("needMoodToday", null) { needMood ->
                if (needMood == null) {
                    state = State.UNKNOWN
                    invalidate()
                    resyncSoon(300)
                    return@invokeBool
                }
                if (needMood) {
                    state = State.MOOD
                    invalidate()
                } else {
                    fetchLastCheckIn {
                        state = State.MAIN
                        invalidate()
                    }
                }
            }
        }
    }

    private fun fetchLastCheckIn(done: () -> Unit) {
        channel.invokeMethod("getCheckInsMillis", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                try {
                    val list = (result as? List<*>)?.mapNotNull { (it as? Number)?.toLong() } ?: emptyList()
                    val lastMillis = list.maxOrNull()
                    lastCheckInText = lastMillis?.let { formatTime(it) } ?: "--:--"
                } catch (_: Throwable) {
                    lastCheckInText = "--:--"
                }
                done()
            }
            override fun error(code: String, message: String?, details: Any?) {
                lastCheckInText = "--:--"; done()
            }
            override fun notImplemented() {
                lastCheckInText = "--:--"; done()
            }
        })
    }

    // ---------- Helpers ----------
    private fun pingThen(onReady: () -> Unit) {
        channel.invokeMethod("ping", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result == true) onReady() else resyncSoon(200)
            }
            override fun error(code: String, message: String?, details: Any?) {
                resyncSoon(200)
            }
            override fun notImplemented() {
                resyncSoon(200)
            }
        })
    }

    private fun invokeBool(method: String, args: Any?, cb: (Boolean?) -> Unit) {
        channel.invokeMethod(method, args, object : MethodChannel.Result {
            override fun success(result: Any?) { cb((result as? Boolean) == true) }
            override fun error(code: String, message: String?, details: Any?) {
                Log.w("MOETHUB", "invokeBool($method) error: $code $message"); cb(false)
            }
            override fun notImplemented() {
                Log.w("MOETHUB", "invokeBool($method) notImplemented"); cb(null)
            }
        })
    }

    private fun formatTime(millis: Long): String {
        val fmt = SimpleDateFormat("hh:mm a", Locale.getDefault())
        return fmt.format(Date(millis))
    }

    private fun carToast(msg: String) {
        CarToast.makeText(carContext, msg, CarToast.LENGTH_SHORT).show()
    }
}