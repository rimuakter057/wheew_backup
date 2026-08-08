// import 'package:flutter/material.dart';
// import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// /// Vehicle Color picker — circle swatches (VehicleInfoScreen এর ডিজাইন অনুযায়ী)
// class VehicleColorPicker extends StatelessWidget {
//   final ProfileController controller;
//
//   const VehicleColorPicker({super.key, required this.controller});
//
//   static const List<Map<String, dynamic>> _colorOptions = [
//     {'name': 'Bianco', 'color': Color(0xFFF4F4F2)},
//     {'name': 'Nero', 'color': Color(0xFF1B1B1D)},
//     {'name': 'Grigio', 'color': Color(0xFF6E7074)},
//     {'name': 'Blu', 'color': Color(0xFF2C3E5C)},
//     {'name': 'Rosso', 'color': Color(0xFFB11724)},
//     {'name': 'Bianco2', 'color': AppColors.white},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedColor = controller.vehicleColorController.text;
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         horizontal: ResponsiveHelper.padding(14),
//         vertical: ResponsiveHelper.padding(12),
//       ),
//       decoration: BoxDecoration(
//         color: controller.isEditing
//             ? AppColors.white
//             : AppColors.greyShade.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//         border: Border.all(color: AppColors.greyShade),
//       ),
//       child: Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children: _colorOptions.map((c) {
//           final bool isSelected = selectedColor == c['name'];
//           return GestureDetector(
//             onTap: controller.isEditing
//                 ? () {
//               controller.vehicleColorController.text = c['name'];
//               controller.update(['vehicle_fields']);
//             }
//                 : null,
//             child: Tooltip(
//               message: c['name'],
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: c['color'],
//                   border: Border.all(
//                     color: isSelected ? AppColors.blue : AppColors.greyShade300,
//                     width: isSelected ? 3 : 1,
//                   ),
//                   boxShadow: isSelected
//                       ? [
//                     BoxShadow(
//                       color: AppColors.blue.withOpacity(0.3),
//                       blurRadius: 6,
//                       spreadRadius: 1,
//                     ),
//                   ]
//                       : [],
//                 ),
//                 child: isSelected
//                     ? Icon(
//                   Icons.check,
//                   color: c['name'] == 'Bianco' || c['name'] == 'Bianco2'
//                       ? AppColors.blue
//                       : AppColors.white,
//                   size: 18,
//                 )
//                     : null,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Vehicle Color picker — Horizontal 3D Glossy/Glass Circles (immagine 2.png এর মতো হুবহু ডিজাইন)
class VehicleColorPicker extends StatelessWidget {
  final ProfileController controller;

  const VehicleColorPicker({super.key, required this.controller});

  // immagine 2.png অনুযায়ী কালার লিস্ট
  static const List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Bianco', 'color': AppColors.bianco},
    {'name': 'Nero', 'color':  AppColors.nero},
    {'name': 'Grigio / Argento', 'color':  AppColors.grigioArgento},
    {'name': 'Blu', 'color':  AppColors.blu},
    {'name': 'Rosso', 'color': AppColors.rosso},
    {'name': 'Verde', 'color':  AppColors.verde},
    {'name': 'Marrone / Bronzo', 'color':  AppColors.marroneBronzo},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = controller.vehicleColorController.text;
    // Locked once already set; otherwise editable while in edit mode.
    final bool isFieldEnabled = controller.isEditing && !controller.isVehicleColorLocked;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(14),
        vertical: ResponsiveHelper.padding(14),
      ),
      decoration: BoxDecoration(
        color: isFieldEnabled
            ? AppColors.white
            : AppColors.greyShade.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
        border: Border.all(color: AppColors.greyShade),
      ),

      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _colorOptions.map((c) {
          final bool isSelected = selectedColor == c['name'];
          // সিলেক্ট করা কালারেরই ডিপ শেড — বর্ডার/গ্লো কালার হিসেবে ব্যবহার হবে
          final Color selectionColor = _getDarkerShade(c['color']);

          return GestureDetector(
            onTap: isFieldEnabled
                ? () {
              controller.vehicleColorController.text = c['name'];
              controller.update(['vehicle_fields']);
            }
                : null,
            child: Tooltip(
              message: c['name'],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: ResponsiveHelper.iconSize(30), // ৩D ইফেক্টটি সুন্দরভাবে ফুটিয়ে তুলতে সাইজ ৪০ করা হয়েছে
                height: ResponsiveHelper.iconSize(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // সিলেকশন হাইলাইট বর্ডার এবং গ্লো শ্যাডো (নিজের কালারের ডিপ শেড)
                  border: Border.all(
                    color: isSelected ? selectionColor : AppColors.transparent,
                    width: isSelected ? 1.5 : 0,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: selectionColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                      : [
                    // ছবির মতো বাস্তবসম্মত ৩D আউটার শ্যাডো
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // ১. ৩D বেস শেডিং (Radial Gradient দিয়ে ত্রিমাত্রিক গোলকের মতো ফিল তৈরি করা হয়েছে)
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              c['color'], // কেন্দ্র বা আলোর দিকটা উজ্জ্বল
                              _getDarkerShade(c['color']), // বাইরের দিকটা ডার্ক বা ছায়া
                            ],
                            center: const Alignment(-0.25, -0.25), // আলোর কেন্দ্র (টপ-লেফট)
                            radius: 0.85,
                          ),
                        ),
                      ),

                      // ২. গ্লসি বা গ্লাস রিফ্লেকশন (Glossy Gloss / Light Highlight Layer)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.white.withOpacity(0.55), // ছবির মতো উপরের চমৎকার সাদা লাইট রিফ্লেকশন
                              AppColors.white.withOpacity(0.0),   // মাঝখানে ট্রান্সপারেন্ট
                              AppColors.black.withOpacity(0.15),  // নিচের অংশে গভীর ছায়া বা ডেপ্থ
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // ৩. সিলেক্টেড চেক আইকন লেয়ার
                      if (isSelected)
                        Positioned.fill(
                          child: Icon(
                            Icons.check,
                            // হালকা/সাদা কালারের ক্ষেত্রে ডিপ শেড, নাহলে সাদা (কনট্রাস্টের জন্য)
                            color: (c['color'] as Color).computeLuminance() >
                                0.6
                                ? selectionColor
                                : AppColors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ৩D ইফেক্টের গভীরতা বাড়ানোর জন্য বেস কালারকে ডার্ক করার হেল্পার মেথড
  Color _getDarkerShade(Color color) {
    // সাদা বা হালকা কালার হলে একটু আলাদা গ্রে-শেড ছায়া দেবো
    if (color.computeLuminance() > 0.8) {
      return const Color(0xFFB0B0B0);
    }

    return Color.lerp(color, AppColors.black, 0.25)!;
  }
}

