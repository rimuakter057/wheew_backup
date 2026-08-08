import 'package:platchatapp/utils/color/app_colors.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class ShowProfileImageScreen extends StatelessWidget {
  final String image;

  const ShowProfileImageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = image.startsWith("http");

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: isNetwork ? Image.network(image) : Image.file(File(image)),
        ),
      ),
    );
  }
}

