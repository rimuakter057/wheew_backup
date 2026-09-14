import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';

class ChatDateDivider extends StatelessWidget {
  final String text;

  const ChatDateDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.height(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.width(12),
          vertical: ResponsiveHelper.height(4),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(12),
            color: const Color(0xFF54656F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
