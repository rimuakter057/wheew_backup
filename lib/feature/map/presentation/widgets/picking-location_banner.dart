import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// Banner shown while the user is in "pick location on map" mode.
class PickingLocationBanner extends StatelessWidget {
  const PickingLocationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(16),
      left: ResponsiveHelper.padding(16),
      right: ResponsiveHelper.padding(16),
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Tap on the map to select parking location',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}