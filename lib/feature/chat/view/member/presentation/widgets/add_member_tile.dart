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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.padding(6),
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
            GestureDetector(
              onTap: () => onCheckChanged(!isSelected),
              child: Container(
                width: ResponsiveHelper.width(22),
                height: ResponsiveHelper.width(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppColors.blue, AppColors.darBlue],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.blue
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.blue.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: ResponsiveHelper.iconSize(14),
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}