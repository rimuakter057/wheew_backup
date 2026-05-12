// lib/core/bindings/app_bindings.dart

import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/useful_number/controller/useful_number_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ChatController());
    Get.put(ProfileController());
    Get.put(ScanController());
    Get.put(UsefulNumberController());
  }
}