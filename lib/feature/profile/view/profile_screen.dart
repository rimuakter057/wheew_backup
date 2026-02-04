/*
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            /// Profile Image with Camera Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage:
                  AssetImage('assets/images/person3.png'),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
*/
/*

            /// Name
            const Text(
              'Cameron Williamson',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            /// ID
            const Text(
              '2514596241584692',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
*//*


            const SizedBox(height: 32),

            /// Nick Name
            _label('Nick Name'),
            _textField(
              hintText: 'Hasan',
              enabled: false,
            ),

            const SizedBox(height: 20),

            /// License Number
            _label('License Number'),
            _textField(
              hintText: '2514596241584692',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _textField({
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../share/controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            /// Profile Image
            Obx(() {
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: profileController.profileImage.value != null
                        ? FileImage(
                        profileController.profileImage.value as File)
                        : const AssetImage('assets/images/person3.png')
                    as ImageProvider,
                  ),
                  GestureDetector(
                    onTap: profileController.pickImageFromGallery,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 32),

            _label('Nick Name'),
            _textField(hintText: 'Hasan', enabled: false),

            const SizedBox(height: 20),

            _label('License Number'),
            _textField(
              hintText: '2514596241584692',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500)),
  );

  Widget _textField({
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
