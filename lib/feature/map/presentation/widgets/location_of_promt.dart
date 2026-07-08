import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Shown when device location service is turned off.
class LocationOffPrompt extends StatelessWidget {
  final VoidCallback onEnableLocation;

  const LocationOffPrompt({
    super.key,
    required this.onEnableLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F1FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off,
                    color: Color(0xFF185FA5), size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.locationTurnedOff.tr,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.locationOffDesc.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onEnableLocation,
                  child: Text(
                    AppStrings.enableLocation.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}