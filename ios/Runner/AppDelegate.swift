import Flutter
import UIKit
import AppIntents
import GoogleMaps  // ← Add this line

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBatgvXrVXxNagCM5RDmd6aab0G-Z5DNdQ")

    let controller = window?.rootViewController as! FlutterViewController
    PlateChatVoiceBridge.shared.setup(with: controller)

    if #available(iOS 16.4, *) {
      PlateChatAppShortcuts.updateAppShortcutParameters()
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}