import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class DropPinButton extends StatelessWidget {
  final VoidCallback onTap;

  const DropPinButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: ResponsiveHelper.buttonHeight(52),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D72E8).withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:  EdgeInsets.only(left:ResponsiveHelper.width(8)),
              child: Container(
                width: ResponsiveHelper.width(28),
                height: ResponsiveHelper.height(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'P',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(15),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Expanded(                          // ← এটা add করো
              child: Text(
                'drop_parking_pin'.tr.isNotEmpty ? 'drop_parking_pin'.tr : 'Drop Parking Pin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,   // ← center রাখতে চাইলে
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
