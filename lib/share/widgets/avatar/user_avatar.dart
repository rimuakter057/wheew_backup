import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/share/widgets/loading/loading_widget.dart';
import 'package:platchatapp/share/widgets/network_image/custom_network_image.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../core/service/api_url.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final bool isGroup;

  const UserAvatar({
    super.key,
    this.imagePath,
    this.radius = 20,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a network image
    if (imagePath != null &&
        (imagePath!.startsWith('http') || imagePath!.startsWith('uploads'))) {
      final String imageUrl = imagePath!.startsWith('http')
          ? imagePath!
          : '${ApiUrl.baseUrl}/$imagePath';

      return CircleAvatar(
        backgroundColor: AppColors.greyBorder,
        radius: radius,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => const LoadingWidget(
              color: AppColors.greyBg,
            ), // CircularProgressIndicator(),
            errorWidget: (context, url, error) => isGroup
                ? _groupIcon()
                : CustomNetworkImage(imageUrl: AppConst.unknown),
          ),
        ),
      );
    }

    // Local asset or default
    return CircleAvatar(
      radius: radius,
      backgroundColor: isGroup ? AppColors.softBrandColor : AppColors.greyBorder,
      child: imagePath != null && imagePath!.endsWith('.svg')
          ? SvgPicture.asset(
        imagePath!,
        width: radius,
        height: radius,
      )
          : (isGroup ? _groupIcon() : CustomImage(imageSrc: AppConst.unknown)),
    );
  }

  Widget _groupIcon() {
    return SvgPicture.asset(
      AssetsPath.groupChat,
      width: radius * 0.4,
      height: radius * 0.4,
    );
  }
}


