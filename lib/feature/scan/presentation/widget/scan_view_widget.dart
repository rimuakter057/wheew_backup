import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final MobileScannerController controller = MobileScannerController();

  bool scanned = false;
  bool loading = false;

  void onDetect(BarcodeCapture capture) async {
    if (scanned || loading) return;

    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() {
      scanned = true;
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => loading = false);

    // show bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
        ),

        if (loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}