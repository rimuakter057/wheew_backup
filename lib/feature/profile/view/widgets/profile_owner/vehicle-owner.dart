import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';


/// Vehicle ownership verification status — তিনটি অবস্থা:
/// 1. Verified ✅
/// 2. Submitted, waiting ⏳
/// 3. Not submitted ❌
class VehicleOwnershipStatusWidget extends StatelessWidget {
  const VehicleOwnershipStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (ctrl) {
        final user = ctrl.userProfile.value;
        final isSubmitted = user?.isVehicleOwnershipDocumentSubmitted == true;
        final isVerified = user?.isVehicleVerified == true;

        final StatusConfig config = _resolveStatus(isSubmitted, isVerified);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: config.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: config.color.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(config.icon, color: config.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.message,
                  style: TextStyle(color: config.color, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  StatusConfig _resolveStatus(bool isSubmitted, bool isVerified) {
    if (isSubmitted && isVerified) {
      return StatusConfig(
        message: AppStrings.vehicleVerifiedSuccess.tr,
        color: AppColors.blue,
        bgColor: AppColors.blue.withOpacity(0.1),
        icon: Icons.verified,
      );
    } else if (isSubmitted && !isVerified) {
      return StatusConfig(
        message: AppStrings.documentSubmittedWaiting.tr,
        color: AppColors.chargingGreen,
        bgColor: AppColors.chargingGreen.withOpacity(0.1),
        icon: Icons.hourglass_bottom,
      );
    } else {
      return StatusConfig(
        message: AppStrings.notVerifiedSubmitDoc.tr,
        color: Colors.red,
        bgColor: Colors.red.withOpacity(0.1),
        icon: Icons.info_outline,
      );
    }
  }
}

/// Status এর color, icon ও message একসাথে hold করে
class StatusConfig {
  final String message;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const StatusConfig({
    required this.message,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}