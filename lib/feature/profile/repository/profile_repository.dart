import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class ProfileRepository {
  Future<http.Response> getProfile() async {
    return await ApiClient.getData(uri: ApiUrl.updateProfile);
  }

  Future<http.Response> updateProfile({
    String? nickName,
    String? licenceId,
    File? imageFile,
  }) async {
    List<http.MultipartFile> files = [];
    Map<String, String> fields = {};

    // Add text fields
    if (nickName != null && nickName.isNotEmpty) {
      fields['nick_name'] = nickName;
    }
    if (licenceId != null && licenceId.isNotEmpty) {
      fields['licence_id'] = licenceId;
    }

    // Add image file
    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'avatar', // Check your backend - might be 'image', 'profile_image', etc.
        stream,
        length,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      files.add(multipartFile);
    }

    return await ApiClient.multipartRequest(
      uri: ApiUrl.updateProfile,
      method: 'PUT', // Or 'PATCH' - check your backend
      fields: fields,
      files: files.isNotEmpty ? files : null,
    );
  }
}