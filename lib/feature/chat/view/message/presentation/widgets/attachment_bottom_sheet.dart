import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class AttachmentBottomSheet {
  static void show({
    required BuildContext context,
    required Function(String filePath, String type) onFileSelected,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Camera
                        _AttachOption(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: Colors.orange,
                          onTap: () async {
                            Navigator.pop(context);
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                            );
                            if (picked != null) {
                              onFileSelected(picked.path, 'image');
                            }
                          },
                        ),

                        // Gallery
                        _AttachOption(
                          icon: Icons.image_rounded,
                          label: 'Gallery',
                          color: Colors.purple,
                          onTap: () async {
                            Navigator.pop(context);
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );
                            if (picked != null) {
                              onFileSelected(picked.path, 'image');
                            }
                          },
                        ),

                        // Document
                        _AttachOption(
                          icon: Icons.insert_drive_file_rounded,
                          label: 'Document',
                          color: Colors.blue,
                          onTap: () async {
                            Navigator.pop(context);
                            final picker = ImagePicker();
                            final picked = await picker.pickMedia();
                            if (picked != null) {
                              onFileSelected(picked.path, 'document');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}