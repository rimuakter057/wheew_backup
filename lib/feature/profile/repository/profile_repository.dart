/*
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class ProfileRepository {
  /// Get user profile
  Future<http.Response> getProfile() async {
    return await ApiClient.getData(uri: ApiUrl.updateProfile);
  }

  /// Update ONLY avatar
  Future<http.Response> updateAvatar({required File imageFile}) async {
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );

    return await ApiClient.multipartRequest(
      uri: ApiUrl.updateProfile,
      method: 'PATCH', // Changed from 'PUT' to 'PATCH'
      files: [multipartFile],
    );
  }
}
*/

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class ProfileRepository {

  /// ✅ Get user profile
  Future<http.Response> getProfile() async {
    return await ApiClient.getData(uri: ApiUrl.profile);
  }

  /// ✅ Update ONLY avatar
  Future<http.Response> updateAvatar({required File imageFile}) async {
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );

    return await ApiClient.multipartRequest(
      uri: ApiUrl.updateProfile,
      method: 'PATCH',
      files: [multipartFile],
    );
  }
}