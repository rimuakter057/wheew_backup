




// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class VehicleTypeWheel extends StatelessWidget {
//   final List<VehicleType> types;
//   final VehicleType? selected;
//   final ValueChanged<VehicleType> onSelected;
//
//   final double wheelSize;
//
//   const VehicleTypeWheel({
//     super.key,
//     required this.types,
//     required this.selected,
//     required this.onSelected,
//     this.wheelSize = 360,
//   });
//
//
//   static const double _startAngle = -90;
//   static const double _sweepAngle = 360;
//
//   @override
//   Widget build(BuildContext context) {
//     if (types.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     final VehicleType current = selected ?? types.first;
//
//     return SizedBox(
//       width: wheelSize,
//       height: wheelSize,
//       child: Stack(
//         alignment: Alignment.center,
//         clipBehavior: Clip.none,
//         children: [
//
//           /// Background Circle
//           Container(
//             width: wheelSize,
//             height: wheelSize,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const RadialGradient(
//                 radius: .95,
//                 colors: [
//                   Color(0xffF8FBFF),
//                   Color(0xffEEF4FA),
//                   Color(0xffDEE7F0),
//                 ],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.white.withOpacity(.85),
//                   blurRadius: 18,
//                   spreadRadius: 3,
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(.05),
//                   blurRadius: 18,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//           ),
//
//           /// Petals
//           ...List.generate(types.length, (index) {
//             final angle = (_startAngle +
//                 (_sweepAngle / (types.length - 1)) * index) *
//                 math.pi /
//                 180;
//
//             return _WheelPetal(
//               angle: angle,
//               wheelSize: wheelSize,
//               radius: wheelSize * .36,
//               label:
//               "${(index + 1).toString().padLeft(2, '0')}",
//               selected: current == types[index],
//               onTap: () => onSelected(types[index]),
//             );
//           }),
//
//           /// Center Vehicle
//           _CenterVehicle(
//             wheelSize: wheelSize,
//             current: current,
//           ),
//
//           /// Bottom Badge
//           _VehicleBadge(
//             current: current,
//             wheelSize: wheelSize,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _WheelPetal extends StatelessWidget {
//   final double angle;
//   final double radius;
//   final double wheelSize;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const _WheelPetal({
//     required this.angle,
//     required this.radius,
//     required this.wheelSize,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final dx = radius * math.cos(angle);
//     final dy = radius * math.sin(angle);
//
//     return Positioned(
//       left: wheelSize / 2 + dx - 34,
//       top: wheelSize / 2 + dy - 44,
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOut,
//
//           width: selected ? 72 : 64,
//           height: selected ? 88 : 80,
//
//           transformAlignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..rotateZ(angle + math.pi / 2),
//
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//
//               /// Shadow
//               Positioned.fill(
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(
//                         color: selected
//                             ? AppColors.blue.withOpacity(.28)
//                             : Colors.black.withOpacity(.05),
//                         blurRadius: selected ? 22 : 12,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               /// Petal Shape
//               CustomPaint(
//                 size: Size(
//                   selected ? 72 : 64,
//                   selected ? 88 : 80,
//                 ),
//                 painter: _PetalPainter(
//                   color: selected
//                       ? AppColors.blue
//                       : Colors.white,
//                 ),
//               ),
//
//               /// Number
//               Transform.rotate(
//                 angle: -(angle + math.pi / 2),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: selected ? 24 : 18,
//                       fontWeight: FontWeight.w700,
//                       color: selected
//                           ? Colors.white
//                           : const Color(0xffA8B5C7),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PetalPainter extends CustomPainter {
//   final Color color;
//
//   const _PetalPainter({
//     required this.color,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
//
//     final borderPaint = Paint()
//       ..color = Colors.white.withOpacity(.95)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.2;
//
//     final path = Path();
//
//     // Bottom Center
//     path.moveTo(size.width * .50, size.height);
//
//     /// Left Side===================
//     path.quadraticBezierTo(
//       size.width * .08,
//       size.height * .82,
//       size.width * .12,
//       size.height * .38,
//     );
//     //
//     // // Top Left Curve
//     path.quadraticBezierTo(
//       size.width * .14,
//       size.height * .10,
//       size.width * .36,
//       size.height * .02,
//     );
//     //
//     // // Top Arc
//     path.quadraticBezierTo(
//       size.width * .50,
//       -size.height * .06,
//       size.width * .64,
//       size.height * .02,
//     );
//
//     /// Top Right Curve
//     path.quadraticBezierTo(
//       size.width * .86,
//       size.height * .10,
//       size.width * .88,
//       size.height * .38,
//     );
//
//     /// Right Side
//     path.quadraticBezierTo(
//       size.width * .92,
//       size.height * .82,
//       size.width * .50,
//       size.height,
//     );
//
//
//
//
//     path.close();
//
//     // Soft Shadow
//     canvas.drawShadow(
//       path,
//       Colors.black.withOpacity(.15),
//       10,
//       true,
//     );
//
//     // Fill
//     canvas.drawPath(path, paint);
//
//     // Thin Border
//     canvas.drawPath(path, borderPaint);
//
//     // Top Highlight
//     final highlight = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Colors.white.withOpacity(.35),
//           Colors.transparent,
//         ],
//       ).createShader(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//       );
//
//     canvas.drawPath(path, highlight);
//   }
//
//   @override
//   bool shouldRepaint(covariant _PetalPainter oldDelegate) {
//     return oldDelegate.color != color;
//   }
// }
//
//
// class _CenterVehicle extends StatelessWidget {
//   final double wheelSize;
//   final VehicleType current;
//
//   const _CenterVehicle({
//     required this.wheelSize,
//     required this.current,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: wheelSize * .26,
//       child: Column(
//         children: [
//
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeOut,
//
//             width: wheelSize * .36,
//             height: wheelSize * .22,
//
//             child: current.icon.toLowerCase().endsWith(".svg")
//                 ? SvgPicture.asset(
//               current.icon,
//               fit: BoxFit.contain,
//               colorFilter: const ColorFilter.mode(
//                 Color(0xff1F2937),
//                 BlendMode.srcIn,
//               ),
//             )
//                 : const Icon(
//               Icons.directions_car_filled_rounded,
//               size: 80,
//               color: Color(0xff1F2937),
//             ),
//           ),
//
//           const SizedBox(height: 14),
//
//           Container(
//             width: 44,
//             height: 4,
//             decoration: BoxDecoration(
//               color: AppColors.blue.withOpacity(.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _VehicleBadge extends StatelessWidget {
//   final VehicleType current;
//   final double wheelSize;
//
//   const _VehicleBadge({
//     required this.current,
//     required this.wheelSize,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: wheelSize * .18,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//
//         padding: const EdgeInsets.symmetric(
//           horizontal: 26,
//           vertical: 11,
//         ),
//
//         decoration: BoxDecoration(
//           color: AppColors.blue,
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.blue.withOpacity(.35),
//               blurRadius: 22,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//
//             const Icon(
//               Icons.directions_car_filled,
//               color: Colors.white,
//               size: 18,
//             ),
//
//             const SizedBox(width: 8),
//
//             Text(
//               current.displayName,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 15,
//                 letterSpacing: .3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _WheelDecoration extends StatelessWidget {
//   final double wheelSize;
//
//   const _WheelDecoration({
//     required this.wheelSize,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: SizedBox(
//         width: wheelSize,
//         height: wheelSize,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//
//             /// Outer Glow
//             Container(
//               width: wheelSize * .96,
//               height: wheelSize * .96,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.blue.withOpacity(.05),
//                     blurRadius: 60,
//                     spreadRadius: 20,
//                   ),
//                 ],
//               ),
//             ),
//
//             /// Outer Ring
//             Container(
//               width: wheelSize * .88,
//               height: wheelSize * .88,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(.75),
//                   width: 1.2,
//                 ),
//               ),
//             ),
//
//             /// Middle Ring
//             Container(
//               width: wheelSize * .67,
//               height: wheelSize * .67,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: const Color(0xffE8EEF5),
//                   width: 1,
//                 ),
//               ),
//             ),
//
//             /// Inner Ring
//             Container(
//               width: wheelSize * .42,
//               height: wheelSize * .42,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(.45),
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 1,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// extension _WheelSize on double {
//   double wp(double percent) => this * percent;
// }
//
// class _WheelScaleAnimation extends StatelessWidget {
//   final Widget child;
//   final bool selected;
//
//   const _WheelScaleAnimation({
//     required this.child,
//     required this.selected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedScale(
//       duration: const Duration(milliseconds: 220),
//       curve: Curves.easeOutBack,
//       scale: selected ? 1.12 : 1,
//       child: AnimatedOpacity(
//         duration: const Duration(milliseconds: 220),
//         opacity: selected ? 1 : .95,
//         child: child,
//       ),
//     );
//   }
// }



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

  static const double _startAngle = -120; // হাফ-সার্কেল বা বাঁকা আর্কের জন্য স্টার্ট অ্যাঙ্গেল
  static const double _sweepAngle = 240;  // পুরো ৩৬০ ডিগ্রি না ঘুরে আর্কের মতো দেখাবে

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    // ResponsiveHelper ব্যবহার করে সাইজ কনভার্ট করা হলো
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
    final double baseWidth = selected ? 76 : 66;
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

    final path = Path();
    final w = size.width;
    final h = size.height;

    // ১. নিচের বাম কোণ থেকে শুরু
    path.moveTo(w * 0.26, h);

    // ২. নিচের কার্ভড লাইন (Inner Arc) যা ডান কোণে যায়
    path.quadraticBezierTo(w * 0.5, h * 0.88, w * 0.74, h);

    // ৩. ডান দিকের ওপরের কোণে যাওয়ার লাইন
    path.quadraticBezierTo(w * 0.84, h * 0.5, w * 0.92, h * 0.08);

    // ৪. ওপরের ডান কোণের রাউন্ডেড কার্ভ
    path.quadraticBezierTo(w * 0.95, 0, w * 0.85, 0);

    // ৫. ওপরের কার্ভড লাইন (Outer Arc) যা বাম কোণে যায়
    path.quadraticBezierTo(w * 0.5, h * 0.12, w * 0.15, 0);

    // ৬. ওপরের বাম কোণের রাউন্ডেড কার্ভ
    path.quadraticBezierTo(w * 0.05, 0, w * 0.08, h * 0.08);

    // ৭. বাম দিকের নিচের কোণে ফিরে আসার লাইন
    path.quadraticBezierTo(w * 0.16, h * 0.5, w * 0.26, h);

    path.close();

    // সফট শ্যাডো ইফেক্ট
    canvas.drawShadow(
      path,
      isSelected ? AppColors.blue.withOpacity(0.4) : Colors.black.withOpacity(0.08),
      isSelected ? 12 : 6,
      true,
    );

    // Fill the path
    canvas.drawPath(path, paint);

    // Draw border if not selected
    canvas.drawPath(path, borderPaint);

    // প্রিমিয়াম হাইলাইট ইফেক্ট
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