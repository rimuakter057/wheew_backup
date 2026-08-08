
import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/chat/model/view_user_profile_model.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.name,
    required this.rating,
    this.image,
    required this.showRating,
    this.onRatingTap,
  });

  final ViewUserProfileModel profile;
  final String name;
  final double rating;
  final String? image;
  final bool showRating;
  final VoidCallback? onRatingTap;

  @override
  Widget build(BuildContext context) {
    // profile.avatar à¦•à§‡ priority à¦¦à¦¾à¦“, à¦¨à¦¾ à¦¥à¦¾à¦•à¦²à§‡ fallback à¦¹à¦¿à¦¸à§‡à¦¬à§‡ passed image à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à§‹
    final avatarPath = (profile.avatar != null && profile.avatar!.isNotEmpty)
        ? profile.avatar
        : image;

    final displayName = (profile.nickName != null && profile.nickName!.isNotEmpty)
        ? profile.nickName!
        : (profile.name ?? name);

    final hasVehicleInfo = (profile.vehicleType != null && profile.vehicleType!.isNotEmpty) ||
        (profile.vehicleModel != null && profile.vehicleModel!.isNotEmpty) ||
        (profile.vehicleColor != null && profile.vehicleColor!.isNotEmpty);

    final hasLocation = (profile.city != null && profile.city!.isNotEmpty) ||
        (profile.country != null && profile.country!.isNotEmpty);


    final location = [profile.city, profile.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');


    return Center(
      child: Container(
        width: ResponsiveHelper.width(320),
        padding: ResponsiveHelper.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(28),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // â”€â”€ Close button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: CircleAvatar(
                    radius: ResponsiveHelper.iconSize(16),
                    backgroundColor: AppColors.grey[100],
                    child: Icon(
                      Icons.close,
                      size: ResponsiveHelper.iconSize(16),
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            // â”€â”€ Avatar + verified badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: ResponsiveHelper.width(48),
                  backgroundColor: AppColors.materialBlue[50],
                  backgroundImage: NetworkImage(
                    ImageHandler.imagesHandle(avatarPath, isProfile: true),
                  ),
                ),
                if (profile.emailVerified)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        size: ResponsiveHelper.iconSize(18),
                        color: AppColors.blue,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(12)),

            // â”€â”€ Name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Text(
              displayName,
              style: context.bodyMedium.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),

            // â”€â”€ Designation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (profile.designation != null && profile.designation!.isNotEmpty) ...[
              SizedBox(height: ResponsiveHelper.spacing(4)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.width(10),
                  vertical: ResponsiveHelper.height(3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(20),
                  ),
                ),
                child: Text(
                  profile.designation!.capitalizeFirst ?? profile.designation!,
                  style: context.bodySmall.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            SizedBox(height: ResponsiveHelper.spacing(10)),

            // â”€â”€ Rating + Location row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: profile.totalRatings > 0
                      ? AppColors.orange
                      : AppColors.grey,
                  size: ResponsiveHelper.iconSize(18),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: context.bodySmall,
                ),
                if (profile.totalRatings > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${profile.totalRatings})',
                    style: context.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],

                  SizedBox(width: ResponsiveHelper.width(10)),
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.black,
                    size: ResponsiveHelper.iconSize(16),
                  ),
                  const SizedBox(width: 2),

                Flexible(
                  child: Text(
                    location.isEmpty ? 'N/A' : location,
                    style: context.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),

            // â”€â”€ Vehicle info card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (hasVehicleInfo) ...[
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey[50],
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(14),
                  ),
                  border: Border.all(color: AppColors.grey.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_filled_outlined,
                          size: ResponsiveHelper.iconSize(16),
                          color: AppColors.blue,
                        ),
                        SizedBox(width: ResponsiveHelper.width(6)),
                        Text(
                          AppStrings.vehicleDetails.tr,
                          style: context.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        if (profile.isVehicleVerified)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: ResponsiveHelper.iconSize(14),
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                AppStrings.verified.tr,
                                style: context.bodySmall.copyWith(
                                  color: AppColors.green,
                                  fontSize: ResponsiveHelper.fontSize(11),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(8)),
                    Wrap(
                      spacing: ResponsiveHelper.width(8),
                      runSpacing: ResponsiveHelper.height(6),
                      children: [
                        if (profile.vehicleType != null && profile.vehicleType!.isNotEmpty)
                          _InfoChip(
                            label: profile.vehicleType!,
                          ),
                        if (profile.vehicleModel != null && profile.vehicleModel!.isNotEmpty)
                          _InfoChip(
                            label: profile.vehicleModel!,
                          ),
                        if (profile.vehicleColor != null && profile.vehicleColor!.isNotEmpty)
                          _InfoChip(
                            label: profile.vehicleColor!,
                            dotColor: _colorFromName(profile.vehicleColor!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],



            SizedBox(height: ResponsiveHelper.spacing(20)),

            // â”€â”€ Start Chat / Rate Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(55),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (showRating) {
                    onRatingTap?.call();
                  }
                },
                icon: Icon(
                  showRating ? Icons.star_outline : Icons.chat_bubble_outline,
                  size: ResponsiveHelper.iconSize(20),
                ),
                label: Text(
                  showRating ? AppStrings.giveRating.tr : AppStrings.startChat.tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(15),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase().trim()) {
      case 'red':
        return AppColors.red;
      case 'blue':
        return AppColors.blue;
      case 'green':
        return AppColors.green;
      case 'black':
        return AppColors.black;
      case 'white':
        return AppColors.greyShade300;
      case 'yellow':
        return AppColors.yellow.shade700;
      case 'orange':
        return AppColors.orange;
      case 'grey':
      case 'gray':
        return AppColors.grey;
      case 'silver':
        return AppColors.greyShade400;
      default:
        return AppColors.grey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.dotColor});

  final String label;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.width(10),
        vertical: ResponsiveHelper.height(5),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: context.bodySmall.copyWith(
              fontSize: ResponsiveHelper.fontSize(11),
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey[50],
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: ResponsiveHelper.iconSize(18), color: AppColors.blue),
          SizedBox(height: ResponsiveHelper.spacing(4)),
          Text(
            value,
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: context.bodySmall.copyWith(
              color: AppColors.grey,
              fontSize: ResponsiveHelper.fontSize(10),
            ),
          ),
        ],
      ),
    );
  }
}

