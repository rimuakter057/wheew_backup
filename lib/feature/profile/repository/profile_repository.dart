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

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class ProfileRepository {
  /// ✅ Get user profile
  Future<http.Response> getProfile() async {
    return await ApiClient.getData(uri: ApiUrl.profile);
  }

  /// ✅ Update avatar + vehicle fields
  Future<http.Response> updateAvatar({
    File? imageFile,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
  }) async {
    final List<http.MultipartFile> files = [];
    final Map<String, String> fields = {};

    if (imageFile != null) {
      files.add(await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (vehicleType != null && vehicleType.isNotEmpty) {
      fields['vehicle_type'] = vehicleType;
    }
    if (vehicleModel != null && vehicleModel.isNotEmpty) {
      fields['vehicle_model'] = vehicleModel;
    }
    if (vehicleColor != null && vehicleColor.isNotEmpty) {
      fields['vehicle_color'] = vehicleColor;
    }

    return await ApiClient.multipartRequest(
      uri: ApiUrl.updateProfile,
      method: 'PATCH',
      files: files,
      fields: fields,
    );
  }







}



