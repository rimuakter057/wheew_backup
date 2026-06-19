import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/ocr/data/ocr_controller.dart';
import 'package:platchatapp/feature/ocr/presentation/widgets/dialog.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class OcrScannerScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const OcrScannerScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final OcrController controller = OcrController();

  bool _loading = true;
  bool _autoScan = false;
  bool _dialogOpen = false;
  bool _isLoopRunning = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await controller.initCamera(widget.cameras);

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _manualScan() async {
    if (_dialogOpen) return;

    setState(() {
      _dialogOpen = true;
    });

    // Show processing indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Scanning..."),
        duration: Duration(milliseconds: 800),
      ),
    );

    final plate = await controller.captureAndScan();

    if (plate == null) {
      if (mounted) {
        setState(() {
          _dialogOpen = false;
        });
      }
      _showMessage("No plate/number detected");
      return;
    }

    if (mounted) {
      await PlateDialog.show(context, plate,
            (p) => controller.verifyUser(plateNumber: p),
      );
      setState(() {
        _dialogOpen = false;
      });
    }
  }

  Future<void> _toggleAutoScan() async {
    setState(() {
      _autoScan = !_autoScan;
    });

    if (_autoScan) {
      _startAutoScanLoop();
    }
  }

  Future<void> _startAutoScanLoop() async {
    if (_isLoopRunning) return;
    _isLoopRunning = true;

    while (_autoScan && mounted) {
      if (_dialogOpen) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final plate = await controller.captureAndScan();

      if (plate != null && _autoScan && mounted) {
        setState(() {
          _dialogOpen = true;
        });

        await PlateDialog.show(context, plate,  (String p) async {
          return await controller.verifyUser(
            plateNumber: p,
          );
        },);



        if (mounted) {
          setState(() {
            _dialogOpen = false;
          });
        }

        // Wait after successful detection to prevent immediate re-trigger
        await Future.delayed(const Duration(milliseconds: 2000));
      } else {
        // Wait 1.5 seconds before capturing again if no plate is found
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }

    _isLoopRunning = false;
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _autoScan = false;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final scanW = size.width * 0.85;
    const scanH = 140.0;
    final left = (size.width - scanW) / 2;
    final top = (size.height - scanH) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full-screen Camera Preview
          Positioned.fill(
            child: controller.cameraController!.value.isInitialized
                ? CameraPreview(controller.cameraController!)
                : Container(color: Colors.black),
          ),

          // 2. Custom Scanner Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanW: scanW,
                scanH: scanH,
                left: left,
                top: top,
              ),
            ),
          ),

          // 3. Animated Scan Line (Inside Cutout Frame)
          Positioned(
            left: left,
            top: top,
            width: scanW,
            height: scanH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  ScanLine(width: scanW, height: scanH),
                ],
              ),
            ),
          ),

          // 4. Custom Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  //   onPressed: () => Navigator.pop(context),
                  // ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        context.pop();

                      }, icon: Icon(Icons.arrow_back_ios,color: AppColors.white,)),
                      SizedBox(width: ResponsiveHelper.width(12),),
                       Text(
                        "Plate Scanner",
                        style: context.titleMedium.copyWith(color: AppColors.white)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Custom Bottom Control Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Auto Scan Switch Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Automatic Detection",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _autoScan
                                ? "Auto scanning in progress..."
                                : "Manual scan mode active",
                            style: TextStyle(
                              color: _autoScan ? Colors.greenAccent : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _autoScan,
                        activeColor: Colors.greenAccent,
                        activeTrackColor: Colors.greenAccent.withOpacity(0.3),
                        onChanged: (value) {
                          _toggleAutoScan();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Manual capture/scan button
                  GestureDetector(
                    onTap: _autoScan ? null : _manualScan,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _autoScan ? 0.3 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient:  LinearGradient(
                            colors: [

                              AppColors.blue, AppColors.blue],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "SCAN NOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for scanning frame cutout
class ScannerOverlayPainter extends CustomPainter {
  final double scanW;
  final double scanH;
  final double left;
  final double top;

  ScannerOverlayPainter({
    required this.scanW,
    required this.scanH,
    required this.left,
    required this.top,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);

    // Outer mask
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Transparent cutout
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanW, scanH),
        const Radius.circular(16),
      ));

    final overlayPath = Path.combine(PathOperation.difference, outerPath, cutoutPath);
    canvas.drawPath(overlayPath, paint);

    // Glowing border for scanner cutout
    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanW, scanH),
        const Radius.circular(16),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanW != scanW ||
        oldDelegate.scanH != scanH ||
        oldDelegate.left != left ||
        oldDelegate.top != top;
  }
}

// Animated Scan Line Component
class ScanLine extends StatefulWidget {
  final double width;
  final double height;

  const ScanLine({super.key, required this.width, required this.height});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: widget.height).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.greenAccent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}