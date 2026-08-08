import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_service.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

import '../../../utils/language/app_string.dart';

class ScanQrResult {

  final bool isSuccess;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const ScanQrResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });
}

class ScanController extends GetxController {

  RxBool isScanning = false.obs;

  Future<ScanQrResult> scanQrCode({
    required String qrData,
    BuildContext? context,
    Function(Map<String, dynamic>)? onResult,
  }) async
  {
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
        final mapped = Map<String, dynamic>.from(data);
        onResult?.call(mapped);
        return ScanQrResult(
          isSuccess: true,
          data: mapped,
        );
      } else {
        String message = 'Invalid QR Code';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        return ScanQrResult(
          isSuccess: false,
          errorMessage: message,
        );
      }
    } catch (e) {
      print('💥 [SCAN] Error: $e');
      return ScanQrResult(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    } finally {
      isScanning.value = false;
    }
  }


  ///get scan==============
  var isLoadingQr = false.obs;
  var qrBase64 = ''.obs;

  var isDownloadingQr = false.obs;


  var qrCardHtml = ''.obs;


  Future<void> getQrCode({required BuildContext context}) async {
    try {
      isLoadingQr.value = true;

      Response response = await ApiService.getData(ApiUrl.qrCard);

      if (response.statusCode == 200) {
        qrCardHtml.value = response.bodyString ?? response.body.toString();
      } else {



        CustomSnackbar.error(
          context: context,
          message: AppStrings.failedToLoadQrCard.tr,
        );
      }
    } catch (e) {
      Logger().e("❌ getQrCode Error: $e");

      CustomSnackbar.error(
        context: context,
        message: AppStrings.somethingWentWrongWhileLoadingQrCard.tr,
      );
    } finally {
      isLoadingQr.value = false;
    }
  }





Future<void> getScanQrCode() async {
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










  RxBool isScanningNumber = false.obs;



  Future<ScanQrResult> scanByPlate({
    required String plateNo,
    BuildContext? context,
    Function(Map<String, dynamic>)? onResult,
  }) async {
    try {
      isScanningNumber.value = true;

      print('🔍 [SCAN-PLATE] plateNo: $plateNo');

      final response = await ApiClient.postData(
        uri: ApiUrl.verifyPlate,
        body: {"plate_no": plateNo},
      );

      print('📡 [SCAN-PLATE] Status: ${response.statusCode}');
      print('📡 [SCAN-PLATE] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final mapped = Map<String, dynamic>.from(data);
        onResult?.call(mapped);
        return ScanQrResult(
          isSuccess: true,
          data: mapped,
        );
      } else {
        String message = AppStrings.invalidPlateNumber;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        return ScanQrResult(
          isSuccess: false,
          errorMessage: message,
        );
      }
    } catch (e) {
      print('💥 [SCAN-PLATE] Error: $e');
      return ScanQrResult(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    } finally {
      isScanningNumber.value = false;
    }
  }





}