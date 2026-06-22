import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/vihecal_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

// class VehicleInfoScreen extends StatelessWidget {
//   VehicleInfoScreen({super.key});
//
//   final VehicleController controller = Get.put(VehicleController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Vehicle Info")),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//           SizedBox(height: ResponsiveHelper.height(28),),
//                 /// TYPE DROPDOWN
//                 Obx(() => DropdownButtonFormField<String>(
//           value: controller.selectedType.value,
//             items: controller.vehicleTypes.map((type) {
//               return DropdownMenuItem(
//                 value: type,
//                 child: Text(type),
//               );
//             }).toList(),
//             onChanged: (value) {
//               controller.selectedType.value = value!;
//             },
//             decoration: const InputDecoration(
//               labelText: "Vehicle Type",
//             ),
//           )),
//
//                 const SizedBox(height: 15),
//
//                 /// MODEL
//                 TextField(
//                   controller: controller.vehicleModelController,
//                   decoration: const InputDecoration(
//                     labelText: "Vehicle Model",
//                   ),
//                 ),
//
//                 const SizedBox(height: 15),
//
//                 /// COLOR
//                 TextField(
//                   controller: controller.vehicleColorController,
//                   decoration: const InputDecoration(
//                     labelText: "Vehicle Color",
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 Obx(() => ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
//                   onPressed: controller.isLoading.value
//                       ? null
//                       : () {
//                     controller.submitVehicle(context: context );
//                   },
//                   child: controller.isLoading.value
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Submit"),
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



class VehicleInfoScreen extends StatelessWidget {
  VehicleInfoScreen({super.key});

  final VehicleController controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context); // 🔥 IMPORTANT

    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Info")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
            child: Column(
              children: [

                SizedBox(height: ResponsiveHelper.height(28)),

                /// TYPE DROPDOWN
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedType.value,
                  items: controller.vehicleTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedType.value = value!;
                  },
                  decoration: InputDecoration(
                    labelText: "Vehicle Type",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.padding(12),
                      vertical: ResponsiveHelper.padding(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                    ),
                  ),
                )),

                SizedBox(height: ResponsiveHelper.spacing(15)),

                /// MODEL
                TextField(
                  controller: controller.vehicleModelController,
                  decoration: InputDecoration(
                    labelText: "Vehicle Model",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(15)),

                /// COLOR
                TextField(
                  controller: controller.vehicleColorController,
                  decoration: InputDecoration(
                    labelText: "Vehicle Color",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(30)),

                /// SUBMIT BUTTON
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      controller.submitVehicle(context: context);
                    },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : Text(
                      "Submit",
                      style: TextStyle(
                        fontSize:
                        ResponsiveHelper.fontSize(16),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
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