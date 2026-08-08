import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/auth/view/widgets/custom_devider_or.dart';
import 'package:platchatapp/feature/auth/view/widgets/vehicle_model_field.dart';
import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/color_picker.dart';
import 'package:platchatapp/feature/profile/view/widgets/custom_upload_card.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_avater.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/profile_textfield.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle-owner.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_owner/vehicle_type_dropdown.dart';
import 'package:platchatapp/helper/common_container/common_container.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
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
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        title: Text(
          AppStrings.personalInfoTitle.tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.fontSize(18),
            color: AppColors.primaryText,
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
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: GetBuilder<ProfileController>(
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
                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  // ─── Profile Avatar ───────────────────────────────────────
                  ProfileAvatarWidget(controller: ctrl),

                  SizedBox(height: ResponsiveHelper.spacing(28)),

                  // ─── Nickname + License Number ────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppStrings.nickName.tr),
                            SizedBox(height: ResponsiveHelper.spacing(4)),
                            ProfileTextField(
                              controller: ctrl.nickNameController,
                              hintText: AppStrings.nickName.tr,
                              enabled: false, // Nickname কখনো edit হয় না
                              prefixIcon: _fieldIcon(AssetsPath.profileLogin),
                              prefixIconConstraints: _fieldIconConstraints,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.width(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppStrings.licenseNumberTitle.tr),
                            SizedBox(height: ResponsiveHelper.spacing(4)),
                            ProfileTextField(
                              controller: ctrl.licenseController,
                              hintText: AppStrings.licenseNumber1.tr,
                              enabled: false, // License কখনো edit হয় না
                              prefixIcon: _fieldIcon(
                                AssetsPath.licenseNumberSignUp,
                              ),
                              prefixIconConstraints: _fieldIconConstraints,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          prefixIcon: _fieldIcon(AssetsPath.emailSignUp),
                          prefixIconConstraints: _fieldIconConstraints,
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: ResponsiveHelper.spacing(28)),

                  // ─── Vehicle Details ──────────────────────────────────────
                  _sectionTitle(AppStrings.vehicleDetails.tr),
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  CommonContainer(
                    bgColor: const Color(0xFFD8E0EB),
                    borderRadius: 16,
                    horizontalPadding: 16,
                    verticalPadding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        SizedBox(height: ResponsiveHelper.spacing(16)),
                        Divider(color: AppColors.divider, height: 1),
                        SizedBox(height: ResponsiveHelper.spacing(16)),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(AppStrings.vehicleModel.tr),
                                  SizedBox(
                                    height: ResponsiveHelper.spacing(4),
                                  ),
                                  GetBuilder<ProfileController>(
                                    id: 'vehicle_fields',
                                    builder: (controler) =>
                                        VehicleModelDropdown(
                                          selectedModel:
                                              controler
                                                  .vehicleModelController
                                                  .text,
                                          onSelected: (value) =>
                                              controler.setVehicleModel(value),
                                          // Locked once already set; otherwise editable while in edit mode.
                                          enabled:
                                              controler.isEditing &&
                                              !controler.isVehicleModelLocked,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.width(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(AppStrings.vehicleColor.tr),
                                  SizedBox(
                                    height: ResponsiveHelper.spacing(4),
                                  ),
                                  GetBuilder<ProfileController>(
                                    id: 'vehicle_fields',
                                    builder: (controller) =>
                                        controller.isEditing
                                        ? VehicleColorPicker(
                                            controller: controller,
                                          )
                                        : _VehicleColorSummary(
                                            colorName: controller
                                                .vehicleColorController
                                                .text,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(28)),

                  Obx(() {
                    final uploadCtrl = Get.find<UploadDocumentController>();
                    if (!uploadCtrl.isFetching.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.spacing(8),
                      ),
                      child: const LinearProgressIndicator(minHeight: 3),
                    );
                  }),

                  // Text(
                  //   AppStrings.verifyAccountBecomeWheewer.tr,
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style:context.bodyMedium.copyWith(color:AppColors.black ),
                  // ),


                  _sectionTitle(AppStrings.verifyAccountBecomeWheewer.tr),
                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  ///owner ship document==========================================================
                 // _sectionTitle(AppStrings.vehicleOwnershipStatus.tr),
                  Text(
                    AppStrings.vehicleOwnershipStatus.tr,

                    style:context.bodySmall.copyWith(color:AppColors.greyText ),
                  ),


                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  const VehicleOwnershipStatusWidget(),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  CustomUploadCard(
                    title: AppStrings.vehicleOwnershipStatus.tr,
                    documentType: 'VEHICLE_OWNERSHIP',
                    iconPath: AssetsPath.ownerIcon,
                    isOwner: true,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(28)),

                  ///  Document Upload Section===========================================================
                  _sectionTitle(AppStrings.uploadDocuments.tr),

                  SizedBox(height: ResponsiveHelper.spacing(12)),

                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.containerGradient,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(14),
                      ),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: Column(
                      children: [
                        CustomUploadCard(
                          title: AppStrings.driversLicense.tr,
                          documentType: 'LICENSE',
                          iconPath: AssetsPath.driverIcon,
                          showCard: false,
                        ),
                        CustomDivider(),
                        CustomUploadCard(
                          title: AppStrings.carInspection.tr,
                          documentType: 'CAR_INSPECTION',
                          iconPath: AssetsPath.carInspectionIcon,
                          showCard: false,
                        ),
                    CustomDivider(),
                        CustomUploadCard(
                          title: AppStrings.carInsurance.tr,
                          documentType: 'INSURANCE',
                          iconPath: AssetsPath.carInsuranceIcon,
                          showCard: false,
                        ),
                       CustomDivider(),
                        CustomUploadCard(
                          title: AppStrings.carTax.tr,
                          documentType: 'TAX',
                          iconPath: AssetsPath.carTaxIcon,
                          showCard: false,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EFF9), // হালকা নীল ব্যাকগ্রাউন্ড কালার
                      borderRadius: BorderRadius.circular(12.0), // রাউন্ডেড কর্নার
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ওয়ার্নিং বা অ্যালার্ট আইকন
                        const Icon(
                          Icons.warning_rounded,
                          color: Color(0xFF1E6BBB), // টেক্সটের সাথে মিলানো নীল কালার
                          size: 20.0,
                        ),
                        SizedBox(width: ResponsiveHelper.width(10)),
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
      ),
    );
  }

  Widget _fieldIcon(String asset) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.padding(14),
        right: ResponsiveHelper.padding(8),
      ),
      child: CustomImage(
        imageSrc: asset,
        width: ResponsiveHelper.iconSize(14),
        height: ResponsiveHelper.iconSize(14),
      ),
    );
  }

  BoxConstraints get _fieldIconConstraints => BoxConstraints(
    minWidth: ResponsiveHelper.width(40),
    minHeight: ResponsiveHelper.height(16),
  );

  // Section label
  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: ResponsiveHelper.fontSize(13),
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: ResponsiveHelper.fontSize(16),
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    ),
  );
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.divider,
      indent: ResponsiveHelper.width(16),
      endIndent: ResponsiveHelper.width(16),
    );
  }
}

/// Compact "● Color Name" summary shown while not editing — the full swatch
/// grid (VehicleColorPicker) only appears in edit mode.
class _VehicleColorSummary extends StatelessWidget {
  final String colorName;

  const _VehicleColorSummary({required this.colorName});

  static const Map<String, Color> _swatches = {
    'Bianco': AppColors.bianco,
    'Nero': AppColors.nero,
    'Grigio / Argento': AppColors.grigioArgento,
    'Blu': AppColors.blu,
    'Rosso': AppColors.rosso,
    'Verde': AppColors.verde,
    'Marrone / Bronzo': AppColors.marroneBronzo,
  };

  @override
  Widget build(BuildContext context) {
    final bool hasColor = colorName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(14),
        vertical: ResponsiveHelper.padding(14),
      ),
      decoration: BoxDecoration(
        color: AppColors.greyShade.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
        border: Border.all(color: AppColors.greyShade),
      ),
      child: Row(
        children: [
          if (hasColor) ...[
            Container(
              width: ResponsiveHelper.iconSize(16),
              height: ResponsiveHelper.iconSize(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _swatches[colorName] ?? AppColors.grey,
                border: Border.all(color: AppColors.white, width: 1),
              ),
            ),
            SizedBox(width: ResponsiveHelper.width(8)),
          ],
          Expanded(
            child: Text(
              hasColor ? colorName : AppStrings.noVehicleColorTapEdit.tr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: hasColor ? AppColors.black87 : AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


