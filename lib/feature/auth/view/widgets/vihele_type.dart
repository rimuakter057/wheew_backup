import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';

/// Horizontal "coverflow" style carousel — the selected vehicle sits large
/// in the center, neighbours peek in on either side, scaled down and faded.
class VehicleTypeWheel extends StatefulWidget {
  final List<VehicleType> types;
  final VehicleType? selected;
  final ValueChanged<VehicleType> onSelected;

  const VehicleTypeWheel({
    super.key,
    required this.types,
    required this.selected,
    required this.onSelected,
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

    final VehicleType current = widget.selected ?? widget.types.first;

    return Column(
      children: [
        SizedBox(
          height: ResponsiveHelper.height(160),
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
                  final double opacity = 1 - (distance * 0.55);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: _VehicleTypeCard(
                        type: widget.types[index],
                        isCenter: distance < 0.5,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(14)),
        Text(
          current.displayName,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(17),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleType type;
  final bool isCenter;

  const _VehicleTypeCard({required this.type, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveHelper.width(140),
        height: ResponsiveHelper.height(140),
        child: SvgPicture.asset(
          type.icon,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            isCenter ? AppColors.blue : Colors.grey.shade400,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
