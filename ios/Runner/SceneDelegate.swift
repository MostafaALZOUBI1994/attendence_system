import UIKit
import Flutter

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = scene as? UIWindowScene,
          let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }

    // Use the same, already-running engine
    let engine = appDelegate.flutterEngine

    window = UIWindow(windowScene: windowScene)
    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)

    // Optional: you can comment this out if you suspect splash is misbehaving
    controller.loadDefaultSplashScreenView()

    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
}
