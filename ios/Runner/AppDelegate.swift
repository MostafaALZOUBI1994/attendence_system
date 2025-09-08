import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {

  // Keep a single, long-lived engine owned by AppDelegate
  lazy var flutterEngine = FlutterEngine(name: "shared_engine",
                                         project: nil,
                                         allowHeadlessExecution: true)

  override func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Make native Firebase ready before Dart touches it
    FirebaseApp.configure()

    // Start the engine once
    // (If you might call this again elsewhere, guard against duplicates.)
    flutterEngine.run()

    // Register all plugins on THIS engine (not on self)
    GeneratedPluginRegistrant.register(with: flutterEngine)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
