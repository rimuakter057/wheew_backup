import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

import '../../../../utils/language/app_string.dart';

final GlobalKey qrCardKey = GlobalKey();

Future<void> downloadQrCard(BuildContext context) async {

  debugPrint("start download======================");
  try {
    // Gallery permission চেক করুন
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {

        debugPrint("Please allow gallery access to download'");
        CustomSnackbar.error(
          context: context,
          message: AppStrings.pleaseAllowGalleryAccessToDownload.tr,
        );


        return;
      }
    }

    RenderRepaintBoundary? boundary;
    int retries = 0;
    while (boundary == null && retries < 10) {
      final renderObject = qrCardKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        boundary = renderObject;
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    }

    if (boundary == null) {

      debugPrint("boundary error=====================");
      CustomSnackbar.error(
        context: context,
        message: AppStrings.qrCardNotReady.tr,
      );

      return;
    }

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    await Gal.putImageBytes(
      pngBytes,
      name: 'qr_card_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (context.mounted) {
      CustomSnackbar.success(
        context: context,
        message: AppStrings.downloadSuccessfullyComplete.tr,
      );
    }
    debugPrint("success================================");

  } catch (e) {

    if (context.mounted) {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.failedToDownloadQrCard.tr,
      );
    }
    Logger().e("❌ Download QR Card Error: $e");
  }
}
