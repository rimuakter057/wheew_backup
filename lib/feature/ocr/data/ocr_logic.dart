import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrController {
  CameraController? cameraController;
  final TextRecognizer _recognizer = TextRecognizer();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<void> initCamera(List<CameraDescription> cameras) async {
    final backCamera = cameras.firstWhere(
      (e) => e.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      backCamera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    await cameraController!.initialize();
  }

  /// Captures a picture and processes it for OCR.
  /// This is 100% reliable and avoids the platform-dependent format issues of image streams.
  Future<String?> captureAndScan() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }

    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final XFile file = await cameraController!.takePicture();

      // Crop the image to focus strictly on the scanner cutout to ignore background text noise
      try {
        final bytes = await File(file.path).readAsBytes();
        final img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          final cropWidth = (image.width * 0.85).toInt();
          final cropHeight = (image.height * 0.20).toInt();
          final cropLeft = ((image.width - cropWidth) / 2).toInt();
          final cropTop = ((image.height - cropHeight) / 2).toInt();

          final croppedImage = img.copyCrop(
            image,
            x: cropLeft,
            y: cropTop,
            width: cropWidth,
            height: cropHeight,
          );

          await File(file.path).writeAsBytes(img.encodeJpg(croppedImage));
        }
      } catch (cropErr) {
        debugPrint("OCR Image crop error: $cropErr");
      }

      final inputImage = InputImage.fromFilePath(file.path);
      final result = await _recognizer.processImage(inputImage);

      // Clean up the image file asynchronously to save space
      try {
        final ioFile = File(file.path);
        if (await ioFile.exists()) {
          await ioFile.delete();
        }
      } catch (e) {
        debugPrint("Error deleting temp image: $e");
      }

      _isProcessing = false;
      return _extractPlate(result.text);
    } catch (e) {
      debugPrint("Capture and Scan Error: $e");
      _isProcessing = false;
      return null;
    }
  }

  String? _extractPlate(String text) {
    if (text.isEmpty) return null;

    final cleaned = text.toUpperCase().trim();

    final patterns = [
      // AB123CD
      RegExp(r'\b[A-Z]{2}\d{3}[A-Z]{2}\b'),
      // AB12CDE
      RegExp(r'\b[A-Z]{2}\d{2}[A-Z]{3}\b'),
      // ABC1234
      RegExp(r'\b[A-Z]{2,3}\d{3,4}\b'),
      // ABC-1234
      RegExp(r'\b[A-Z]{2,3}-\d{3,4}\b'),
      // 1234ABC
      RegExp(r'\b\d{3,4}[A-Z]{2,3}\b'),
      // General Alphanumeric combinations (e.g. Bangladesh plate pattern like Dhaka Metro-Ga 12-3456)
      RegExp(r'\b[A-Z\s]{2,15}\s*[-–—]?\s*[A-Z]{1,2}\s*[-–—]?\s*\d{2,4}\s*[-–—]?\s*\d{4}\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        return match.group(0);
      }
    }

    final lines = cleaned.split('\n');

    // Fallback 1: Any line containing letters (or Bangla characters) and at least a 3-digit number sequence (highly confident plate indicator)
    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.length >= 4 && trimmedLine.length <= 25) {
        final hasLetters = RegExp(r'[A-Z\u0980-\u09FF]').hasMatch(trimmedLine);
        final hasNumberSeq = RegExp(r'\d{3,}').hasMatch(trimmedLine);
        if (hasLetters && hasNumberSeq) {
          return trimmedLine.replaceAll(RegExp(r'[^A-Z0-9\s\-\u0980-\u09FF]'), '');
        }
      }
    }

    // Fallback 2: Any line containing a sequence of 4 or more digits (typical for plates detected without leading letters)
    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.length >= 4 && trimmedLine.length <= 20) {
        if (RegExp(r'\d{4,}').hasMatch(trimmedLine)) {
          return trimmedLine.replaceAll(RegExp(r'[^A-Z0-9\s\-\u0980-\u09FF]'), '');
        }
      }
    }

    // No confident matches found (prevents showing random words/buttons/noise in the dialog)
    return null;
  }

  Future<void> dispose() async {
    await cameraController?.dispose();
    _recognizer.close();
  }
}