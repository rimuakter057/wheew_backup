// ios/Runner/PlateChatVoiceBridge.swift

import Flutter
import UIKit

class PlateChatVoiceBridge: NSObject {
    static let shared = PlateChatVoiceBridge()
    private var channel: FlutterMethodChannel?

    func setup(with controller: FlutterViewController) {
        channel = FlutterMethodChannel(
            name: "com.platechat/voice_intent",
            binaryMessenger: controller.binaryMessenger
        )

        // Flutter থেকে checkPendingIntent call আসলে respond করো
        channel?.setMethodCallHandler { [weak self] call, result in
            if call.method == "checkPendingIntent" {
                self?.checkPendingVoiceIntent()
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
            rawText = "\(contactName) k \(message) bolo"
        } else {
            rawText = "\(contactName) er chat open koro"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sendToFlutter(rawText)
        }
    }
}
