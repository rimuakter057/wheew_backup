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
//     {'name': 'Bianco2', 'color': Colors.white},
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
//                     color: isSelected ? AppColors.blue : Colors.grey.shade300,
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
//                       : Colors.white,
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

  // immagine 2.png অনুযায়ী কালার লিস্ট
  static const List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Bianco', 'color': Color(0xFFF4F4F2)},
    {'name': 'Nero', 'color': Color(0xFF1B1B1D)},
    {'name': 'Grigio / Argento', 'color': Color(0xFF888B8D)},
    {'name': 'Blu', 'color': Color(0xFF1E3A8A)}, // ডিপ রয়্যাল ব্লু
    {'name': 'Rosso', 'color': Color(0xFFB11724)},
    {'name': 'Verde', 'color': Color(0xFF006A4E)},
    {'name': 'Marrone / Bronzo', 'color': Color(0xFF915135)},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = controller.vehicleColorController.text;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(14),
        vertical: ResponsiveHelper.padding(14),
      ),
      decoration: BoxDecoration(
        color: controller.isEditing
            ? AppColors.white
            : AppColors.greyShade.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
        border: Border.all(color: AppColors.greyShade),
      ),
      // অনুভূমিকভাবে (Horizontal) ৩D সার্কেলগুলো সাজানোর জন্য Wrap ব্যবহার করা হয়েছে
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _colorOptions.map((c) {
          final bool isSelected = selectedColor == c['name'];

          return GestureDetector(
            onTap: controller.isEditing
                ? () {
              controller.vehicleColorController.text = c['name'];
              controller.update(['vehicle_fields']);
            }
                : null,
            child: Tooltip(
              message: c['name'],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40, // ৩D ইফেক্টটি সুন্দরভাবে ফুটিয়ে তুলতে সাইজ ৪০ করা হয়েছে
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // সিলেকশন হাইলাইট বর্ডার এবং গ্লো শ্যাডো
                  border: Border.all(
                    color: isSelected ? AppColors.blue : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                      : [
                    // ছবির মতো বাস্তবসম্মত ৩D আউটার শ্যাডো
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // ১. ৩D বেস শেডিং (Radial Gradient দিয়ে ত্রিমাত্রিক গোলকের মতো ফিল তৈরি করা হয়েছে)
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              c['color'], // কেন্দ্র বা আলোর দিকটা উজ্জ্বল
                              _getDarkerShade(c['color']), // বাইরের দিকটা ডার্ক বা ছায়া
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
                              Colors.white.withOpacity(0.55), // ছবির মতো উপরের চমৎকার সাদা লাইট রিফ্লেকশন
                              Colors.white.withOpacity(0.0),   // মাঝখানে ট্রান্সপারেন্ট
                              Colors.black.withOpacity(0.15),  // নিচের অংশে গভীর ছায়া বা ডেপ্থ
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // ৩. সিলেক্টেড চেক আইকন লেয়ার
                      if (isSelected)
                        Positioned.fill(
                          child: Icon(
                            Icons.check,
                            color: c['name'] == 'Bianco'
                                ? AppColors.blue
                                : Colors.white,
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

  // ৩D ইফেক্টের গভীরতা বাড়ানোর জন্য বেস কালারকে ডার্ক করার হেল্পার মেথড
  Color _getDarkerShade(Color color) {
    // সাদা বা হালকা কালার হলে একটু আলাদা গ্রে-শেড ছায়া দেবো
    if (color.computeLuminance() > 0.8) {
      return const Color(0xFFB0B0B0);
    }
    // অন্য কালারগুলোর ক্ষেত্রে কালারটিকে ২০% ডার্ক বা ব্ল্যাকিশ করা হবে ছায়ার জন্য
    return Color.lerp(color, Colors.black, 0.25)!;
  }
}