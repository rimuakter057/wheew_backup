// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
// import 'package:platchatapp/feature/profile/view/widgets/custom_upload_card.dart';
// import '../../../../helper/responsive_helper/responsive_helper.dart';
// import '../../../../utils/color/app_colors.dart';
// import '../../repository/profile_controller.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   late ProfileController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(ProfileController());
//     if (!Get.isRegistered<UploadDocumentController>()) {
//       Get.put(UploadDocumentController());
//     }
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.reloadProfile();
//       Get.find<UploadDocumentController>().fetchDocuments(context: context);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'profile'.tr,
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w500,
//             fontSize: ResponsiveHelper.fontSize(18),
//           ),
//         ),
//         actions: [
//           GetBuilder<ProfileController>(
//             builder: (controller) {
//               return TextButton(
//                 onPressed: () {
//                   controller.isEditing
//                       ? controller.updateProfile()
//                       : controller.toggleEdit();
//                 },
//                 child: Text(
//                   controller.isEditing ? 'save'.tr : 'edit'.tr,
//                   style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: GetBuilder<ProfileController>(
//         builder: (controller) {
//           if (controller.isLoading && controller.userProfile.value == null) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return SingleChildScrollView(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(24),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: ResponsiveHelper.spacing(24)),
//
//                 /// Profile Image - Fixed circular display
//                 Center(
//                   child: Obx(() {
//                     final avatar = controller.userProfile.value?.avatar;
//                     return GestureDetector(
//                       onTap: () {
//                         final image =
//                             controller
//                                 .tempCroppedImage
//                                 .value
//                                 ?.path ?? // ✅ tempCroppedImage
//                             controller.userProfile.value?.avatar;
//
//                         if (image != null && image.isNotEmpty) {
//                           context.pushNamed(
//                             RouteName.showProfile,
//                             extra: image,
//                           );
//                         }
//                       },
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: ResponsiveHelper.iconSize(90),
//                             height: ResponsiveHelper.iconSize(90),
//                             child: ClipOval(
//                               child:
//                                   controller.tempCroppedImage.value !=
//                                       null // ✅ tempCroppedImage
//                                   ? Image.file(
//                                       controller
//                                           .tempCroppedImage
//                                           .value!, // ✅ tempCroppedImage
//                                       width: ResponsiveHelper.iconSize(90),
//                                       height: ResponsiveHelper.iconSize(90),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : avatar != null && avatar.isNotEmpty
//                                   ? Image.network(
//                                       avatar,
//                                       width: ResponsiveHelper.iconSize(90),
//                                       height: ResponsiveHelper.iconSize(90),
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, _, _) => Container(
//                                         width: ResponsiveHelper.iconSize(90),
//                                         height: ResponsiveHelper.iconSize(90),
//                                         color: AppColors.greyShade,
//                                         child: Icon(
//                                           Icons.person,
//                                           size: ResponsiveHelper.iconSize(45),
//                                           color: AppColors.blue,
//                                         ),
//                                       ),
//                                     )
//                                   : Container(
//                                       width: ResponsiveHelper.iconSize(90),
//                                       height: ResponsiveHelper.iconSize(90),
//                                       color: AppColors.greyShade,
//                                       child: Icon(
//                                         Icons.person,
//                                         size: ResponsiveHelper.iconSize(45),
//                                         color: AppColors.blue,
//                                       ),
//                                     ),
//                             ),
//                           ),
//
//                           if (controller.isEditing)
//                             GestureDetector(
//                               onTap: controller.pickImageFromGallery,
//                               child: Container(
//                                 padding: EdgeInsets.all(
//                                   ResponsiveHelper.padding(6),
//                                 ),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black26,
//                                       blurRadius: 4,
//                                       offset: Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.camera_alt_outlined,
//                                   size: ResponsiveHelper.iconSize(18),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(32)),
//
//                 _label('nick_name'.tr),
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//                 _textField(
//                   controller: controller.nickNameController,
//                   hintText: 'nick_name'.tr,
//                   enabled: false,
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 _label('license_number_title'.tr),
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//                 _textField(
//                   controller: controller.licenseController,
//                   hintText: 'license_number1'.tr,
//                   enabled: false,
//                 ),
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//                 Obx(() {
//                   final email = controller.userProfile.value?.email ?? '';
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _label('Email'),
//                       SizedBox(height: ResponsiveHelper.spacing(4)),
//                       _textField(
//                         controller: TextEditingController(text: email),
//                         hintText: 'Email',
//                         enabled: false,   // email kokhono edit hoy na
//                       ),
//                       SizedBox(height: ResponsiveHelper.spacing(20)),
//                     ],
//                   );
//                 }),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 _label('Vehicle Type'),
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//                 GetBuilder<ProfileController>(
//                   builder: (controller) {
//                     return DropdownButtonFormField<String>(
//                       value: controller.vehicleTypeController.text.isEmpty
//                           ? null
//                           : controller.vehicleTypeController.text,
//                       decoration: InputDecoration(
//                         hintText: 'Vehicle Type',
//                         filled: true,
//                         fillColor: controller.isEditing ? AppColors.white : AppColors.greyShade.withOpacity(0.3),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//                           borderSide: BorderSide(color: AppColors.greyShade),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//                           borderSide: BorderSide(color: AppColors.greyShade),
//                         ),
//                         disabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//                           borderSide: BorderSide(color: AppColors.greyShade),
//                         ),
//                       ),
//                       items: ['CAR', 'MOTORCYCLE', 'VAN', 'OTHER']
//                           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                           .toList(),
//                       onChanged: controller.isEditing
//                           ? (val) {
//                         controller.vehicleTypeController.text = val ?? '';
//                       }
//                           : null,
//                     );
//                   },
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 _label('Vehicle Model'),
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//                 _textField(
//                   controller: controller.vehicleModelController,
//                   hintText: 'Vehicle Model',
//                   enabled: controller.isEditing,
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 _label('Vehicle Color'),
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//                 _textField(
//                   controller: controller.vehicleColorController,
//                   hintText: 'Vehicle Color',
//                   enabled: controller.isEditing,
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//
// ///=============================================================
//
//
//
//
//
//
//
//                 ///vehicle ownership status=========================
//                 _label('Vehicle Ownership status'),
//                 SizedBox(height: ResponsiveHelper.spacing(6)),
//
//                 ///vehicle  --------================================
//                 GetBuilder<ProfileController>(
//                   builder: (controller) {
//                     final user = controller.userProfile.value;
//
//                     final isSubmitted =
//                         user?.isVehicleOwnershipDocumentSubmitted == true;
//                     final isVerified = user?.isVehicleVerified == true;
//
//                     debugPrint('submitted: $isSubmitted');
//                     debugPrint('verified: $isVerified');
//
//                     String message;
//                     Color color;
//                     Color bgColor;
//                     IconData icon;
//
//                     if (isSubmitted && isVerified) {
//                       message = 'Vehicle verified successfully';
//                       color = AppColors.blue;
//                       bgColor = AppColors.blue.withOpacity(0.1);
//                       icon = Icons.verified;
//                     } else if (isSubmitted && !isVerified) {
//                       message = 'Document submitted, waiting for verification';
//                       color = AppColors.chargingGreen;
//                       bgColor = AppColors.chargingGreen.withOpacity(0.1);
//                       icon = Icons.hourglass_bottom;
//                     } else {
//                       message =
//                           'Not verified (please submit vehicle ownership document)';
//                       color = Colors.red;
//                       bgColor = Colors.red.withOpacity(0.1);
//                       icon = Icons.info_outline;
//                     }
//
//                     return Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: bgColor,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: color.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(icon, color: color, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               message,
//                               style: TextStyle(color: color, fontSize: 14),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//
//                 // Container(
//                 //   width: double.infinity,
//                 //   padding: EdgeInsets.all(12),
//                 //   decoration: BoxDecoration(
//                 //     color: Colors.red.withOpacity(0.1),
//                 //     borderRadius: BorderRadius.circular(8),
//                 //     // এখানে ভুল হয়েছিল, নিচে সঠিক কোডটি দেওয়া হলো:
//                 //     border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 //   ),
//                 //   child: Row(
//                 //     crossAxisAlignment: CrossAxisAlignment.start,
//                 //     children: [
//                 //       Icon(Icons.info_outline, color: Colors.red, size: 20),
//                 //       SizedBox(width: 8),
//                 //       Expanded(
//                 //         child: Text(
//                 //           'Not verified (because the vehicle ownership document has not been registered)',
//                 //           style: TextStyle(
//                 //             color: Colors.red[700],
//                 //             fontSize: 14,
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//
//
//
//                 ///==================================================================
//                 Text(
//                   'upload_documents'.tr,
//                   textAlign: TextAlign.start,
//                   style: GoogleFonts.poppins(
//                     fontSize: ResponsiveHelper.fontSize(16),
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textBlack,
//                   ),
//                 ),
//
//                 Obx(() {
//                   final uploadCtrl = Get.find<UploadDocumentController>();
//                   if (!uploadCtrl.isFetching.value) {
//                     return const SizedBox.shrink();
//                   }
//                   return Padding(
//                     padding: EdgeInsets.only(
//                       top: ResponsiveHelper.spacing(12),
//                       bottom: ResponsiveHelper.spacing(8),
//                     ),
//                     child: const LinearProgressIndicator(minHeight: 3),
//                   );
//                 }),
//
//                 SizedBox(height: ResponsiveHelper.spacing(18)),
//
//                 CustomUploadCard(
//                   title: "VEHICLE OWNERSHIP",
//                   documentType: 'VEHICLE_OWNERSHIP',
//                 ),
//                 SizedBox(height: ResponsiveHelper.spacing(12)),
//                 CustomUploadCard(
//                   title: "CAR INSPECTION",
//                   documentType: 'CAR_INSPECTION',
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(12)),
//                 CustomUploadCard(
//                   title: 'drivers_license'.tr,
//                   documentType: 'LICENSE',
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(12)),
//
//                 CustomUploadCard(
//                   title: 'car_insurance'.tr,
//                   documentType: 'INSURANCE',
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(12)),
//
//                 CustomUploadCard(title: 'car_tax'.tr, documentType: 'TAX'),
//                 SizedBox(height: ResponsiveHelper.spacing(78)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _label(String text) => Align(
//     alignment: Alignment.centerLeft,
//     child: Text(
//       text,
//       style: GoogleFonts.poppins(
//         fontSize: ResponsiveHelper.fontSize(16),
//         fontWeight: FontWeight.w400,
//         color: AppColors.textBlack,
//       ),
//     ),
//   );
//
//   Widget _textField({
//     required TextEditingController controller,
//     required String hintText,
//     bool enabled = true,
//   }) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
//         filled: true,
//         // _textField এ fillColor ঠিক করো
//         fillColor: enabled ? AppColors.white : AppColors.greyShade.withOpacity(0.3),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(
//             ResponsiveHelper.borderRadius(12),
//           ),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(
//             ResponsiveHelper.borderRadius(12),
//           ),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(
//             ResponsiveHelper.borderRadius(12),
//           ),
//           borderSide: BorderSide(color: AppColors.greyShade, width: 1),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(
//             ResponsiveHelper.borderRadius(12),
//           ),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/color_picker.dart';
import 'package:platchatapp/feature/profile/view/widgets/custom_upload_card.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_avater.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_textfield.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle-owner.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle_type_dropdown.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../utils/color/app_colors.dart';
import '../../../../utils/language/app_string.dart';
import '../../repository/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;

  // @override
  // void initState() {
  //   super.initState();
  //   controller = Get.put(ProfileController());
  //
  //   // UploadDocumentController শুধু একবার register করো
  //   if (!Get.isRegistered<UploadDocumentController>()) {
  //     Get.put(UploadDocumentController());
  //   }
  //
  //   // Screen load হলে profile ও documents fetch করো
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     controller.reloadProfile();
  //     Get.find<UploadDocumentController>().fetchDocuments(context: context);
  //   });
  // }




  @override
  void initState() {
    super.initState();


    controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    if (!Get.isRegistered<UploadDocumentController>()) {
      Get.put(UploadDocumentController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reloadProfile();
      Get.find<UploadDocumentController>().fetchDocuments(context: context);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppStrings.profile.tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        actions: [
          // Edit / Save button — isEditing এর উপর নির্ভর করে
          GetBuilder<ProfileController>(
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  controller.isEditing ? controller.updateProfile() : controller.toggleEdit();
                },
                child: Text(
                  controller.isEditing ? AppStrings.save.tr : AppStrings.edit.tr,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        builder: (ctrl) {
          // Profile load হওয়া পর্যন্ত loading দেখাও
          if (ctrl.isLoading && ctrl.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveHelper.spacing(24)),

                // ─── Profile Avatar ───────────────────────────────────────
                ProfileAvatarWidget(controller: ctrl),

                SizedBox(height: ResponsiveHelper.spacing(32)),

                // ─── Read-only fields ─────────────────────────────────────

                _label(AppStrings.nickName.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                ProfileTextField(
                  controller: ctrl.nickNameController,
                  hintText: AppStrings.nickName.tr,
                  enabled: false, // Nickname কখনো edit হয় না
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label(AppStrings.licenseNumberTitle.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                ProfileTextField(
                  controller: ctrl.licenseController,
                  hintText: AppStrings.licenseNumber1.tr,
                  enabled: false, // License কখনো edit হয় না
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // Email — Obx দিয়ে কারণ userProfile reactive
                Obx(() {
                  final email = ctrl.userProfile.value?.email ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(AppStrings.email.tr),
                      SizedBox(height: ResponsiveHelper.spacing(4)),
                      ProfileTextField(
                        controller: TextEditingController(text: email),
                        hintText: AppStrings.email.tr,
                        enabled: false, // Email কখনো edit হয় না
                      ),
                    ],
                  );
                }),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // ─── Editable Vehicle fields ──────────────────────────────

                // Vehicle Type — Dropdown (CAR / MOTORCYCLE / VAN / OTHER)
               // _label(AppStrings.vehicleType.tr),
                _label(AppStrings.vehicleType.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields', // শুধু এই widget rebuild হবে
                  builder: (ctrl) => VehicleTypeDropdown(controller: ctrl,
                    onSelected: (value) => ctrl.setVehicleType(value.backendKey),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),


                // 👁️ Vehicle Model — READ ONLY (client request অনুযায়ী edit বন্ধ)
                // এখানে enabled সবসময় false, isEditing হলেও change হবে না
                _label(AppStrings.vehicleModel.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controller) => ProfileTextField(
                    controller: controller.vehicleModelController,
                    hintText: controller.vehicleModelController.text.isEmpty
                        ? AppStrings.noVehicleModelTapEdit.tr
                        : AppStrings.vehicleModel.tr,
                    enabled: false, // ✅ সবসময় read-only, isEditing দিয়ে control হচ্ছে না
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // 👁️ Vehicle Color — READ ONLY (client request অনুযায়ী edit বন্ধ)
                _label(AppStrings.vehicleColor.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controller) => ProfileTextField(
                    controller: controller.vehicleColorController,
                    hintText: controller.vehicleColorController.text.isEmpty
                        ? AppStrings.noVehicleColorTapEdit.tr
                        : AppStrings.vehicleColor.tr,
                    enabled: false, // ✅ সবসময় read-only
                  ),
                ),




                // Vehicle Model — free text
              //   _label(AppStrings.vehicleModel.tr),
              // //  _label("Vehicle Model"),
              //   SizedBox(height: ResponsiveHelper.spacing(4)),
              //   GetBuilder<ProfileController>(
              //     id: 'vehicle_fields', // type করলে পুরো screen rebuild হবে না
              //     builder: (controller) => ProfileTextField(
              //       controller: controller.vehicleModelController,
              //       hintText: ctrl.vehicleModelController.text.isEmpty && !ctrl.isEditing
              //           ? AppStrings.noVehicleModelTapEdit.tr
              //           : AppStrings.vehicleModel.tr,
              //       enabled: controller.isEditing,
              //     ),
              //   ),
              //
              //   SizedBox(height: ResponsiveHelper.spacing(20)),
              //
              //   // Vehicle Color — free text
              // //  _label(AppStrings.vehicleColor.tr),
              //  // // _label("Vehicle Color"),
              //  //  SizedBox(height: ResponsiveHelper.spacing(4)),
              //  //  GetBuilder<ProfileController>(
              //  //    id: 'vehicle_fields',
              //  //    builder: (controller) => ProfileTextField(
              //  //      controller: controller.vehicleColorController,
              //  //      hintText: ctrl.vehicleModelController.text.isEmpty && !ctrl.isEditing
              //  //          ? AppStrings.noVehicleColorTapEdit.tr
              //  //          : AppStrings.vehicleColor.tr,
              //  //      enabled: controller.isEditing,
              //  //    ),
              //  //  ),
              //
              //
                _label(AppStrings.vehicleColor.tr),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controller) => VehicleColorPicker(controller: controller),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // ─── Vehicle Ownership Status ─────────────────────────────

              //  SizedBox(height: ResponsiveHelper.spacing(6)),
             //   const VehicleOwnershipStatusWidget(),




                // Document fetch হওয়ার সময় progress bar
                Obx(() {
                  final uploadCtrl = Get.find<UploadDocumentController>();
                  if (!uploadCtrl.isFetching.value) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(
                      top: ResponsiveHelper.spacing(12),
                      bottom: ResponsiveHelper.spacing(8),
                    ),
                    child: const LinearProgressIndicator(minHeight: 3),
                  );
                }),

               // SizedBox(height: ResponsiveHelper.spacing(18)),



                Row(
                  children: [
                    Text(
                      AppStrings.vehicleOwnershipStatus.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(16),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textBlack,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    // GestureDetector(
                    //     onTap: (){
                    //       showDialog(
                    //         context: context,
                    //         builder: (context) {
                    //           return AlertDialog(
                    //         //    contentPadding: EdgeInsets.zero,
                    //             content: const VehicleOwnershipStatusWidget(),
                    //           );
                    //         },
                    //       );
                    //     },
                    //     child: CustomImage(imageSrc: AssetsPath.info,imageColor: AppColors.black,))
                  ],
                ),


                SizedBox(height: ResponsiveHelper.spacing(18)),
///owner ship document==========================================================

                const VehicleOwnershipStatusWidget(),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                // প্রতিটি document type আলাদা card
                CustomUploadCard(title: AppStrings.vehicleOwnershipStatus.tr, documentType: 'VEHICLE_OWNERSHIP',
                  iconText: "📋",
                  isOwner: true,

                  //  iconPath: AssetsPath.otherUpload,
                ),


                SizedBox(height: ResponsiveHelper.spacing(32)),



                ///  Document Upload Section===========================================================
                Text(
                  AppStrings.uploadDocuments.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(12)),

                CustomUploadCard(title: AppStrings.driversLicense.tr, documentType: 'LICENSE',
                  iconText: "🪪",
                ),

                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(title: AppStrings.carInspection.tr, documentType: 'CAR_INSPECTION',

                  iconText: "📋",
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                // CustomUploadCard(title: AppStrings.driversLicense.tr, documentType: 'LICENSE',
                //   iconText: "🪪",
                // ),
               // SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(title: AppStrings.carInsurance.tr, documentType: 'INSURANCE',
                  iconText: "📋",
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(title: AppStrings.carTax.tr, documentType: 'TAX',
                  iconText: "📋",
                ),


                SizedBox(height: ResponsiveHelper.spacing(12)),


                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EFF9), // হালকা নীল ব্যাকগ্রাউন্ড কালার
                    borderRadius: BorderRadius.circular(12.0), // রাউন্ডেড কর্নার
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // আইকন এবং টেক্সট যেন ওপর থেকে শুরু হয়
                    children: [
                      // ওয়ার্নিং বা অ্যালার্ট আইকন
                      const Icon(
                        Icons.warning_rounded,
                        color: Color(0xFF1E6BBB), // টেক্সটের সাথে মিলানো নীল কালার
                        size: 20.0,
                      ),
                       SizedBox(height: ResponsiveHelper.height(24)), // আইকন এবং টেক্সটের মাঝের গ্যাপ

                      // টেক্সট সেকশন
                       Expanded(
                        child: Text(
                       AppStrings.makeSureAllDocuments.tr,
                          style: context.bodySmall.copyWith(color: AppColors.blue)
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(78)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Section label
  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: ResponsiveHelper.fontSize(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      ),
    ),
  );
}
