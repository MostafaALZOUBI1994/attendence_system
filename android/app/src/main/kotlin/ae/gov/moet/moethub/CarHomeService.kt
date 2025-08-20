package ae.gov.moet.moethub

import android.content.Intent
import android.content.pm.ApplicationInfo
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.FlutterInjector

class CarHomeService : CarAppService() {

    companion object { const val CHANNEL = "ae.gov.moet.moethub/car" }

    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        android.util.Log.i("MOETHUB", "CarHomeService.onCreate")
        super.onCreate()
        flutterEngine = FlutterEngine(this).apply {
            // Register plugins for this engine
            GeneratedPluginRegistrant.registerWith(this)

            // Run the **named** Dart entrypoint (so we don't boot the full app here)
            val appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath()
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(appBundlePath, "carEntryPoint")
            )
        }
    }

    override fun onDestroy() {
        try { flutterEngine.destroy() } catch (_: Throwable) {}
        super.onDestroy()
    }

    override fun createHostValidator(): HostValidator {
        return if ((applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
        } else {
            HostValidator.Builder(applicationContext)
                .addAllowedHosts(R.array.hosts_allowlist_sample)
                .build()
        }
    }

    override fun onCreateSession(): Session {
        android.util.Log.i("MOETHUB", "CarHomeService.onCreateSession")
        return object: Session() {
            override fun onCreateScreen(intent: Intent) =
                CheckInScreen(carContext, flutterEngine)
        }
    }
}
