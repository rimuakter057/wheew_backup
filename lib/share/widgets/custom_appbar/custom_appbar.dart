import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(

      centerTitle: true,

      elevation: 0,

      backgroundColor: Colors.white,

      leading: showBackButton
          ? IconButton(

        onPressed: onBackPressed ??
                () {
              context.pop();
            },

        icon: Icon(
          Icons.arrow_back,
          size: ResponsiveHelper.iconSize(24),
          color: Colors.black,
        ),

      )
          : null,

      title: Text(

        title.tr,

        style: GoogleFonts.poppins(

          color: Colors.black,

          fontSize: ResponsiveHelper.fontSize(18),

          fontWeight: FontWeight.w500,

        ),

      ),

      actions: actions,

    );

  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
