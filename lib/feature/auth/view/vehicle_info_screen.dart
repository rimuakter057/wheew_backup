// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/core/router/route_path.dart';
// import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
//
// import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/language/app_string.dart';
//
// import '../repository/country_list.dart';
//
// class VehicleInfoScreen extends StatefulWidget {
//   const VehicleInfoScreen({super.key});
//
//   @override
//   State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
// }
//
// class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
//   late final VehicleController controller;
//
//   // VehicleColorPicker widget-এর সাথে হুবহু মিল রেখে কালার লিস্ট
//   final List<Map<String, dynamic>> colorOptions = [
//     {'name': 'Bianco', 'color': AppColors.bianco},
//     {'name': 'Nero', 'color':  AppColors.nero},
//     {'name': 'Grigio / Argento', 'color':  AppColors.grigioArgento},
//     {'name': 'Blu', 'color':  AppColors.blu},
//     {'name': 'Rosso', 'color': AppColors.rosso},
//     {'name': 'Verde', 'color':  AppColors.verde},
//     {'name': 'Marrone / Bronzo', 'color':  AppColors.marroneBronzo},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(VehicleController(), permanent: false); // ✅ initState এ put করুন
//   }
//
//   @override
//   void dispose() {
//     Get.delete<VehicleController>(force: true); // ✅ এটাই মূল fix
//     super.dispose();
//   }
//
//   Color _getDarkerShade(Color color) {
//
//     if (color.computeLuminance() > 0.8) {
//       return const Color(0xFFB0B0B0);
//     }
//     // অন্য কালারগুলোর ক্ষেত্রে কালারটিকে ২৫% ডার্ক বা ব্ল্যাকিশ করা হবে ছায়ার জন্য
//     return Color.lerp(color, Colors.black, 0.25)!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final menuController = MenuController();
//     InputDecoration customInputDecoration({
//       required String labelText,
//       IconData? prefixIcon,
//     }) {
//       return InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(
//           fontSize: ResponsiveHelper.fontSize(14),
//           color: Colors.grey[600],
//         ),
//         prefixIcon: prefixIcon != null
//             ? Icon(prefixIcon, color: AppColors.blue, size: 22)
//             : null,
//         filled: true,
//         fillColor: Colors.grey[50],
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: ResponsiveHelper.padding(16),
//           vertical: ResponsiveHelper.padding(16),
//         ),
//         border: OutlineInputBorder(
//           borderRadius:
//           BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius:
//           BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
//           borderSide: BorderSide(color: Colors.grey[200]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius:
//           BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
//           borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Vehicle Info",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: TextButton.icon(
//               onPressed: () => context.go(RoutePath.mainNavScreen),
//               style: TextButton.styleFrom(
//                 backgroundColor: AppColors.blue.withOpacity(0.08),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               icon: const Icon(
//                 Icons.arrow_forward_rounded,
//                 size: 18,
//                 color: AppColors.blue,
//               ),
//               label: const Text(
//                 "Skip",
//                 style: TextStyle(
//                   color: AppColors.blue,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Text(
//                   "Let's add your vehicle",
//                   style: TextStyle(
//                     fontSize: ResponsiveHelper.fontSize(22),
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: ResponsiveHelper.height(6)),
//                 Text(
//                   "Please fill out the details below to proceed.",
//                   style: TextStyle(
//                     fontSize: ResponsiveHelper.fontSize(14),
//                     color: Colors.grey[500],
//                   ),
//                 ),
//                 SizedBox(height: ResponsiveHelper.height(30)),
//
//                 /// TYPE DROPDOWN
//                 Obx(
//                       () => PopupMenuButton<VehicleType>(
//                     offset: const Offset(120, 0), // ডানে সরাবে
//                     constraints: const BoxConstraints(
//                       minWidth: 200,
//                       maxWidth: 200,
//                     ),
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     onSelected: (value) {
//                       controller.selectedType.value = value;
//                     },
//                     itemBuilder: (context) {
//                       return controller.vehicleTypes.map((type) {
//                         return PopupMenuItem<VehicleType>(
//                           value: type,
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 type.icon,
//                                 width: 20,
//                                 height: 20,
//                                 colorFilter: const ColorFilter.mode(
//                                   Colors.black87,
//                                   BlendMode.srcIn,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   type.displayName,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList();
//                     },
//                     child: InputDecorator(
//                       decoration: customInputDecoration(
//                         labelText: AppStrings.vehicleType.tr,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: controller.selectedType.value == null
//                                 ? Text(
//                               "Select Vehicle Type",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: ResponsiveHelper.fontSize(14),
//                               ),
//                             )
//                                 : Row(
//                               children: [
//                                 SvgPicture.asset(
//                                   controller.selectedType.value!.icon,
//                                   width: 20,
//                                   height: 20,
//                                   colorFilter: const ColorFilter.mode(
//                                     Colors.black87,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     controller.selectedType.value!.displayName,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontSize: ResponsiveHelper.fontSize(14),
//                                       fontWeight: FontWeight.w500,
//                                       color: AppColors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Icon(Icons.keyboard_arrow_down_rounded),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 /// MODEL
//                 Obx(
//                       () => PopupMenuButton<String>(
//                     offset: const Offset(150, 0),
//                     constraints: BoxConstraints(
//                       minWidth: ResponsiveHelper.height(200),
//                       maxWidth: ResponsiveHelper.width(220),
//                       maxHeight: ResponsiveHelper.height(450),
//                       minHeight: ResponsiveHelper.height(350),
//                     ),
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     onSelected: (value) {
//                       controller.selectedVehicleModel.value = value;
//                     },
//                     itemBuilder: (context) {
//                       return vehicleModels.map((model) {
//                         return PopupMenuItem<String>(
//                           value: model,
//                           child: Text(
//                             model,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         );
//                       }).toList();
//                     },
//                     child: InputDecorator(
//                       decoration: customInputDecoration(
//                         labelText: AppStrings.vehicleModel.tr,
//                         prefixIcon: Icons.model_training_rounded,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               controller.selectedVehicleModel.value.isEmpty
//                                   ? "Select Vehicle Model"
//                                   : controller.selectedVehicleModel.value,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: ResponsiveHelper.fontSize(14),
//                                 color: controller.selectedVehicleModel.value.isEmpty
//                                     ? Colors.grey
//                                     : Colors.black87,
//                                 fontWeight: controller.selectedVehicleModel.value.isEmpty
//                                     ? FontWeight.normal
//                                     : FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           const Icon(Icons.keyboard_arrow_down_rounded),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(20)),
//
//                 /// COLOR CHIPS (Glossy 3D Circle Design — VehicleColorPicker এর মতো)
//                 Obx(() => Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppStrings.vehicleColor.tr,
//                       style: TextStyle(
//                         fontSize: ResponsiveHelper.fontSize(14),
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(height: ResponsiveHelper.height(12)),
//                     Wrap(
//                       spacing: 14,
//                       runSpacing: 14,
//                       children: colorOptions.map((c) {
//                         final bool isSelected =
//                             controller.selectedColor.value == c['name'];
//                         // সিলেক্ট করা কালারেরই ডিপ শেড — বর্ডার/গ্লো কালার হিসেবে ব্যবহার হবে
//                         final Color selectionColor =
//                         _getDarkerShade(c['color']);
//                         return GestureDetector(
//                           onTap: () =>
//                           controller.selectedColor.value = c['name'],
//                           child: Tooltip(
//                             message: c['name'],
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width:ResponsiveHelper.iconSize(38),
//                               height: ResponsiveHelper.iconSize(38),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 // সিলেকশন হাইলাইট বর্ডার এবং গ্লো শ্যাডো (নিজের কালারের ডিপ শেড)
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? selectionColor
//                                       : Colors.transparent,
//                                   width: isSelected ?1.5 : 0,
//                                 ),
//                                 boxShadow: isSelected
//                                     ? [
//                                   BoxShadow(
//                                     color: selectionColor.withOpacity(0.4),
//                                     blurRadius: 8,
//                                     spreadRadius: 2,
//                                   ),
//                                 ]
//                                     : [
//                                   // বাস্তবসম্মত ৩D আউটার শ্যাডো
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: ClipOval(
//                                 child: Stack(
//                                   children: [
//                                     // ১. ৩D বেস শেডিং (Radial Gradient)
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         gradient: RadialGradient(
//                                           colors: [
//                                             c['color'],
//                                             _getDarkerShade(c['color']),
//                                           ],
//                                           center: const Alignment(-0.25, -0.25),
//                                           radius: 0.85,
//                                         ),
//                                       ),
//                                     ),
//
//                                     // ২. গ্লসি বা গ্লাস রিফ্লেকশন লেয়ার
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomCenter,
//                                           colors: [
//                                             Colors.white.withOpacity(0.55),
//                                             Colors.white.withOpacity(0.0),
//                                             Colors.black.withOpacity(0.15),
//                                           ],
//                                           stops: const [0.0, 0.45, 1.0],
//                                         ),
//                                       ),
//                                     ),
//
//                                     // ৩. সিলেক্টেড চেক আইকন লেয়ার
//                                     if (isSelected)
//                                       Positioned.fill(
//                                         child: Icon(
//                                           Icons.check,
//                                           // হালকা/সাদা কালারের ক্ষেত্রে ডিপ শেড, নাহলে সাদা
//                                           color: c['color'].computeLuminance() >
//                                               0.6
//                                               ? selectionColor
//                                               : Colors.white,
//                                           size: 20,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 )),
//
//                 SizedBox(height: ResponsiveHelper.spacing(40)),
//
//                 /// SUBMIT BUTTON
//                 Obx(() => SizedBox(
//                   width: double.infinity,
//                   height: ResponsiveHelper.buttonHeight(54),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.blue,
//                       foregroundColor: Colors.white,
//                       elevation: 2,
//                       shadowColor: AppColors.blue.withOpacity(0.3),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           ResponsiveHelper.borderRadius(14),
//                         ),
//                       ),
//                     ),
//                     onPressed: controller.isLoading.value
//                         ? null
//                         : () => controller.submitVehicle(context: context),
//                     child: controller.isLoading.value
//                         ? const SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : Text(
//                       AppStrings.submitDetails.tr,
//                       style: TextStyle(
//                         fontSize: ResponsiveHelper.fontSize(16),
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



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

  // আগের কোডে যেই ৭টা কালার ছিল, সেগুলোই রাখা হলো
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFDEE7F0),
              Color(0xFFD0DCE8),
              Color(0xFFB6C5DA),
            ],

          ),
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
                  _buildSectionTitle(),
                  SizedBox(height: ResponsiveHelper.height(16)),


                  CustomBackgroundContainer(
                    child: Column(
                      children: [
                        _buildModelField(),
                        _buildColorPicker(),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(40)),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Add Your Vehicle",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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

  Widget _buildTypeWheel() {
    return Obx(
          () => VehicleTypeWheel(
        types: controller.vehicleTypes,
        selected: controller.selectedType.value,
        onSelected: (type) => controller.selectedType.value = type,
      ),
    );
  }





  Widget _buildSectionTitle() {
    return Text(
      "Vehicle Model & Color",
      style: TextStyle(
        fontSize: ResponsiveHelper.fontSize(18),
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildModelField() {
    return Obx(
          () => VehicleModelDropdown(
        selectedModel: controller.selectedVehicleModel.value,
        onSelected: (model) => controller.selectedVehicleModel.value = model,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.vehicleColor.tr,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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