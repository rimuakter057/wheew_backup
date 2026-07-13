import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

class MessageController extends GetxController {
  // Received Requests
  final RxList<dynamic> messageRequests = <dynamic>[].obs;
  final RxBool isLoadingRequests = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalRequestsCount = 0.obs;

  int _page = 1;
  final int _limit = 10;

  // Sent Requests
  final RxList<dynamic> sentRequests = <dynamic>[].obs;
  final RxBool isLoadingSentRequests = false.obs;
  final RxBool isLoadMoreSent = false.obs;
  final RxBool hasMoreSent = true.obs;
  final RxInt totalSentRequestsCount = 0.obs;

  int _sentPage = 1;
  final int _sentLimit = 30;

  Future<void> fetchMessageRequestInbox({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      isLoadingRequests.value = true;
      messageRequests.clear();
    } else {
      if (!hasMore.value || isLoadMore.value || isLoadingRequests.value) return;
      isLoadMore.value = true;
    }

    try {
      final response = await ApiClient.getData(
        uri: '${ApiUrl.getMessageRequestInbox}?page=$_page&limit=$_limit',
      );


      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final List<dynamic> requests = decoded['requests'] ?? [];
          final int total = decoded['total'] ?? 0;
          totalRequestsCount.value = total;

          if (refresh) {
            messageRequests.assignAll(requests);
          } else {
            messageRequests.addAll(requests);
          }

          if (requests.length < _limit || messageRequests.length >= total) {
            hasMore.value = false;
          } else {
            _page++;
          }
        }
      } else {
        debugPrint('Failed to load message requests: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchMessageRequestInbox error: $e');
    } finally {
      isLoadingRequests.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> fetchSentMessageRequests({bool refresh = false}) async {
    if (refresh) {
      _sentPage = 1;
      hasMoreSent.value = true;
      isLoadingSentRequests.value = true;
      sentRequests.clear();
    } else {
      if (!hasMoreSent.value || isLoadMoreSent.value || isLoadingSentRequests.value) return;
      isLoadMoreSent.value = true;
    }

    try {
      final response = await ApiClient.getData(
        uri: '${ApiUrl.getSentMessageRequests}?page=$_sentPage&limit=$_sentLimit',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final List<dynamic> requests = decoded['requests'] ?? [];
          final int total = decoded['total'] ?? 0;
          totalSentRequestsCount.value = total;

          if (refresh) {
            sentRequests.assignAll(requests);
          } else {
            sentRequests.addAll(requests);
          }

          if (requests.length < _sentLimit || sentRequests.length >= total) {
            hasMoreSent.value = false;
          } else {
            _sentPage++;
          }
        }
      } else {
        debugPrint('Failed to load sent requests: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchSentMessageRequests error: $e');
    } finally {
      isLoadingSentRequests.value = false;
      isLoadMoreSent.value = false;
    }
  }

  Future<bool> acceptMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.acceptMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Request accepted!');
        messageRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalRequestsCount.value = (totalRequestsCount.value - 1).clamp(0, 999999);
        return true;
      } else {
        String errMsg = 'Failed to accept message request';
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('acceptMessageRequest error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to accept request.');
      return false;
    }
  }

  Future<bool> declineMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.declineMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Request declined.');
        messageRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalRequestsCount.value = (totalRequestsCount.value - 1).clamp(0, 999999);
        return true;
      } else {
        String errMsg = 'Failed to decline message request';
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('declineMessageRequest error: $e');
      CustomSnackbar.error(context: context, message: 'Failed to decline request.');
      return false;
    }
  }
}
