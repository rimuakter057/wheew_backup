import Flutter
import UIKit
import AppIntents
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    }

    let controller = window?.rootViewController as! FlutterViewController
    PlateChatVoiceBridge.shared.setup(with: controller)

    if #available(iOS 16.4, *) {
      PlateChatAppShortcuts.updateAppShortcutParameters()
    }

    // ── Allow foreground notification banners on iOS ──
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}