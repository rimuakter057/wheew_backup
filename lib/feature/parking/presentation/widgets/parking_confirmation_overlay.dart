import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class ParkingConfirmationOverlay extends StatelessWidget {
  final RxBool visible;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const ParkingConfirmationOverlay({
    super.key,
    required this.visible,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!visible.value) {
        return const SizedBox.shrink();
      }
      return Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(24),
                vertical: ResponsiveHelper.padding(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(18)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_parking_rounded,
                      size: ResponsiveHelper.iconSize(44),
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  Text(
                    'Parking Confirmation',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  Text(
                    'Are you leaving a parking spot right now?',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(15),
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(32)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            visible.value = false;
                            onNo();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.padding(15),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: ResponsiveHelper.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(14)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            visible.value = false;
                            onYes();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.padding(15),
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
