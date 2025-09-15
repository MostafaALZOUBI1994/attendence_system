import UIKit
import Flutter
import FirebaseCore


let flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)

@main
@objc class AppDelegate: FlutterAppDelegate {


  override func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      flutterEngine.run()
    // Make native Firebase ready before Dart touches it
    FirebaseApp.configure()

    // Start the engine once
    // (If you might call this again elsewhere, guard against duplicates.)
 

    // Register all plugins on THIS engine (not on self)
    GeneratedPluginRegistrant.register(with: flutterEngine)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
