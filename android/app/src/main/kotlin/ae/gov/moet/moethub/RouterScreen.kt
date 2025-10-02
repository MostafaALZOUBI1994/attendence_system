package ae.gov.moet.moethub

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.CarToast
import androidx.car.app.model.*
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class RouterScreen(
    carContext: CarContext,
    private val flutterEngine: FlutterEngine
) : Screen(carContext) {

    companion object {
        const val ACTION_RESYNC = "ae.gov.moet.moethub.RESYNC"
        const val ACTION_APP_RESYNC = "ae.gov.moet.moethub.APP_RESYNC"
        private const val TAG = "MOETHUB"
        private const val CHANNEL = "ae.gov.moet.moethub/car"

    }

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CarHomeService.CHANNEL
    )

    private enum class State { UNKNOWN, AUTH, MOOD, MAIN }

    private var state: State = State.UNKNOWN
    private val handler = Handler(Looper.getMainLooper())
    private var busy = false
    private var lastCheckInText: String = "--:--"

    private fun notifyPhoneUi() {
        val i = Intent(ACTION_APP_RESYNC)
        carContext.sendBroadcast(i)
        Log.i(TAG, "Broadcasted APP_RESYNC to phone")
    }

    // Same moods order/labels as CarPlay
    private val moods = linkedMapOf(
        "Happy" to "😀",
        "Neutral" to "😐",
        "Sad" to "😢",
        "Angry" to "😡"
    )

    // Receiver to trigger immediate resync from the phone process
    private val resyncReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.i(TAG, "Received RESYNC from phone")
            sync()
        }
    }

    init {
        // 1) Kick the Dart isolate and try a couple of times in case it’s still warming up
        pingThen { sync() }
        resyncSoon(500)
        resyncSoon(1200)

        // 2) Listen for resync broadcasts from MainActivity (phone side)
        carContext.registerReceiver(resyncReceiver, IntentFilter(ACTION_RESYNC))

        // 3) Use Screen's lifecycle (NOT carContext.lifecycle)
        lifecycle.addObserver(LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_RESUME -> resyncSoon(50)
                Lifecycle.Event.ON_DESTROY -> {
                    try { carContext.unregisterReceiver(resyncReceiver) } catch (_: Throwable) {}
                }
                else -> Unit
            }
        })
    }

    private fun resyncSoon(delayMs: Long = 250) {
        handler.postDelayed({ pingThen { sync() } }, delayMs)
    }

    // ---------------- Template routing ----------------
    override fun onGetTemplate(): Template {
        Log.i(TAG, "onGetTemplate() state=$state")
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
        val list = ItemList.Builder()
        moods.forEach { (label, emoji) ->
            list.addItem(
                Row.Builder()
                    .setTitle("$emoji $label")
                    .setOnClickListener {
                        if (busy) return@setOnClickListener
                        busy = true
                        carToast("Saving mood…")
                        invokeBool("checkInWithMood", mapOf("mood" to label)) { ok ->
                            carToast(if (ok == true) "Mood saved" else "Failed to save mood")
                            busy = false
                            if (ok == true) notifyPhoneUi()
                            sync()
                        }
                    }
                    .build()
            )
        }
        return ListTemplate.Builder()
            .setHeaderAction(Action.APP_ICON)
            .setTitle("Select Mood")
            .setSingleList(list.build())
            .build()
    }

    private fun mainTemplate(): Template {
        val action = Action.Builder()
            .setTitle("Check-in 🫆")
            .setOnClickListener {
                if (busy) return@setOnClickListener
                busy = true
                carToast("Checking in…")
                invokeBool("checkIn", null) { ok ->
                    carToast(if (ok == true) "Checked in" else "Check-in failed")
                    busy = false
                    if (ok == true) notifyPhoneUi()   // <<< add this
                    sync()
                }
            }
            .build()

        val msg = "Last Check-in 🫆: $lastCheckInText"
        return MessageTemplate.Builder(msg)
            .setHeaderAction(Action.APP_ICON)
            .addAction(action)
            .build()
    }

    // ---------------- State sync ----------------
    private fun sync() {
        invokeBool("isLoggedIn", null) { loggedIn ->
            if (loggedIn != true) {
                state = State.AUTH
                invalidate()
                return@invokeBool
            }
            invokeBool("needMoodToday", null) { needMood ->
                if (needMood == true) {
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

    // ---------------- Channel helpers ----------------
    private fun pingThen(onReady: () -> Unit) {
        channel.invokeMethod("ping", null, object : MethodChannel.Result {
            override fun success(result: Any?) { if (result == true) onReady() else resyncSoon(200) }
            override fun error(code: String, message: String?, details: Any?) { resyncSoon(200) }
            override fun notImplemented() { resyncSoon(200) }
        })
    }

    private fun invokeBool(method: String, args: Any?, cb: (Boolean?) -> Unit) {
        channel.invokeMethod(method, args, object : MethodChannel.Result {
            override fun success(result: Any?) { cb((result as? Boolean) == true) }
            override fun error(code: String, message: String?, details: Any?) {
                Log.w(TAG, "invokeBool($method) error: $code $message"); cb(false)
            }
            override fun notImplemented() {
                Log.w(TAG, "invokeBool($method) notImplemented"); cb(null)
            }
        })
    }

    // ---------------- Misc ----------------
    private fun formatTime(millis: Long): String =
        SimpleDateFormat("hh:mm a", Locale.getDefault()).format(Date(millis))

    private fun carToast(msg: String) {
        CarToast.makeText(carContext, msg, CarToast.LENGTH_SHORT).show()
    }
}
