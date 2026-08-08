import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_user_sheet.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
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

  bool _scanned = false;
  bool _isLoading = false;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late MobileScannerController _scannerController;

  // â”€â”€ Lifecycle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } else if (state == AppLifecycleState.resumed) {
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

  // â”€â”€ QR detected â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
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

  // â”€â”€ Back navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Reached either via a pushed GoRouter route (chat list's scan icon) or via
  // the bottom nav's Scan tab, which just swaps mainNavIndex without pushing
  // a route — so there may be nothing for GoRouter to pop back to.

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      mainNavIndex.value = previousMainNavIndex.value;
    }
  }

  // â”€â”€ Bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showScannedUserSheet(Map<String, dynamic> data) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withOpacity(0.6),
      isScrollControlled: true,
      builder: (_) => ScannedUserSheet(data: data),
    );

    if (!mounted) return;
    setState(() => _scanned = false);
    _scannerController.start();
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryBackgroundGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScanView(
              scannerController: _scannerController,
              lineAnimation: _lineAnimation,
              isScanned: _scanned,
              isLoading: _isLoading,
              onDetect: _onDetect,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(bottom: false, child: _buildHeader()),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(top: false, child: _buildBottomControls()),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Header: circular back button + centered title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(16),
        vertical: ResponsiveHelper.padding(8),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _goBack,
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 18),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppStrings.scanQrCode.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.width(40)),
        ],
      ),
    );
  }

  // â”€â”€ Bottom controls: torch / rescan / flip camera â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(40),
        vertical: ResponsiveHelper.padding(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _scannerController,
            builder: (context, state, _) {
              final bool torchOn = state.torchState == TorchState.on;
              return _CircleIconButton(
                icon: torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                onTap: () => _scannerController.toggleTorch(),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              setState(() => _scanned = false);
              _scannerController.start();
            },
            child: Container(
              width: ResponsiveHelper.width(64),
              height: ResponsiveHelper.width(64),
              padding: EdgeInsets.all(ResponsiveHelper.width(4)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.35),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.white, Color(0xFFDCE2E9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.cameraswitch_outlined,
            onTap: () => _scannerController.switchCamera(),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Small circular icon button used in the bottom control bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.width(48),
        height: ResponsiveHelper.width(48),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.black, size: ResponsiveHelper.iconSize(22)),
      ),
    );
  }
}


