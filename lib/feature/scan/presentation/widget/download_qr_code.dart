import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

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
        CustomSnackbar.error(context: context, message: 'Please allow gallery access to download');


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
      CustomSnackbar.error(context: context, message: 'QR card is not ready yet. Please try again.');

      return;
    }

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // ✅ সরাসরি Gallery তে সেভ হবে
    // await Gal.putImageBytes(
    //   pngBytes,
    //   name: 'qr_card_${DateTime.now().millisecondsSinceEpoch}',
    // );
    //
    //
    // CustomSnackbar.success(context: context, message: ' QR Card saved to gallery');
    // debugPrint("success================================");
    await Gal.putImageBytes(
      pngBytes,
      name: 'qr_card_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (context.mounted) {
      CustomSnackbar.success(context: context, message: 'download successfully complete');
    }
    debugPrint("success================================");

  } catch (e) {

    if (context.mounted) {
      CustomSnackbar.error(context: context, message: 'Failed to download QR card');
    }
    Logger().e("❌ Download QR Card Error: $e");
  }
}


// Future<void> downloadQrCard(BuildContext context) async {
//   try {
//     CustomSnackbar.success(
//       context: context,
//       message: 'Preparing QR Card...',
//     );
//
//     final hasAccess = await Gal.hasAccess();
//
//     if (!hasAccess) {
//       final granted = await Gal.requestAccess();
//
//       if (!granted) {
//         CustomSnackbar.error(
//           context: context,
//           message: 'Gallery permission denied',
//         );
//         return;
//       }
//     }
//
//     RenderRepaintBoundary? boundary;
//
//     for (int i = 0; i < 10; i++) {
//       final renderObject = qrCardKey.currentContext?.findRenderObject();
//
//       if (renderObject is RenderRepaintBoundary) {
//         boundary = renderObject;
//         break;
//       }
//
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//
//     if (boundary == null) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'QR card not ready. Please try again.',
//       );
//       return;
//     }
//
//     if (boundary.debugNeedsPaint) {
//       await Future.delayed(const Duration(milliseconds: 300));
//     }
//
//     final image = await boundary.toImage(pixelRatio: 4);
//
//     final byteData = await image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//
//     if (byteData == null) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Failed to generate image',
//       );
//       return;
//     }
//
//     final pngBytes = byteData.buffer.asUint8List();
//
//     await Gal.putImageBytes(
//       pngBytes,
//       name: 'qr_card_${DateTime.now().millisecondsSinceEpoch}',
//     );
//
//     CustomSnackbar.success(
//       context: context,
//       message: 'QR Card saved successfully',
//     );
//
//     Logger().i("✅ QR Card Saved");
//   } catch (e, s) {
//     Logger().e(
//       "❌ Download QR Error",
//       error: e,
//       stackTrace: s,
//     );
//
//     CustomSnackbar.error(
//       context: context,
//       message: 'Download failed: ${e.toString()}',
//     );
//   }
// }