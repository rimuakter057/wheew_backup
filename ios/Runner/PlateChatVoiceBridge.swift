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
    }

    func sendToFlutter(_ rawText: String) {
        DispatchQueue.main.async {
            self.channel?.invokeMethod("onVoiceIntent", arguments: rawText)
        }
    }
}
