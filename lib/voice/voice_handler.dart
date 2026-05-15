// lib/voice/voice_handler.dart

// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'intent_parser.dart';

class VoiceHandler extends WidgetsBindingObserver {
  static const _channel = MethodChannel('com.platechat/voice_intent');
  static bool _initialized = false;
  static VoiceHandler? _instance;

  static void initialize({required Function(ParsedIntent) onIntent}) {
    if (_initialized) return;
    _initialized = true;

    // MethodChannel handler
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onVoiceIntent') {
        final raw = call.arguments as String? ?? '';
        if (raw.isEmpty) return;
        final intent = IntentParser.instance.parseWithFallback(raw);
        onIntent(intent);
      }
    });

    // App lifecycle observer — foreground এ আসলে iOS কে জিজ্ঞেস করো
    _instance = VoiceHandler._internal(onIntent);
    WidgetsBinding.instance.addObserver(_instance!);

    // App start এ একবার check করো
    _checkPending();
  }

  static void _checkPending() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _channel.invokeMethod('checkPendingIntent');
    });
  }

  final Function(ParsedIntent) _onIntent;
  VoiceHandler._internal(this._onIntent);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App foreground এ আসলে pending intent check করো
    if (state == AppLifecycleState.resumed) {
      _checkPending();
    }
  }

  static void simulateVoice(String raw, Function(ParsedIntent) onIntent) {
    final intent = IntentParser.instance.parse(raw);
    onIntent(intent);
  }
}
// ```

// ---

// ## Flow এখন কেমন হবে
// ```
// Siri → contact name নেয় → perform() → UserDefaults এ save
//     → app foreground এ আসে → Flutter resumed
//     → checkPendingIntent() call → iOS UserDefaults পড়ে
//     → Flutter এ send → IntentParser → MessageScreen
