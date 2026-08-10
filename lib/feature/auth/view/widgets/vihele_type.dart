import 'package:flutter/material.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';

/// Horizontal "coverflow" style carousel — the selected vehicle sits large
/// in the center, neighbours peek in on either side, scaled down and faded.
class VehicleTypeWheel extends StatefulWidget {
  final List<VehicleType> types;
  final VehicleType? selected;
  final ValueChanged<VehicleType> onSelected;

  /// Tint applied to the centered/selected vehicle image so it matches the
  /// chosen vehicle color. Null keeps the original blue artwork.
  final Color? selectedColorTint;

  const VehicleTypeWheel({
    super.key,
    required this.types,
    required this.selected,
    required this.onSelected,
    this.selectedColorTint,

  });

  @override
  State<VehicleTypeWheel> createState() => _VehicleTypeWheelState();
}

class _VehicleTypeWheelState extends State<VehicleTypeWheel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.selected == null
        ? 0
        : widget.types.indexOf(widget.selected!).clamp(0, widget.types.length - 1);
    _pageController = PageController(
      viewportFraction: 0.42,
      initialPage: initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.types.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: ResponsiveHelper.height(190),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.types.length,
        onPageChanged: (index) => widget.onSelected(widget.types[index]),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = index.toDouble();
              if (_pageController.position.haveDimensions) {
                page = _pageController.page ?? index.toDouble();
              }
              final double distance = (page - index).abs().clamp(0.0, 1.0);
              final double scale = 1 - (distance * 0.35);
              final double opacity = 1 - (distance * 0.35);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: _VehicleTypeCard(
                    type: widget.types[index],
                    isCenter: distance < 0.5,
                    colorTint: widget.selectedColorTint,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleType type;
  final bool isCenter;
  final Color? colorTint;

  const _VehicleTypeCard({
    required this.type,
    required this.isCenter,
    this.colorTint,
  });

  @override
  Widget build(BuildContext context) {
    final bool tinted = isCenter && colorTint != null;

    // The white PNG's body is near-neutral gray (R≈G≈B per pixel), so
    // BlendMode.modulate multiplies it by the tint to recolor just the car
    // body while keeping its shading — and, unlike BlendMode.color, it
    // multiplies alpha too, so fully-transparent background pixels (alpha 0)
    // stay transparent instead of getting painted solid.
    final Widget image = Image.asset(
      isCenter && !tinted ? type.imageBlue : type.imageWhite,
      fit: BoxFit.contain,
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ResponsiveHelper.width(140),
            height: ResponsiveHelper.height(140),
            child: tinted
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(colorTint!, BlendMode.modulate),
                    child: image,
                  )
                : image,
          ),
          SizedBox(height: ResponsiveHelper.spacing(10)),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(isCenter ? 17 : 13),
              fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
              color: isCenter ?AppColors.black : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}


