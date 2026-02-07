import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../utils/color/app_colors.dart';



class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitCircle(
        color: color?? AppColors.black,
        size: 40.0,
      ),
    );
  }
}
