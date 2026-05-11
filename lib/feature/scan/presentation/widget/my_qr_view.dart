import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class MyQrView extends StatelessWidget {
  const MyQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.iconSize(240),
            height: ResponsiveHelper.iconSize(240),
            color: Colors.white,
            child: const Icon(Icons.qr_code_2, size: 150),
          ),

          const SizedBox(height: 20),

          Text('show_qr_to_connect'.tr),
        ],
      ),
    );
  }
}