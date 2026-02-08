// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// import 'package:platchatapp/helper/image_handler/image_handler.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class ProfileAvatarWidget extends StatelessWidget {
//   final String imagePath;
//   final Color? borderColor;
//   final double? heightA;
//   final double? widthA;
//   //final bool enableEdit; // enable edit icon
//  // final VoidCallback? onEdit; // callback on edit tap
//  // final String editIconAsset;
//   final bool? isFile;
//
//   const ProfileAvatarWidget({
//     super.key,
//     required this.imagePath,
//     this.borderColor,
//     this.heightA,
//     this.widthA,
//     //this.enableEdit = false,
//     //this.onEdit,
//   //  this.editIconAsset = "assets/icon/edit_profile_camera.svg",
//     this.isFile = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final double avatarHeight = ResponsiveHelper.height(80);
//     final double avatarWidth =ResponsiveHelper.width(80);
//
//     return SizedBox(
//       height: heightA ?? avatarHeight,
//       width: widthA ?? avatarWidth,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Circular profile image
//           Container(
//             height: heightA ?? avatarHeight,
//             width: widthA ?? avatarWidth,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: borderColor ?? AppColors.greyShade,
//                 width: ResponsiveHelper.width(2),
//               ),
//               color: Colors.white,
//             ),
//             child: ClipOval(
//               child:
//               !isFile!
//                   ? CachedNetworkImage(
//                 imageUrl: ImageHandler.imagesHandle(imagePath),
//                 width: avatarHeight,
//                 height: avatarWidth,
//                 fit: BoxFit.cover,
//               )
//                   : Image.file(
//                 File(imagePath),
//                 width: avatarHeight,
//                 height: avatarWidth,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
