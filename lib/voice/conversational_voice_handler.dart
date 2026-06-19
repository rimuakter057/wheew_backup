import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:platchatapp/voice/intent_parser.dart';
import 'package:platchatapp/voice/voice_action_router.dart';

class ConversationalVoiceHandler {
  ConversationalVoiceHandler._();
  static final ConversationalVoiceHandler instance = ConversationalVoiceHandler._();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  
  bool _isTtsInitialized = false;

  Future<void> _initTts() async {
    if (_isTtsInitialized) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Play through speaker even if phone is on silent/vibrate mode (essential for drivers!)
    try {
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playAndRecord,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
      );
    } catch (e) {
      debugPrint('[Voice] Failed to set iOS audio category: $e');
    }

    await _flutterTts.awaitSpeakCompletion(true);
    _isTtsInitialized = true;
  }

  Future<void> startConversationalFlow(VoiceActionRouter router) async {
    await _initTts();

    debugPrint('[Voice] Starting conversational flow...');
    
    // 1. Speak prompt
    await _flutterTts.speak("What should I do now?");
    
    // 2. Start listening
    await _startListening(router);
  }

  Future<void> _startListening(VoiceActionRouter router) async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint('[Voice] STT Status: $status'),
      onError: (error) => debugPrint('[Voice] STT Error: $error'),
    );

    if (available) {
      debugPrint('[Voice] Listening started...');
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedText = result.recognizedWords;
            debugPrint('[Voice] Recognized: $recognizedText');
            
            if (recognizedText.isNotEmpty) {
              final intent = IntentParser.instance.parseWithFallback(recognizedText);
              router.route(intent);
            }
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );
    } else {
      debugPrint('[Voice] Speech recognition not available or permission denied.');
    }
  }
}
