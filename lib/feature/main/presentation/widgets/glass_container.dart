import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;

  const GlassContainer({
    super.key,
    required this.child,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          /// Blur
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 35,
              sigmaY: 35,
            ),
            child: const SizedBox.expand(),
          ),

          /// Main Glass
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(.32),
                  Colors.white.withOpacity(.18),
                  Colors.white.withOpacity(.08),
                ],
              ),

              border: Border.all(
                color: Colors.white.withOpacity(.32),
                width: ResponsiveHelper.borderWidth(1.1),
              ),
            ),
          ),

          /// Top Reflection
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: ResponsiveHelper.height(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(.40),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Shine
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: ResponsiveHelper.height(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(radius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(.10),
                  ],
                ),
              ),
            ),
          ),

          /// Inner Border
          Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius - 2),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}