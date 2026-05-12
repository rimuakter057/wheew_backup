import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Map / parking debug. Filter logcat with: `[PlateChat.Map]`
/// Example (PowerShell): `adb logcat | Select-String "PlateChat"`
/// Native `BufferQueueProducer` lines cannot be turned off from Dart—they come from SurfaceView/ImageReader/Camera.
void mapDebug(String message) {
  if (kDebugMode) {
    const tag = '[PlateChat.Map]';
    debugPrint('$tag $message');
    developer.log(message, name: tag);
  }
}
