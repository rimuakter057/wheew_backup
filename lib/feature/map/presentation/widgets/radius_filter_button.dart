import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// Floating action button (top-left) that opens the radius filter sheet.
class RadiusFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RadiusFilterButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ResponsiveHelper.padding(30),
      top: ResponsiveHelper.padding(80),
      child: FloatingActionButton(
        heroTag: 'filterRadiusBtn',
        backgroundColor: Colors.white,
        elevation: 3,
        onPressed: onPressed,
        child: const Icon(Icons.tune, color: Color(0xFF185FA5)),
      ),
    );
  }
}