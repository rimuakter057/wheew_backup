import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  /// Rx file (nullable)
  Rx<File?> profileImage = Rx<File?>(null);

  Future<void> pickImageFromGallery() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }
}
