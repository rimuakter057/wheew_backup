
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
import 'package:platchatapp/feature/auth/view/widgets/background_container.dart';
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
    {'name': 'Blu', 'color': AppColors.blu},
    {'name': 'Nero', 'color': AppColors.nero},
    {'name': 'Grigio / Argento', 'color': AppColors.grigioArgento},
    {'name': 'Bianco', 'color': AppColors.bianco},
    {'name': 'Rosso', 'color': AppColors.rosso},
    {'name': 'Verde', 'color': AppColors.verde},
    {'name': 'Marrone / Bronzo', 'color': AppColors.marroneBronzo},
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
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
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
                  SizedBox(height: ResponsiveHelper.height(10)),
                  _buildTypeWheel(),
                  SizedBox(height: ResponsiveHelper.spacing(30)),
                  ///vihecle model and color ========
                  _buildSectionTitle(),
                  SizedBox(height: ResponsiveHelper.height(16)),

                  ///vihecle model and color ========
                  CustomBackgroundContainer(
                    child: Column(
                      children: [
                        _buildModelField(),
                        _buildColorPicker(),
                      ],
                    ),
                  ),

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


  ///app bar===================
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title:  Text(
        "Add Your Vehicle",
        style: context.bodyLarge.copyWith(color: AppColors.black,fontWeight: FontWeight.w600)
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton(
            onPressed: () => context.go(RoutePath.mainNavScreen),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
            ),
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


///build title text=========================


  Widget _buildSectionTitle() {
    return Text(
      "Vehicle Model & Color",
      style: context.bodyLarge.copyWith(color: AppColors.black)
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
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.vehicleColor.tr,
            style: context.bodyLarge.copyWith(color: AppColors.black)
          ),
          SizedBox(height: ResponsiveHelper.height(12)),
          VehicleColorPicker(
            colorOptions: colorOptions,
            selectedColorName: controller.selectedColor.value,
            onSelected: (name) => controller.selectedColor.value = name,
          ),
        ],
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