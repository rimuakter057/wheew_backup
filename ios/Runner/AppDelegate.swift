import Flutter
import UIKit
import AppIntents
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBatgvXrVXxNagCM5RDmd6aab0G-Z5DNdQ")
        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        PlateChatVoiceBridge.shared.setup(with: controller)

        PlateChatAppShortcuts.updateAppShortcutParameters()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ── URL Scheme handler ──
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "platechat", url.host == "voice" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let action = components?.queryItems?.first(where: { $0.name == "action" })?.value ?? ""
            let data   = components?.queryItems?.first(where: { $0.name == "data"   })?.value ?? ""

            let rawText: String
            if action == "sendMessage" {
                let parts = data.components(separatedBy: "||||")
                let name  = parts.first ?? ""
                let msg   = parts.count > 1 ? parts[1] : "Hello"
                rawText   = "tell \(name) \(msg)"
            } else {
                rawText = "open chat with \(data)"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                PlateChatVoiceBridge.shared.sendToFlutter(rawText)
            }
            return true
        }
        return super.application(app, open: url, options: options)
    }
}