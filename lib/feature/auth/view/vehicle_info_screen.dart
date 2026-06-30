import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';

import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../repository/country_list.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late final VehicleController controller;

  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Bianco', 'color': const Color(0xFFF4F4F2)},
    {'name': 'Nero', 'color': const Color(0xFF1B1B1D)},
    {'name': 'Grigio', 'color': const Color(0xFF6E7074)},
    {'name': 'Blu', 'color': const Color(0xFF2C3E5C)},
    {'name': 'Rosso', 'color': const Color(0xFFB11724)},
    {'name': 'Bianco2', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(VehicleController(), permanent: false); // ✅ initState এ put করুন
  }

  @override
  void dispose() {
    Get.delete<VehicleController>(force: true); // ✅ এটাই মূল fix
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuController = MenuController();
    InputDecoration customInputDecoration({
      required String labelText,
      IconData? prefixIcon,
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.fontSize(14),
          color: Colors.grey[600],
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.blue, size: 22)
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical: ResponsiveHelper.padding(16),
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Vehicle Info",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => context.go(RoutePath.mainNavScreen),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.blue.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.blue,
              ),
              label: const Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Let's add your vehicle",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.height(6)),
                Text(
                  "Please fill out the details below to proceed.",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: ResponsiveHelper.height(30)),

                /// TYPE DROPDOWN (Professional Modern UI)
                /// TYPE DROPDOWN (Professional Box UI with controlled width)
                /// TYPE DROPDOWN (Controlled Width & Professional UI)
                /// TYPE DROPDOWN (Fixed Menu Width 200)
                // Obx(() => DropdownButtonFormField<VehicleType>(
                //   value: controller.selectedType.value,
                //   hint: Text(
                //     "Select Vehicle Type",
                //     style: TextStyle(
                //       fontSize: ResponsiveHelper.fontSize(14),
                //       color: Colors.grey[600],
                //     ),
                //   ),
                //   isExpanded: true, // এটি ইনপুট বক্সের ভেতরের টেক্সটকে ফুল উইডথ দেবে
                //   icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 24),
                //   dropdownColor: Colors.white,
                //   menuMaxHeight: 300,
                //   borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
                //   decoration: customInputDecoration(
                //     labelText: AppStrings.vehicleType.tr,
                //   ),
                //   style: TextStyle(
                //     fontSize: ResponsiveHelper.fontSize(14),
                //     color: Colors.black87,
                //   ),
                //   selectedItemBuilder: (context) {
                //     return controller.vehicleTypes.map((type) {
                //       return Row(
                //         children: [
                //           SvgPicture.asset(
                //             type.icon,
                //             width: 22,
                //             height: 22,
                //             colorFilter: const ColorFilter.mode(
                //                 AppColors.black, BlendMode.srcIn),
                //           ),
                //           SizedBox(width: ResponsiveHelper.width(12)),
                //           Text(
                //             type.displayName,
                //             style: TextStyle(
                //               fontSize: ResponsiveHelper.fontSize(14),
                //               color: Colors.black87,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ],
                //       );
                //     }).toList();
                //   },
                //   items: controller.vehicleTypes.map((type) {
                //     return DropdownMenuItem<VehicleType>(
                //       value: type,
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Container(
                //
                //             padding: const EdgeInsets.all(8),
                //             decoration: BoxDecoration(
                //               color: Colors.grey[100],
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //             child: SvgPicture.asset(
                //               type.icon,
                //               width: 20,
                //               height: 20,
                //               colorFilter: const ColorFilter.mode(
                //                   Colors.black87, BlendMode.srcIn),
                //             ),
                //           ),
                //           SizedBox(width: ResponsiveHelper.width(12)),
                //           Expanded(
                //             child: Text(
                //               type.displayName,
                //               style: TextStyle(
                //                 fontSize: ResponsiveHelper.fontSize(14),
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.black87,
                //               ),
                //               maxLines: 1,
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     if (value != null) controller.selectedType.value = value;
                //   },
                // )),


              Obx(
                    () => PopupMenuButton<VehicleType>(
                      offset: const Offset(120, 0), // ডানে সরাবে
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 200,
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    controller.selectedType.value = value;
                  },
                  itemBuilder: (context) {
                    return controller.vehicleTypes.map((type) {
                      return PopupMenuItem<VehicleType>(
                        value: type,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              type.icon,
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.black87,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                type.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: InputDecorator(
                    decoration: customInputDecoration(
                      labelText: AppStrings.vehicleType.tr,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: controller.selectedType.value == null
                              ? Text(
                            "Select Vehicle Type",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: ResponsiveHelper.fontSize(14),
                            ),
                          )
                              : Row(
                            children: [
                              SvgPicture.asset(
                                controller.selectedType.value!.icon,
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black87,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.selectedType.value!.displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.fontSize(14),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
              ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                /// MODEL
                Obx(
                      () => PopupMenuButton<String>(
                        offset: const Offset(150, 0),
                    constraints:  BoxConstraints(
                      minWidth:  ResponsiveHelper.height(200),
                      maxWidth:  ResponsiveHelper.width(220),
                      maxHeight: ResponsiveHelper.height(450),
                      minHeight: ResponsiveHelper.height(350),
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (value) {
                      controller.selectedVehicleModel.value = value;

                    },
                    itemBuilder: (context) {
                      return vehicleModels.map((model) {
                        return PopupMenuItem<String>(
                          value: model,
                          child: Text(
                            model,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();
                    },
                    child: InputDecorator(
                      decoration: customInputDecoration(
                        labelText: AppStrings.vehicleModel.tr,
                        prefixIcon: Icons.model_training_rounded,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedVehicleModel.value.isEmpty
                                  ? "Select Vehicle Model"
                                  : controller.selectedVehicleModel.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(14),
                                color: controller.selectedVehicleModel.value.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: controller.selectedVehicleModel.value.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                /// COLOR CHIPS
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.vehicleColor.tr,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.height(12)),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colorOptions.map((c) {
                        final bool isSelected =
                            controller.selectedColor.value == c['name'];
                        return GestureDetector(
                          onTap: () =>
                          controller.selectedColor.value = c['name'],
                          child: Tooltip(
                            message: c['name'],
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c['color'],
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.blue
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: AppColors.blue
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                                    : [],
                              ),
                              child: isSelected
                                  ? Icon(
                                Icons.check,
                                color: c['name'] == 'Bianco' ||
                                    c['name'] == 'Bianco2'
                                    ? AppColors.blue
                                    : Colors.white,
                                size: 20,
                              )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )),

                SizedBox(height: ResponsiveHelper.spacing(40)),

                /// SUBMIT BUTTON
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(54),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(14),
                        ),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submitVehicle(context: context),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      AppStrings.submitDetails.tr,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(16),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}