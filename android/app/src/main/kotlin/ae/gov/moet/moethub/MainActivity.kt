package ae.gov.moet.moethub

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var appEventsChannel: MethodChannel? = null

    // Listen for broadcasts from the car UI (Android Auto) telling the phone UI to refresh.
    private val appResyncReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Call into Dart: notify blocs to refresh (we handle this in CarChannel._app handler)
            appEventsChannel?.invokeMethod("appResync", null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Phone -> Car: ask RouterScreen to sync (broadcast ACTION_RESYNC)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ae.gov.moet.moethub/car_ui")
            .setMethodCallHandler { call, result ->
                if (call.method == "resyncCar") {
                    applicationContext.sendBroadcast(Intent(RouterScreen.ACTION_RESYNC))
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }

        // Car -> Phone: native can invoke Dart (we’ll send "appResync" here)
        appEventsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ae.gov.moet.moethub/app"
        )
    }

    override fun onResume() {
        super.onResume()
        // Register receiver while activity is visible
        registerReceiver(
            appResyncReceiver,
            IntentFilter(RouterScreen.ACTION_APP_RESYNC)
        )
    }

    override fun onPause() {
        try { unregisterReceiver(appResyncReceiver) } catch (_: Throwable) {}
        super.onPause()
    }
}
