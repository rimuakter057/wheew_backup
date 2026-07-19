import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/auth/view/widgets/vehicle_model_field.dart';
import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/color_picker.dart';
import 'package:platchatapp/feature/profile/view/widgets/custom_upload_card.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_avater.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_textfield.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle-owner.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle_type_dropdown.dart';
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
          GetBuilder<ProfileController>(
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  controller.isEditing
                      ? controller.updateProfile()
                      : controller.toggleEdit();
                },
                child: Text(
                  controller.isEditing
                      ? AppStrings.save.tr
                      : AppStrings.edit.tr,
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

                _label(AppStrings.vehicleType.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields', // শুধু এই widget rebuild হবে
                  builder: (ctrl) => VehicleTypeDropdown(
                    controller: ctrl,
                    onSelected: (value) =>
                        ctrl.setVehicleType(value.backendKey),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label(AppStrings.vehicleModel.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controler) => VehicleModelDropdown(
                    selectedModel: controler.vehicleModelController.text,
                    onSelected: (value) => controler.setVehicleModel(value),
                    // Locked once already set; otherwise editable while in edit mode.
                    enabled: controler.isEditing && !controler.isVehicleModelLocked,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label(AppStrings.vehicleColor.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controller) => ProfileTextField(
                    controller: controller.vehicleColorController,
                    hintText: controller.vehicleColorController.text.isEmpty
                        ? AppStrings.noVehicleColorTapEdit.tr
                        : AppStrings.vehicleColor.tr,
                    // Locked once already set; otherwise editable while in edit mode.
                    enabled: controller.isEditing && !controller.isVehicleColorLocked,
                  ),
                ),

                _label(AppStrings.vehicleColor.tr),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                GetBuilder<ProfileController>(
                  id: 'vehicle_fields',
                  builder: (controller) =>
                      VehicleColorPicker(controller: controller),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                Obx(() {
                  final uploadCtrl = Get.find<UploadDocumentController>();
                  if (!uploadCtrl.isFetching.value)
                    return const SizedBox.shrink();
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
                    Expanded(
                      child: Text(
                        AppStrings.verifyAccountBecomeWheewer.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w400,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.spacing(18)),

                ///owner ship document==========================================================
                const VehicleOwnershipStatusWidget(),
                CustomUploadCard(
                  title: AppStrings.vehicleOwnershipStatus.tr,
                  documentType: 'VEHICLE_OWNERSHIP',
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

                CustomUploadCard(
                  title: AppStrings.driversLicense.tr,
                  documentType: 'LICENSE',
                  iconText: "🪪",
                ),

                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(
                  title: AppStrings.carInspection.tr,
                  documentType: 'CAR_INSPECTION',

                  iconText: "📋",
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),

                CustomUploadCard(
                  title: AppStrings.carInsurance.tr,
                  documentType: 'INSURANCE',
                  iconText: "📋",
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(
                  title: AppStrings.carTax.tr,
                  documentType: 'TAX',
                  iconText: "📋",
                ),

                SizedBox(height: ResponsiveHelper.spacing(12)),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE6EFF9,
                    ), // হালকা নীল ব্যাকগ্রাউন্ড কালার
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // রাউন্ডেড কর্নার
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .start,
                    children: [
                      // ওয়ার্নিং বা অ্যালার্ট আইকন
                      const Icon(
                        Icons.warning_rounded,
                        color: Color(
                          0xFF1E6BBB,
                        ), // টেক্সটের সাথে মিলানো নীল কালার
                        size: 20.0,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.height(24),
                      ),
                      // টেক্সট সেকশন
                      Expanded(
                        child: Text(
                          AppStrings.makeSureAllDocuments.tr,
                          style: context.bodySmall.copyWith(
                            color: AppColors.blue,
                          ),
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
