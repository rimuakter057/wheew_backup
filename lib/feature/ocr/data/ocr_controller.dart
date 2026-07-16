import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

import '../../../core/service/api_client.dart';

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
    debugPrint("Camera Initialized");
  }

  Future<String?> captureAndScan() async {
    debugPrint("========== OCR START ==========");

    if (cameraController == null || !cameraController!.value.isInitialized) {
      debugPrint("Camera NOT initialized");
      return null;
    }

    if (_isProcessing) {
      debugPrint("Already processing...");
      return null;
    }

    _isProcessing = true;

    try {
      final XFile file = await cameraController!.takePicture();
      debugPrint("Image captured: ${file.path}");

      // ---------- IMAGE CROP ----------
      try {
        final bytes = await File(file.path).readAsBytes();
        final img.Image? image = img.decodeImage(bytes);

        if (image != null) {
          debugPrint("Original size: ${image.width} x ${image.height}");

          final cropWidth = (image.width * 0.85).toInt();
          final cropHeight = (image.height * 0.20).toInt();
          final cropLeft = ((image.width - cropWidth) / 2).toInt();
          final cropTop = ((image.height - cropHeight) / 2).toInt();

          debugPrint("Crop -> W:$cropWidth H:$cropHeight L:$cropLeft T:$cropTop");

          final croppedImage = img.copyCrop(
            image,
            x: cropLeft,
            y: cropTop,
            width: cropWidth,
            height: cropHeight,
          );

          await File(file.path).writeAsBytes(img.encodeJpg(croppedImage));
          debugPrint("Image cropped successfully");
        }
      } catch (cropErr) {
        debugPrint("Crop error: $cropErr");
      }

      // ---------- OCR ----------
      final inputImage = InputImage.fromFilePath(file.path);
      final result = await _recognizer.processImage(inputImage);

      debugPrint("========== RAW OCR TEXT ==========");
      debugPrint(result.text);
      debugPrint("==================================");

      final plate = _extractPlate(result.text);

      debugPrint("========== FINAL RESULT ==========");
      debugPrint("PLATE: $plate");
      debugPrint("==================================");

      // cleanup
      try {
        final ioFile = File(file.path);
        if (await ioFile.exists()) {
          await ioFile.delete();
        }
      } catch (e) {
        debugPrint("File delete error: $e");
      }

      _isProcessing = false;
      return plate;

    } catch (e) {
      debugPrint("Capture error: $e");
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  String? _extractPlate(String text) {
    debugPrint("========== EXTRACT INPUT ==========");
    debugPrint(text);

    if (text.isEmpty) return null;

    final cleaned = text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    debugPrint("CLEANED: $cleaned");

    final pattern = RegExp(r'[A-Z]{2}\d{3}[A-Z]{2}');
    final match = pattern.firstMatch(cleaned);

    if (match != null) {
      debugPrint("MATCH FOUND: ${match.group(0)}");
      return match.group(0);
    }

    debugPrint("NO MATCH FOUND");

    return null;
  }


  var isVerify = false.obs;

  Future<bool> verifyUser({
    required String plateNumber,
  }) async {
    debugPrint('🚗 verifyUser() called | plateNumber: $plateNumber');

    isVerify.value = true;

    try {
      final uri = ApiUrl.verifyLicense;
      debugPrint('📤 Calling API: $uri | body: {"plate_no": "$plateNumber"}');

      final http.Response response = await ApiClient.postData(
        uri: uri,
        body: {"plate_no": plateNumber},
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        debugPrint('⚠️ Response body parse failed: $e');
        data = null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ success verify');
        showSuccessToast(data?['message'] ?? AppStrings.licenseVerifiedSuccessfully.tr);
        return true;
      } else {
        debugPrint('❌ verify failed | status: ${response.statusCode} | body: ${response.body}');
        showErrorToast(data?['message'] ?? AppStrings.licenseVerificationFailed.tr);
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ verify timeout: $e');
      showErrorToast(AppStrings.connectionTimeout.tr);
      return false;
    } catch (e) {
      debugPrint('❌ verify error: $e');
      showErrorToast(AppStrings.someThingWrong.tr);
      return false;
    } finally {
      isVerify.value = false;
      debugPrint('🔚 verifyUser() finished | isVerify reset to false');
    }
  }










  Future<Map<String, dynamic>?> getChatRoomByPlate({
    required String plateNumber,
  }) async {
    try {
      final http.Response response = await ApiClient.postData(
        uri: ApiUrl.verifyPlate,
        body: {"plate_no": plateNumber},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data);
      } else {
        String message = 'License plate not found';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        showErrorToast(message);
        return null;
      }
    } catch (e) {
      showErrorToast(AppStrings.someThingWrong.tr);
      return null;
    }
  }



  Future<void> dispose() async {
    debugPrint("Disposing OCR...");
    await cameraController?.dispose();
    _recognizer.close();
  }
}