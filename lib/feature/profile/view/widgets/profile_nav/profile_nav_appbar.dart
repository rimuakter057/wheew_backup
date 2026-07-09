import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../../utils/color/app_colors.dart';
import '../../../../../utils/language/app_string.dart';

class ProfileNavAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProfileNavAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBlue,
      elevation: 0,
      title: Text(
        AppStrings.profile.tr,
        style: GoogleFonts.poppins(
          color: const Color(0xFF1A1D20),
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveHelper.titleFontSize(18),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: ResponsiveHelper.padding(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: ResponsiveHelper.height(40),
                width: ResponsiveHelper.height(40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1A1D20),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}