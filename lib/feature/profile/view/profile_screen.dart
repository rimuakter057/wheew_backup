import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/profile_controller.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          GetBuilder<ProfileController>(
            init: ProfileController(),
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  if (controller.isEditing) {
                    controller.updateProfile();
                  } else {
                    controller.toggleEdit();
                  }
                },
                child: Text(
                  controller.isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (controller.isLoading && controller.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                /// Profile Image
                Obx(() {
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      controller.profileImage.value != null
                          ? CircleAvatar(
                        radius: 45,
                        backgroundImage: FileImage(controller.profileImage.value!),
                      )
                          : UserAvatar(
                        imagePath: controller.userProfile.value?.avatar,
                        radius: 45,
                      ),
                      if (controller.isEditing)
                        GestureDetector(
                          onTap: controller.pickImageFromGallery,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
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
                _textField(
                  controller: controller.nickNameController,
                  hintText: 'Nick name',
                  enabled: false, // Always disabled
                ),

                const SizedBox(height: 20),

                _label('License Number'),
                _textField(
                  controller: controller.licenseController,
                  hintText: 'License number',
                  enabled: false, // Always disabled
                ),

                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/profile_controller.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          GetBuilder<ProfileController>(
            init: ProfileController(),
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  if (controller.isEditing) {
                    controller.updateProfile();
                  } else {
                    controller.toggleEdit();
                  }
                },
                child: Text(
                  controller.isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (controller.isLoading && controller.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                /// Profile Image
                Obx(() {
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      controller.profileImage.value != null
                          ? CircleAvatar(
                        radius: 45,
                        backgroundImage: FileImage(controller.profileImage.value!),
                      )
                          : UserAvatar(
                        imagePath: controller.userProfile.value?.avatar,
                        radius: 45,
                      ),
                      if (controller.isEditing)
                        GestureDetector(
                          onTap: controller.pickImageFromGallery,
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
                _textField(
                  controller: controller.nickNameController,
                  hintText: 'Enter nick name',
                  enabled: controller.isEditing,
                ),

                const SizedBox(height: 20),

                _label('License Number'),
                _textField(
                  controller: controller.licenseController,
                  hintText: 'Enter license number',
                  enabled: controller.isEditing,
                ),

                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
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
}*/
