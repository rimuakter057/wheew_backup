import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import '../models/faq_model.dart';

class FaqController extends GetxController {
  final RxList<FaqModel> faqs = <FaqModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    isLoading.value = true;
    error.value = null;
    try {
      final response = await ApiClient.getData(uri: '/faqs?page=1&limit=50');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['faqs'] ?? [];
        faqs.assignAll(list.map((e) => FaqModel.fromJson(e)).toList());
      } else {
        error.value = 'Failed to load FAQs: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ Error fetching FAQs: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
