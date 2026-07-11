
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';

class VehicleTypeWheel extends StatelessWidget {
  final List<VehicleType> types;
  final VehicleType? selected;
  final ValueChanged<VehicleType> onSelected;
  final double wheelSize;

  const VehicleTypeWheel({
    super.key,
    required this.types,
    required this.selected,
    required this.onSelected,
    this.wheelSize = 360,
  });

  static const double _startAngle = -110;
  static const double _sweepAngle = 325;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    final double finalWheelSize = ResponsiveHelper.width(wheelSize);
    final VehicleType current = selected ?? types.first;

    return SizedBox(
      width: finalWheelSize,
      height: finalWheelSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          /// Background Circle
          Container(
            width: finalWheelSize,
            height: finalWheelSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                radius: .95,
                colors: [
                  Color(0xffF8FBFF),
                  Color(0xffEEF4FA),
                  Color(0xffDEE7F0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(.85),
                  blurRadius: ResponsiveHelper.borderRadius(18),
                  spreadRadius: ResponsiveHelper.width(3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: ResponsiveHelper.borderRadius(18),
                  offset: Offset(0, ResponsiveHelper.height(10)),
                ),
              ],
            ),
          ),

          /// Petals
          ...List.generate(types.length, (index) {
            final double angleStep = types.length > 1 ? (_sweepAngle / (types.length - 1)) : 0;
            final angle = (_startAngle + (angleStep * index)) * math.pi / 180;

            return _WheelPetal(
              angle: angle,
              wheelSize: finalWheelSize,
              radius: finalWheelSize * .36,
              label: (index + 1).toString().padLeft(2, '0'),
              selected: current == types[index],
              onTap: () => onSelected(types[index]),
            );
          }),

          /// Center Vehicle
          _CenterVehicle(
            wheelSize: finalWheelSize,
            current: current,
          ),

          /// Bottom Badge
          _VehicleBadge(
            current: current,
            wheelSize: finalWheelSize,
          ),
        ],
      ),
    );
  }
}

class _WheelPetal extends StatelessWidget {
  final double angle;
  final double radius;
  final double wheelSize;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WheelPetal({
    required this.angle,
    required this.radius,
    required this.wheelSize,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dx = radius * math.cos(angle);
    final dy = radius * math.sin(angle);

    // ResponsiveHelper দিয়ে সাইজ জেনারেট
    final double baseWidth = selected ? 86 : 100;
    final double baseHeight = selected ? 92 : 82;


    final double petalWidth = ResponsiveHelper.width(baseWidth);
    final double petalHeight = ResponsiveHelper.height(baseHeight);

    return Positioned(
      left: wheelSize / 2 + dx - (petalWidth / 2),
      top: wheelSize / 2 + dy - (petalHeight / 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: petalWidth,
          height: petalHeight,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()..rotateZ(angle + math.pi / 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Petal Shape (CustomPaint)
              CustomPaint(
                size: Size(petalWidth, petalHeight),
                painter: _PetalPainter(
                  color: selected ? AppColors.blue : Colors.white,
                  isSelected: selected,
                ),
              ),

              /// Number (Counter rotated to keep upright)
              Transform.rotate(
                angle: -(angle + math.pi / 2),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: ResponsiveHelper.height(selected ? 4 : 2),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(selected ? 22 : 17),
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xffA8B5C7),
                    ),
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

class _PetalPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  const _PetalPainter({
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.transparent : Colors.white.withOpacity(.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ResponsiveHelper.borderWidth(1.2);


    // final borderPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = ResponsiveHelper.borderWidth(1.4)
    //   ..color = isSelected
    //       ? const Color(0xFF4D8DFF)
    //       : Colors.white.withOpacity(.95);

    final path = Path();
    final w = size.width;
    final h = size.height;

    /// 1. Start from the bottom-left point
    path.moveTo(w * 0.26, h);

    /// 2. Bottom inner curve
    path.quadraticBezierTo(
      w * 0.5,
      h * 0.90,
      w * 0.74,
      h,
    );

    /// 3. Right side edge (more rounded)
    path.quadraticBezierTo(
      w * 0.90,
      h * 0.50,
      w * 0.96,
      h * 0.10,
    );

    /// 4. Top-right corner (larger radius)
    path.quadraticBezierTo(
      w,
      0,
      w * 0.82,
      0,
    );

    /// 5. Top edge (smooth & flat)
    path.quadraticBezierTo(
      w * 0.5,
      -h * 0.03,
      w * 0.18,
      0,
    );

    /// 6. Top-left corner (larger radius)
    path.quadraticBezierTo(
      0,
      0,
      w * 0.04,
      h * 0.10,
    );

    /// 7. Left side edge (more rounded)
    path.quadraticBezierTo(
      w * 0.08,
      h * 0.50,
      w * 0.26,
      h,
    );

    /// Close the path
    path.close();

    canvas.drawShadow(
      path,
      isSelected
          ? AppColors.blueGrey
          : Colors.black.withOpacity(.14),
      isSelected ? 18 : 10,
      true,
    );

    // Fill the path
    canvas.drawPath(path, paint);

    canvas.drawPath(path, borderPaint);

    if (isSelected) {
      final highlight = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(path, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isSelected != isSelected;
  }
}

class _CenterVehicle extends StatelessWidget {
  final double wheelSize;
  final VehicleType current;

  const _CenterVehicle({
    required this.wheelSize,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: wheelSize * .28,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: wheelSize * .36,
            height: wheelSize * .22,
            child: current.icon.toLowerCase().endsWith(".svg")
                ? SvgPicture.asset(
              current.icon,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Color(0xff1F2937),
                BlendMode.srcIn,
              ),
            )
                : Icon(
              Icons.directions_car_filled_rounded,
              size: ResponsiveHelper.iconSize(72),
              color: const Color(0xff1F2937),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(10)),
          Container(
            width: ResponsiveHelper.width(40),
            height: ResponsiveHelper.height(4),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(.15),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleBadge extends StatelessWidget {
  final VehicleType current;
  final double wheelSize;

  const _VehicleBadge({
    required this.current,
    required this.wheelSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: wheelSize * .16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(50)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(.35),
              blurRadius: ResponsiveHelper.borderRadius(20),
              offset: Offset(0, ResponsiveHelper.height(8)),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: ResponsiveHelper.iconSize(16),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            Text(
              current.displayName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.fontSize(14),
                letterSpacing: .3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}