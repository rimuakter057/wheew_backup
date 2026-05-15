import AppIntents

// ══ Intents ══

@available(iOS 16.0, *)
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send a message in PlateChat"
    static var description = IntentDescription("Send a message to a contact in PlateChat")

    @Parameter(title: "Contact name")
    var contactName: String

    @Parameter(title: "Message", default: "Hello")
    var message: String

    func perform() async throws -> some IntentResult {
        let raw = "\(contactName) k \(message) bolo"
        PlateChatVoiceBridge.shared.sendToFlutter(raw)
        return .result()
    }
}

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open a chat in PlateChat"

    @Parameter(title: "Contact name")
    var contactName: String

    func perform() async throws -> some IntentResult {
        let raw = "\(contactName) er chat open koro"
        PlateChatVoiceBridge.shared.sendToFlutter(raw)
        return .result()
    }
}

// ══ Shortcuts ══

@available(iOS 16.4, *)
struct PlateChatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: SendMessageIntent(),
                phrases: [
                    "PlateChat এ \(\.$contactName) k message pathao",
                    "PlateChat এ \(\.$contactName) k \(\.$message) bolo",
                    "Send a message to \(\.$contactName) in \(.applicationName)",
                    "Tell \(\.$contactName) \(\.$message) on \(.applicationName)",
                    "Message \(\.$contactName) on \(.applicationName)",
                    "Manda un messaggio a \(\.$contactName) su \(.applicationName)",
                    "Scrivi a \(\.$contactName) su \(.applicationName)",
                    "Di a \(\.$contactName) \(\.$message) su \(.applicationName)",
                ],
                shortTitle: "Message pathao",
                systemImageName: "message.fill"
            ),
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "PlateChat এ \(\.$contactName) er chat kholo",
                    "Open \(\.$contactName)'s chat in \(.applicationName)",
                    "Apri la chat con \(\.$contactName) su \(.applicationName)",
                    "Go to \(\.$contactName) in \(.applicationName)",
                ],
                shortTitle: "Chat kholo",
                systemImageName: "bubble.left.fill"
            ),
        ]
    }
}
