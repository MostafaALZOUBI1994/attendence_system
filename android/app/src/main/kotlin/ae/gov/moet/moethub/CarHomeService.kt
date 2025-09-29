package ae.gov.moet.moethub

import android.content.Intent
import android.content.pm.ApplicationInfo
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class CarHomeService : CarAppService() {

    companion object { const val CHANNEL = "ae.gov.moet.moethub/car" }

    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // Ensure the Flutter loader is initialized before creating the engine.
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(this)
            loader.ensureInitializationComplete(this, null)
        }

        flutterEngine = FlutterEngine(this).apply {
            // Register plugins used by the car entrypoint (if any).
            GeneratedPluginRegistrant.registerWith(this)

            // Run the named Dart entrypoint that serves Android Auto.
            val appBundlePath = loader.findAppBundlePath()
            val entrypoint = DartExecutor.DartEntrypoint(appBundlePath, "carEntryPoint")
            dartExecutor.executeDartEntrypoint(entrypoint)
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
        return object : Session() {
            override fun onCreateScreen(intent: Intent) =
                RouterScreen(carContext, flutterEngine)
        }
    }
}