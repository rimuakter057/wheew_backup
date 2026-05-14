import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class AddMemberTile extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double? rating;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckChanged;

  const AddMemberTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isSelected,
    required this.onTap,
    required this.onCheckChanged,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical: ResponsiveHelper.padding(12),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: ResponsiveHelper.borderRadius(24),
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Icon(
                Icons.person,
                color: Colors.white,
                size: ResponsiveHelper.iconSize(24),
              )
                  : null,
            ),
            SizedBox(width: ResponsiveHelper.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if (rating != null) ...[
                    SizedBox(height: ResponsiveHelper.height(4)),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: ResponsiveHelper.iconSize(16),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(4)),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(12),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: AppColors.blueClient,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              onChanged: onCheckChanged,
            ),
          ],
        ),
      ),
    );
  }
}