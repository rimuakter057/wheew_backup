
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
import 'package:platchatapp/feature/auth/view/widgets/vehicle_model_field.dart';
import 'package:platchatapp/feature/auth/view/widgets/vihele_type.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import 'widgets/vehicle_color_picker.dart';

import 'widgets/vehicle_submit_button.dart';


class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late final VehicleController controller;

  /// color select===========================
  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Blu', 'color': AppColors.vehicleColorBlu},
    {'name': 'Arancione', 'color': AppColors.vehicleColorArancione},
    {'name': 'Rosso', 'color': AppColors.vehicleColorRosso},
    {'name': 'Nero', 'color': AppColors.vehicleColorNero},
    {'name': 'Grigio / Argento', 'color': AppColors.vehicleColorGrigioArgento},
    {'name': 'Bianco', 'color': AppColors.vehicleColorBianco},
  ];

  final List<Map<String, dynamic>> borderColorOptions = [
    {'name': 'Blu', 'color': AppColors.vehicleColorBluBorder},
    {'name': 'Arancione', 'color': AppColors.vehicleColorArancioneBorder},
    {'name': 'Rosso', 'color': AppColors.vehicleColorRossoBorder},
    {'name': 'Nero', 'color': AppColors.vehicleColorNeroBorder},
    {'name': 'Grigio / Argento', 'color': AppColors.vehicleColorGrigioArgentoBorder},
    {'name': 'Bianco', 'color': AppColors.vehicleColorBiancoBorder},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(VehicleController(), permanent: false);
  }

  @override
  void dispose() {
    Get.delete<VehicleController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveHelper.height(8)),
                  _buildTopBar(context),
                  SizedBox(height: ResponsiveHelper.spacing(20)),
                  _buildHeading(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildTypeWheel(),
                  SizedBox(height: ResponsiveHelper.spacing(28)),

                  ///vihecle model ========
                  _buildFieldLabel(AppStrings.vehicleModel.tr),
                  SizedBox(height: ResponsiveHelper.height(10)),
                  _buildModelField(),

                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  ///vihecle color ========
                  _buildFieldLabel(AppStrings.vehicleColor.tr),
                  SizedBox(height: ResponsiveHelper.height(12)),
                  _buildColorPicker(),

                  SizedBox(height: ResponsiveHelper.spacing(40)),

                  ///submit button=================================
                  _buildSubmitButton(),
                  SizedBox(height: ResponsiveHelper.height(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  ///top bar (back + skip)===================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: ResponsiveHelper.width(40),
            height: ResponsiveHelper.height(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.black87),
          ),
        ),
        TextButton(
          onPressed: () => context.go(RoutePath.mainNavScreen),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.white.withValues(alpha: 0.6),
            padding: ResponsiveHelper.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
            ),
          ),
          child: Text(
            AppStrings.skip.tr,
            style: context.bodyMedium.copyWith(
              color: AppColors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  ///heading + subtitle===================
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addYourVehicle.tr,
            style: context.titleLarge.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: ResponsiveHelper.height(6)),
          Text(
            AppStrings.addYourVehicleSubtitle.tr,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.black.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  ///vehicle type============================

  Widget _buildTypeWheel() {
    return Obx(
          () => VehicleTypeWheel(
        types: controller.vehicleTypes,
        selected: controller.selectedType.value,
        onSelected: (type) => controller.selectedType.value = type,
      ),
    );
  }


///build field label=========================

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: context.bodyLarge.copyWith(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ///build vehicle model===============

  Widget _buildModelField() {
    return Obx(
          () => VehicleModelDropdown(
        selectedModel: controller.selectedVehicleModel.value,
        onSelected: (model) => controller.selectedVehicleModel.value = model,
      ),
    );
  }

  ///build color picker=================================

  Widget _buildColorPicker() {
    return Obx(
          () => VehicleColorPicker(
        colorOptions: colorOptions,
        borderColorOptions: borderColorOptions,
        selectedColorName: controller.selectedColor.value,
        onSelected: (name) => controller.selectedColor.value = name,
      ),
    );
  }

  ///build submit button====================================

  Widget _buildSubmitButton() {
    return Obx(
          () => VehicleSubmitButton(
        isLoading: controller.isLoading.value,
        label: AppStrings.submitDetails.tr,
        onPressed: () => controller.submitVehicle(context: context),
      ),
    );
  }
}

