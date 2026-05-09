import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowProfileImageScreen extends StatelessWidget {
  final String image;

  const ShowProfileImageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = image.startsWith("http");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: isNetwork
              ? Image.network(image)
              : Image.file(File(image)),
        ),
      ),
    );
  }
}