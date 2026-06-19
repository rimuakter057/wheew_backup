// lib/voice/intent_parser.dart

enum VoiceAction { openApp, openChat, sendMessage, findUser, triggerVoiceMode, unknown }

enum VoiceLang { english, italian, unknown }

class ParsedIntent {
  final VoiceAction action;
  final String? targetUser;
  final String? message;
  final VoiceLang lang;
  final String rawInput;
  final double confidence;

  const ParsedIntent({
    required this.action,
    required this.lang,
    required this.rawInput,
    this.targetUser,
    this.message,
    this.confidence = 1.0,
  });

  bool get isValid => action != VoiceAction.unknown;

  @override
  String toString() =>
      'ParsedIntent(action:$action, user:$targetUser, msg:$message, lang:$lang)';
}

class _IntentPattern {
  final RegExp regex;
  final VoiceAction action;
  final VoiceLang lang;
  final int nameGroup;
  final int msgGroup;

  const _IntentPattern({
    required this.regex,
    required this.action,
    required this.lang,
    this.nameGroup = 0,
    this.msgGroup = 0,
  });
}

class IntentParser {
  IntentParser._();
  static final IntentParser instance = IntentParser._();

  static const _defaultMsg = {
    VoiceLang.english: 'Hello',
    VoiceLang.italian: 'Ciao',
  };

  static _IntentPattern _p(
    String pattern,
    VoiceAction action,
    VoiceLang lang, {
    int nameG = 0,
    int msgG = 0,
  }) {
    return _IntentPattern(
      regex: RegExp(pattern, caseSensitive: false, unicode: true),
      action: action,
      lang: lang,
      nameGroup: nameG,
      msgGroup: msgG,
    );
  }

  static final List<_IntentPattern> _patterns = [
    // ══ ENGLISH — sendMessage ══
    _p(
      r"tell\s+(\w+)\s+(?:that\s+)?(.+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"say\s+(.+?)\s+to\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 2,
      msgG: 1,
    ),
    _p(
      r"send\s+(?:a\s+message\s+to|hello\s+to|hi\s+to)\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"send\s+(\w+)\s+(?:a\s+message|the\s+message\s+(.+?))",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"text\s+(\w+)\s+(.+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"write\s+(.+?)\s+to\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 2,
      msgG: 1,
    ),
    _p(
      r"message\s+(\w+)\s+saying\s+(.+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"message\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"let\s+(\w+)\s+know\s+(.+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"ping\s+(\w+)(?:\s+with\s+(.+))?",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"drop\s+(\w+)\s+a\s+message\s+saying\s+(.+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"say\s+(?:hi|hello)\s+to\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.english,
      nameG: 1,
    ),

    // ══ ENGLISH — openChat ══
    _p(
      r"open\s+(?:(?:my\s+)?chat\s+with|the\s+chat\s+with)\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"go\s+to\s+(\w+)(?:'s\s+chat|\s+in\s+platechat)?",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"show\s+(?:my\s+)?(?:conversation|messages)\s+with\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"open\s+(\w+)(?:'s)?\s+(?:inbox|chat|messages)",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"(?:take\s+me\s+to|open)\s+(\w+)\s+(?:in\s+platechat|chat)",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"find\s+my\s+messages\s+with\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.english,
      nameG: 1,
    ),

    // ══ ENGLISH — findUser ══
    _p(
      r"find\s+(\w+)(?:\s+in\s+platechat)?",
      VoiceAction.findUser,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"search\s+for\s+(\w+)",
      VoiceAction.findUser,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(r"look\s+up\s+(\w+)", VoiceAction.findUser, VoiceLang.english, nameG: 1),
    _p(
      r"is\s+(\w+)\s+on\s+platechat",
      VoiceAction.findUser,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(
      r"show\s+me\s+(\w+)(?:'s)?\s+profile",
      VoiceAction.findUser,
      VoiceLang.english,
      nameG: 1,
    ),
    _p(r"locate\s+(\w+)", VoiceAction.findUser, VoiceLang.english, nameG: 1),

    // ══ ENGLISH — openApp ══
    _p(
      r"(?:open|launch|start|bring\s+up|show)\s+platechat",
      VoiceAction.openApp,
      VoiceLang.english,
    ),
    _p(
      r"(?:go\s+to|open)\s+(?:the\s+)?chat\s+app",
      VoiceAction.openApp,
      VoiceLang.english,
    ),
    _p(r"open\s+my\s+chats", VoiceAction.openApp, VoiceLang.english),

    // ══ ITALIAN — sendMessage ══
    _p(
      r"di['\s]+(?:a\s+)?(\w+)\s+(?:che\s+)?(.+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"manda\s+(.+?)\s+a\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 2,
      msgG: 1,
    ),
    _p(
      r"invia\s+(.+?)\s+a\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 2,
      msgG: 1,
    ),
    _p(
      r"scrivi\s+(?:a\s+)?(\w+)\s+(?:che\s+)?(.+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"scrivi\s+a\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"manda\s+un\s+(?:messaggio|saluto)\s+a\s+(\w+)(?:\s+dicendo\s+(.+))?",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
      msgG: 2,
    ),
    _p(
      r"invia\s+un\s+messaggio\s+a\s+(\w+)(?:\s+dicendo\s+(.+))?",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
      msgG: 2,
    ),
    _p(r"saluta\s+(\w+)", VoiceAction.sendMessage, VoiceLang.italian, nameG: 1),
    _p(
      r"di['\s]+ciao\s+a\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"manda\s+ciao\s+a\s+(\w+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"fai\s+sapere\s+a\s+(\w+)\s+(?:che\s+)?(.+)",
      VoiceAction.sendMessage,
      VoiceLang.italian,
      nameG: 1,
      msgG: 2,
    ),

    // ══ ITALIAN — openChat ══
    _p(
      r"apri\s+la\s+chat\s+con\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"vai\s+(?:alla\s+conversazione|da)\s+(?:con\s+)?(\w+)",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"mostra\s+(?:i\s+messaggi|la\s+chat)\s+(?:con|di)\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"apri\s+(?:la\s+inbox\s+di|(\w+)\s+su\s+platechat)",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"portami\s+dalla\s+chat\s+di\s+(\w+)",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"apri\s+(\w+)\s+su\s+platechat",
      VoiceAction.openChat,
      VoiceLang.italian,
      nameG: 1,
    ),

    // ══ ITALIAN — findUser ══
    _p(
      r"(?:cerca|trova|trovami)\s+(?:l['']\s*utente\s+)?(\w+)(?:\s+su\s+platechat)?",
      VoiceAction.findUser,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"mostrami\s+il\s+profilo\s+di\s+(\w+)",
      VoiceAction.findUser,
      VoiceLang.italian,
      nameG: 1,
    ),
    _p(
      r"(\w+)\s+[èe]\s+su\s+platechat",
      VoiceAction.findUser,
      VoiceLang.italian,
      nameG: 1,
    ),

    // ══ ITALIAN — openApp ══
    _p(
      r"(?:apri|avvia|lancia)\s+platechat",
      VoiceAction.openApp,
      VoiceLang.italian,
    ),
    _p(r"vai\s+su\s+platechat", VoiceAction.openApp, VoiceLang.italian),
    _p(
      r"(?:mostra|torna\s+su)\s+platechat",
      VoiceAction.openApp,
      VoiceLang.italian,
    ),
    _p(
      r"apri\s+l['']\s*app\s+di\s+chat",
      VoiceAction.openApp,
      VoiceLang.italian,
    ),
    _p(
      r"apri\s+la\s+mia\s+chat",
      VoiceAction.openApp,
      VoiceLang.italian,
    ),

    // ══ TRIGGER VOICE MODE ══
    _p(
      r"^trigger_voice_mode$",
      VoiceAction.triggerVoiceMode,
      VoiceLang.english,
    ),
  ];

  ParsedIntent parse(String raw) {
    final input = raw.trim().toLowerCase();

    for (final p in _patterns) {
      final match = p.regex.firstMatch(input);
      if (match == null) continue;

      String? name = p.nameGroup > 0 ? match.group(p.nameGroup)?.trim() : null;
      String? msg = p.msgGroup > 0 ? match.group(p.msgGroup)?.trim() : null;

      name = _cleanName(name);

      if (p.action == VoiceAction.sendMessage && (msg == null || msg.isEmpty)) {
        msg = _defaultMsg[p.lang];
      }

      return ParsedIntent(
        action: p.action,
        lang: p.lang,
        rawInput: raw,
        targetUser: name,
        message: msg,
        confidence: _calcConfidence(match, input),
      );
    }

    return ParsedIntent(
      action: VoiceAction.unknown,
      lang: VoiceLang.unknown,
      rawInput: raw,
      confidence: 0.0,
    );
  }

  ParsedIntent parseWithFallback(String raw) {
    final result = parse(raw);
    if (result.isValid) return result;

    final lower = raw.toLowerCase();
    if (_looksLikeItalian(lower)) return parse(_normalizeItalian(lower));

    return result;
  }

  static const _fillerWords = {
    'please',
    'kindly',
    'just',
    'quickly',
    'per favore',
    'cortesemente',
  };

  String? _cleanName(String? name) {
    if (name == null) return null;
    final clean = name.replaceAll(RegExp(r"[''']"), '').trim();
    if (_fillerWords.contains(clean.toLowerCase())) return null;
    return clean.isEmpty ? null : clean;
  }

  double _calcConfidence(RegExpMatch match, String input) {
    final matchLen = match.end - match.start;
    return (matchLen / input.length).clamp(0.3, 1.0);
  }

  bool _looksLikeItalian(String s) =>
      s.contains(RegExp(r'\b(apri|manda|scrivi|trova|vai|invia)\b'));

  String _normalizeItalian(String s) => s
      .replaceAll("l'", "l ")
      .replaceAll("dell'", "dell ")
      .replaceAll("  ", " ");
}
