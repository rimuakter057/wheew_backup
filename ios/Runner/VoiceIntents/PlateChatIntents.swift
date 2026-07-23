import AppIntents

// ══════════════════════════════════════════
// MARK: - Send Message Intent
// ══════════════════════════════════════════

@available(iOS 16.0, *)
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
        // Save to UserDefaults — Flutter reads this when app opens
        let defaults = UserDefaults.standard
        defaults.set("sendMessage",  forKey: "voice_action")
        defaults.set(contactName,    forKey: "voice_contact_name")
        defaults.set(message,        forKey: "voice_message")
        defaults.synchronize()
        return .result()
    }
}

// ══════════════════════════════════════════
// MARK: - Open Chat Intent
// ══════════════════════════════════════════

@available(iOS 16.0, *)
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
// MARK: - App Shortcuts (Siri phrases)
// ══════════════════════════════════════════

@available(iOS 16.4, *)
struct PlateChatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            // ── Send Message ──────────────────────────
            AppShortcut(
                intent: SendMessageIntent(),
                phrases: [
                    // English
                    "Send \(\.$message) to \(\.$contactName) in \(.applicationName)",
                    "Tell \(\.$contactName) \(\.$message) on \(.applicationName)",
                    "Message \(\.$contactName) \(\.$message) on \(.applicationName)",
                    "Text \(\.$contactName) \(\.$message) on \(.applicationName)",
                    // Italian
                    "Manda \(\.$message) a \(\.$contactName) su \(.applicationName)",
                    "Scrivi \(\.$message) a \(\.$contactName) su \(.applicationName)",
                    "Di a \(\.$contactName) \(\.$message) su \(.applicationName)",
                    "Invia \(\.$message) a \(\.$contactName) su \(.applicationName)",
                ],
                shortTitle: "Send message",
                systemImageName: "message.fill"
            ),

            // ── Open Chat ─────────────────────────────
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    // English
                    "Open chat with \(\.$contactName) in \(.applicationName)",
                    "Go to \(\.$contactName) in \(.applicationName)",
                    "Show my messages with \(\.$contactName) on \(.applicationName)",
                    // Italian
                    "Apri la chat con \(\.$contactName) su \(.applicationName)",
                    "Vai da \(\.$contactName) su \(.applicationName)",
                    "Mostra i messaggi con \(\.$contactName) su \(.applicationName)",
                ],
                shortTitle: "Open chat",
                systemImageName: "bubble.left.fill"
            ),
        ]
    }
}