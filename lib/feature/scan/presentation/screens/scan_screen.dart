import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _tabIndex = 0;
  bool _scanned = false;
  bool _isLoading = false;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late MobileScannerController _scannerController;

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

  void _switchTab(int index) {
    setState(() => _tabIndex = index);
    if (index == 0) {
      _scanned = false;
      _scannerController.start();
    } else {
      _scannerController.stop();
    }
  }

  // ── QR detected → loading → ProfileCard bottomSheet ────────────────────────

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned || _tabIndex != 0 || _isLoading) return;
    final String? code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _scanned = true;
      _isLoading = true;
    });
    _scannerController.stop();

    // ── TODO: Replace dummy data with your real API call ──────────────────
    // final response = await http.get(Uri.parse('https://yourapi.com/user?qr=$code'));
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(milliseconds: 800));
    final Map<String, dynamic> dummyUser = {
      'name': 'Rahul Ahmed',
      'rating': 4.8,
      'address': 'Dhaka, BD',
    };
    // ── End dummy data ─────────────────────────────────────────────────────

    if (!mounted) return;
    setState(() => _isLoading = false);

    /// ── Show ProfileCard ───────────────────────────────────────────────────
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: ProfileCard(
          name: dummyUser['name'] ?? '',
          rating: (dummyUser['rating'] ?? 0.0).toDouble(),
          address: dummyUser['address'] ?? '',
          showRating: false,
        ),
      ),
    );

    // Reset after bottom sheet closes so user can scan again
    if (!mounted) return;
    setState(() => _scanned = false);
    _scannerController.start();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
                  ? _buildScanView(context)
                  : _buildMyQrView(context),
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
          TabButton(
            label: 'scan_qr'.tr,
            isActive: _tabIndex == 0,
            onTap: () => _switchTab(0),
          ),
          TabButton(
            label: 'my_qr'.tr,
            isActive: _tabIndex == 1,
            onTap: () => _switchTab(1),
          ),
        ],
      ),
    );
  }

  // ── Scan View ────────────────────────────────────────────────────────────────

  Widget _buildScanView(BuildContext context) {
    final double boxSize = ResponsiveHelper.width(280);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: ResponsiveHelper.spacing(32)),

        Stack(
          alignment: Alignment.center,
          children: [
            // ── Camera ───────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) =>
                      _CameraError(boxSize: boxSize, error: error),
                ),
              ),
            ),

            // ── Scanning line ─────────────────────────────────────────────
            if (!_scanned)
              SizedBox(
                width: boxSize,
                height: boxSize,
                child: AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (_, __) {
                    return Stack(
                      children: [
                        Positioned(
                          top: _lineAnimation.value * (boxSize - 4),
                          left: 12,
                          right: 12,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF3D72E8).withOpacity(0.8),
                                  const Color(0xFF3D72E8),
                                  const Color(0xFF3D72E8).withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3D72E8).withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // ── Loading overlay ───────────────────────────────────────────
            if (_isLoading)
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius:
                  BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3D72E8),
                    strokeWidth: 2.5,
                  ),
                ),
              ),

            // ── Success overlay ───────────────────────────────────────────
            if (_scanned && !_isLoading)
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius:
                  BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF3D72E8),
                    size: 64,
                  ),
                ),
              ),

            // ── Corner markers ────────────────────────────────────────────
            SizedBox(
              width: boxSize,
              height: boxSize,
              child: CustomPaint(
                painter: _CornerPainter(
                  color: const Color(0xFF3D72E8),
                  cornerSize: ResponsiveHelper.width(28),
                  strokeWidth: ResponsiveHelper.borderWidth(3),
                  radius: ResponsiveHelper.borderRadius(8),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveHelper.spacing(28)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(40)),
          child: Text(
            'point_camera_hint'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(13),
              color: Colors.white.withOpacity(0.45),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // ── My QR View ───────────────────────────────────────────────────────────────

  Widget _buildMyQrView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: ResponsiveHelper.width(240),
          height: ResponsiveHelper.width(240),
          padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D72E8).withOpacity(0.22),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              size: ResponsiveHelper.iconSize(170),
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(28)),
        Text(
          'let_others_scan'.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(13),
            color: Colors.white.withOpacity(0.45),
          ),
        ),

      ],
    );
  }
}

// ─── Camera Error Widget ──────────────────────────────────────────────────────

class _CameraError extends StatelessWidget {
  final double boxSize;
  final MobileScannerException error;

  const _CameraError({required this.boxSize, required this.error});

  String get _message {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'camera_permission_denied'.tr;
      case MobileScannerErrorCode.unsupported:
        return 'camera_unsupported'.tr;
      default:
        return 'camera_error'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined,
              color: Colors.white.withOpacity(0.2), size: 48),
          const SizedBox(height: 12),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Button ───────────────────────────────────────────────────────────────

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton({super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius:
            BorderRadius.circular(ResponsiveHelper.borderRadius(26)),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF1A1A2E)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Corner Painter ───────────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  final double cornerSize;
  final double strokeWidth;
  final double radius;

  _CornerPainter({
    required this.color,
    required this.cornerSize,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double r = radius;
    final double c = cornerSize;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, c)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(c, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - c, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
        ..lineTo(size.width, c),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - c)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height),
            radius: Radius.circular(r), clockwise: false)
        ..lineTo(c, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - c, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(Offset(size.width, size.height - r),
            radius: Radius.circular(r), clockwise: false)
        ..lineTo(size.width, size.height - c),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color ||
          old.cornerSize != cornerSize ||
          old.strokeWidth != strokeWidth;
}


