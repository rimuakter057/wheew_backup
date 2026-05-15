import AppIntents
import Foundation

// ══ Intents ══

@available(iOS 16.0, *)
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send a message in PlateChat"
    static var description = IntentDescription("Send a message to a contact in PlateChat")
    static var openAppWhenRun: Bool = true  // ← app অবশ্যই open হবে

    @Parameter(title: "Contact name")
    var contactName: String

    @Parameter(title: "Message", default: "Hello")
    var message: String

    func perform() async throws -> some IntentResult {
        // UserDefaults এ save করো — app open হলে পড়বে
        let defaults = UserDefaults.standard
        defaults.set(contactName, forKey: "voice_contact_name")
        defaults.set(message, forKey: "voice_message")
        defaults.set("sendMessage", forKey: "voice_action")
        defaults.synchronize()
        return .result()
    }
}

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open a chat in PlateChat"
    static var openAppWhenRun: Bool = true  // ← app অবশ্যই open হবে

    @Parameter(title: "Contact name")
    var contactName: String

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults.standard
        defaults.set(contactName, forKey: "voice_contact_name")
        defaults.set("", forKey: "voice_message")
        defaults.set("openChat", forKey: "voice_action")
        defaults.synchronize()
        return .result()
    }
}

// ══ Shortcuts ══

@available(iOS 16.4, *)
struct PlateChatAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send a message in \(.applicationName)",
                "Message someone on \(.applicationName)",
                "Manda un messaggio su \(.applicationName)",
            ],
            shortTitle: "Send message",
            systemImageName: "message.fill"
        )
        AppShortcut(
            intent: OpenChatIntent(),
            phrases: [
                "Open a chat in \(.applicationName)",
                "Go to a chat in \(.applicationName)",
                "Apri una chat su \(.applicationName)",
            ],
            shortTitle: "Open chat",
            systemImageName: "bubble.left.fill"
        )
    }
}


//import AppIntents
//
//// ══ Intents ══
//
//@available(iOS 16.0, *)
//struct SendMessageIntent: AppIntent {
//    static var title: LocalizedStringResource = "Send a message in PlateChat"
//    static var description = IntentDescription("Send a message to a contact in PlateChat")
//
//    @Parameter(title: "Contact name")
//    var contactName: String
//
//    @Parameter(title: "Message", default: "Hello")
//    var message: String
//
//    func perform() async throws -> some IntentResult {
//        let raw = "\(contactName) k \(message) bolo"
//        PlateChatVoiceBridge.shared.sendToFlutter(raw)
//        return .result()
//    }
//}
//
//@available(iOS 16.0, *)
//struct OpenChatIntent: AppIntent {
//    static var title: LocalizedStringResource = "Open a chat in PlateChat"
//
//    @Parameter(title: "Contact name")
//    var contactName: String
//
//    func perform() async throws -> some IntentResult {
//        let raw = "\(contactName) er chat open koro"
//        PlateChatVoiceBridge.shared.sendToFlutter(raw)
//        return .result()
//    }
//}
//
//// ══ Shortcuts ══
//
//@available(iOS 16.4, *)
//struct PlateChatAppShortcuts: AppShortcutsProvider {
//    @AppShortcutsBuilder
//    static var appShortcuts: [AppShortcut] {
//        AppShortcut(
//            intent: SendMessageIntent(),
//            phrases: [
//                "Send a message in \(.applicationName)",
//                "Message someone on \(.applicationName)",
//                "Manda un messaggio su \(.applicationName)",
//            ],
//            shortTitle: "Send message",
//            systemImageName: "message.fill"
//        )
//        AppShortcut(
//            intent: OpenChatIntent(),
//            phrases: [
//                "Open a chat in \(.applicationName)",
//                "Go to a chat in \(.applicationName)",
//                "Apri una chat su \(.applicationName)",
//            ],
//            shortTitle: "Open chat",
//            systemImageName: "bubble.left.fill"
//        )
//    }
//}
