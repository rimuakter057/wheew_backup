import 'package:flutter/material.dart';

import '../../utils/color/app_colors.dart';
import '../responsive_helper/responsive_helper.dart';

class CommonContainer extends StatelessWidget {
  const CommonContainer({
    super.key,
    required this.child, this.bgColor, this.borderRadius, this.horizontalPadding, this.verticalPadding,
  });

  final Widget child;
  final Color?bgColor;
  final  double?borderRadius;
  final  double?horizontalPadding;
  final  double?verticalPadding;



  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal:
          ResponsiveHelper.padding(horizontalPadding??12),
          vertical:
          ResponsiveHelper.padding(verticalPadding??8),
        ),
        decoration: BoxDecoration(
            color:bgColor?? Color(0xFFEEF1F6),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius??30),
            ),
            border: Border.all(color: AppColors.white)
        ),
        child: child
    );
  }
}

