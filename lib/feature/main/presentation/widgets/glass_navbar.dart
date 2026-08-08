import 'package:platchatapp/utils/color/app_colors.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

import 'glass_container.dart';
import 'nav_item.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.icons,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double height = ResponsiveHelper.height(74);
    final double radius = ResponsiveHelper.borderRadius(38);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.maxContentWidth,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),

            /// Floating Shadow
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(.18),
                blurRadius: 35,
                spreadRadius: 1,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: AppColors.white.withOpacity(.35),
                blurRadius: 12,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child:GlassContainer(
              radius: radius,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(8),
                  vertical: ResponsiveHelper.padding(8),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: icons.length,
                        separatorBuilder: (_, __) => SizedBox(
                          width: ResponsiveHelper.spacing(6),
                        ),
                        itemBuilder: (_, index) {
                          return NavItem(
                            icon: icons[index],
                            index: index,
                            selected: currentIndex == index,
                            onTap: () => onChanged(index),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      width: ResponsiveHelper.spacing(8),
                    ),

                    Container(
                      width: ResponsiveHelper.width(58),
                      height: ResponsiveHelper.width(58),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff111111),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.white,
                        size: ResponsiveHelper.iconSize(22),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}
