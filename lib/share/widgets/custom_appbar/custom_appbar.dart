import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color?bgColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed, this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,

      elevation: 0,

      backgroundColor:bgColor?? AppColors.lightBlue,

      leading: BackIconWidget(),

      title: Text(
        title.tr,

        style: GoogleFonts.poppins(
          color: AppColors.black,

          fontSize: ResponsiveHelper.fontSize(16),

          fontWeight: FontWeight.w500,
        ),
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



class BackIconWidget extends StatelessWidget {
  const BackIconWidget({
    super.key,
  });



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(left: ResponsiveHelper.padding(8)),
      child: GestureDetector(
        onTap: (){

          Navigator.pop(context);

        },
        child: Container(

          padding: ResponsiveHelper.all(12),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.5),
              border: Border.all(color: AppColors.white)
          ),
          child:  Icon(
            Icons.arrow_back,
            size: ResponsiveHelper.iconSize(24),
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}



