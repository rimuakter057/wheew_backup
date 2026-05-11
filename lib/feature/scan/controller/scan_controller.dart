import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';


class ScanController extends GetxController {

  RxBool isScanning = false.obs;

  Future<void> scanQrCode({
    required String qrData,
    required BuildContext context,
    required Function(Map<String, dynamic>) onResult,
  }) async {
    try {
      isScanning.value = true;

      print('🔍 [SCAN] qrData: $qrData');

      final response = await ApiClient.postData(
        uri: ApiUrl.scanQr,
        body: {"qrData": qrData},
      );

      print('📡 [SCAN] Status: ${response.statusCode}');
      print('📡 [SCAN] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        onResult(data); // ✅ screen এ pass করো
      } else {
        // Get.snackbar(
        //   'Error', 'Invalid QR Code',
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        // );
      }
    } catch (e) {
      print('💥 [SCAN] Error: $e');
      // Get.snackbar(
      //   'Error', e.toString(),
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      // );
    } finally {
      isScanning.value = false;
    }
  }


  ///get scan==============
  var isLoadingQr = false.obs;
  var qrBase64 = ''.obs;

  Future<void> getQrCode() async {
    isLoadingQr.value = true;
    qrBase64.value = '';

    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.getQRCode, // ✅ ApiUrl এ add করো: static const generateCode = '/users/generate-code';
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['qr_code'] != null) {
        qrBase64.value = body['qr_code'];
        debugPrint('✅ QR Code loaded');
      } else {
        debugPrint('❌ QR fetch failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('getQrCode error: $e');
    } finally {
      isLoadingQr.value = false;
    }
  }
}