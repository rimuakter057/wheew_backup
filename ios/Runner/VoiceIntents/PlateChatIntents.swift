import AppIntents

// ══════════════════════════════════════════
// MARK: - Send Message Intent
// ══════════════════════════════════════════

struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send a message in PlateChat"
    static var description = IntentDescription(
        "Send a message to any PlateChat contact using your voice"
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Contact name")
    var contactName: String

    @Parameter(title: "Message")
    var message: String

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults.standard
        defaults.set("sendMessage", forKey: "voice_action")
        defaults.set(contactName,   forKey: "voice_contact_name")
        defaults.set(message,       forKey: "voice_message")
        defaults.synchronize()
        return .result()
    }
}

// ══════════════════════════════════════════
// MARK: - Open Chat Intent
// ══════════════════════════════════════════

struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open a chat in PlateChat"
    static var description = IntentDescription(
        "Open a conversation with a PlateChat contact"
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Contact name")
    var contactName: String

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults.standard
        defaults.set("openChat",  forKey: "voice_action")
        defaults.set(contactName, forKey: "voice_contact_name")
        defaults.synchronize()
        return .result()
    }
}

// ══════════════════════════════════════════
// MARK: - App Shortcuts
// ══════════════════════════════════════════

struct PlateChatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send a message in \(.applicationName)",
                "Message someone in \(.applicationName)",
                "Manda un messaggio in \(.applicationName)",
            ],
            shortTitle: "Send message",
            systemImageName: "message.fill"
        )

        AppShortcut(
            intent: OpenChatIntent(),
            phrases: [
                "Open a chat in \(.applicationName)",
                "Go to a chat in \(.applicationName)",
                "Apri una chat in \(.applicationName)",
            ],
            shortTitle: "Open chat",
            systemImageName: "bubble.left.fill"
        )
    }
}