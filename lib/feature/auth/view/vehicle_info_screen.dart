import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class VehicleInfoScreen extends StatelessWidget {
  VehicleInfoScreen({super.key});

  final VehicleController controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {


    // Common input decoration to avoid repetitive code
    InputDecoration customInputDecoration({required String labelText, IconData? prefixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.fontSize(14),
          color: Colors.grey[600],
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.blue, size: 22) : null,
        filled: true,
        fillColor: Colors.grey[50], // হালকা ব্যাকগ্রাউন্ড কালার যা প্রিমিয়াম লুক দেয়
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical: ResponsiveHelper.padding(16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // ক্লিন ব্যাকগ্রাউন্ড
      // appBar: AppBar(
      //   title: const Text(
      //       "Vehicle Info",
      //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      // ),


      appBar: AppBar(
        title: const Text(
          "Vehicle Info",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                context.go(RoutePath.mainNavScreen);
              },
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
            padding: EdgeInsets.all(ResponsiveHelper.padding(20)), // প্যাডিং একটু বাড়ানো হয়েছে
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // একটি সুন্দর হেডার সেকশন
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

                /// TYPE DROPDOWN
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
                  hint: Text("Select Vehicle Type", style: TextStyle(fontSize: ResponsiveHelper.fontSize(14))),
                  isExpanded: true, // স্ক্রিন সাইজ অনুযায়ী ফিট হবে
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                  decoration: customInputDecoration(
                      labelText: "Vehicle Type",
                      prefixIcon: Icons.directions_car_rounded
                  ),

                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.black87,
                  ),
                  items: controller.vehicleTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)), // মেনু আইটেমের সাইজ
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedType.value = value;
                  },
                )),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                /// MODEL
                TextField(
                  controller: controller.vehicleModelController,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                  decoration: customInputDecoration(
                      labelText: "Vehicle Model",
                      prefixIcon: Icons.model_training_rounded
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                /// COLOR
                TextField(
                  controller: controller.vehicleColorController,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                  decoration: customInputDecoration(
                      labelText: "Vehicle Color",
                      prefixIcon: Icons.color_lens_rounded
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(40)),

                /// SUBMIT BUTTON
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(54), // বাটনটি একটু থিক (Thick) করা হয়েছে
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
                        : () {
                      controller.submitVehicle(context: context);
                    },
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
                      "Submit Details",
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