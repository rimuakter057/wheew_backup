import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/my_qr_view.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_painter.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_user_sheet.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

import '../widget/scan_view_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ScanController scanController = Get.put(ScanController());

  int _tabIndex = 0;
  bool _scanned = false;
  bool _isLoading = false;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late MobileScannerController _scannerController;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed && _tabIndex == 0) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lineController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // ── Tab switch ───────────────────────────────────────────────────────────────

  void _switchTab(int index) {
    setState(() => _tabIndex = index);
    if (index == 0) {
      _scanned = false;
      _scannerController.start();
    } else {
      _scannerController.stop();
      scanController.getQrCode();
    }
  }

  // ── QR detected ──────────────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned || _tabIndex != 0) return;
    final String? code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    if (scanController.isScanning.value) return;

    setState(() {
      _scanned = true;
      _isLoading = true;
    });
    _scannerController.stop();

    final result = await scanController.scanQrCode(qrData: code);
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      await _showScannedUserSheet(result.data!);
    } else {
      showCustomSnackBar(
        result.errorMessage ?? 'Failed to scan QR',
        isError: true,
      );
    }

    setState(() => _isLoading = false);

  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────────

  Future<void> _showScannedUserSheet(Map<String, dynamic> data) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      builder: (_) => ScannedUserSheet(data: data),
    );

    if (!mounted) return;
    setState(() => _scanned = false);
    _scannerController.start();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: ResponsiveHelper.spacing(20)),
            _buildTabToggle(),
            Expanded(
              child: _tabIndex == 0
                  ? ScanView(
                scannerController: _scannerController,
                lineAnimation: _lineAnimation,
                isScanned: _scanned,
                isLoading: _isLoading,
                onDetect: _onDetect,
              )
                  : MyQrView(scanController: scanController),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Toggle ───────────────────────────────────────────────────────────────

  Widget _buildTabToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(24)),
      height: ResponsiveHelper.height(44),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
      ),
      child: Row(
        children: [
          ScanTabButton(
            label: 'scan_qr'.tr,
            isActive: _tabIndex == 0,
            onTap: () => _switchTab(0),
          ),
          ScanTabButton(
            label: 'my_qr'.tr,
            isActive: _tabIndex == 1,
            onTap: () => _switchTab(1),
          ),
        ],
      ),
    );
  }
}