// ios/Runner/PlateChatVoiceBridge.swift

import Flutter
import UIKit
import Intents
import IntentsUI

class PlateChatVoiceBridge: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    static let shared = PlateChatVoiceBridge()
    private var channel: FlutterMethodChannel?
    private weak var flutterViewController: FlutterViewController?

    func setup(with controller: FlutterViewController) {
        self.flutterViewController = controller
        channel = FlutterMethodChannel(
            name: "com.platechat/voice_intent",
            binaryMessenger: controller.binaryMessenger
        )

        // Flutter থেকে call আসলে respond করো
        channel?.setMethodCallHandler { [weak self] call, result in
            if call.method == "checkPendingIntent" {
                self?.checkPendingVoiceIntent()
                result(nil)
            } else if call.method == "triggerSiriShortcutPrompt" {
                self?.presentSiriShortcutPrompt()
                result(nil)
            }
        }
    }

    func sendToFlutter(_ rawText: String) {
        DispatchQueue.main.async {
            self.channel?.invokeMethod("onVoiceIntent", arguments: rawText)
        }
    }

    func checkPendingVoiceIntent() {
        // group UserDefaults এর বদলে standard use করো
        let defaults = UserDefaults.standard
        
        guard let action = defaults.string(forKey: "voice_action"),
              !action.isEmpty else { return }

        let contactName = defaults.string(forKey: "voice_contact_name") ?? ""
        let message = defaults.string(forKey: "voice_message") ?? ""

        defaults.removeObject(forKey: "voice_action")
        defaults.removeObject(forKey: "voice_contact_name")
        defaults.removeObject(forKey: "voice_message")
        defaults.synchronize()

        let rawText: String
        if action == "sendMessage" {
            rawText = "tell \(contactName) \(message)"
        } else {
            rawText = "open chat with \(contactName)"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendToFlutter(rawText)
        }
    }

    func presentSiriShortcutPrompt() {
        if #available(iOS 12.0, *) {
            let userActivity = NSUserActivity(activityType: "com.platechat.sendMessage")
            userActivity.title = "Send a message in PlateChat"
            userActivity.suggestedInvocationPhrase = "Send a message in PlateChat"
            let shortcut = INShortcut(userActivity: userActivity)
            
            DispatchQueue.main.async {
                guard let rootVC = self.flutterViewController else { return }
                let addVC = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                addVC.delegate = self
                rootVC.present(addVC, animated: true, completion: nil)
            }
        }
    }

    // ══ INUIAddVoiceShortcutViewControllerDelegate ══
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
