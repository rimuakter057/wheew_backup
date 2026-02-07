import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/service/api_url.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;

  const UserAvatar({
    super.key,
    this.imagePath,
    this.radius = 30,
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
        radius: radius,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.person),
          ),
        ),
      );
    }

    // Local asset or default
    return CircleAvatar(
      radius: radius,
      backgroundImage: imagePath != null
          ? AssetImage(imagePath!)
          : null,
      child: imagePath == null ? const Icon(Icons.person) : null,
    );
  }
}