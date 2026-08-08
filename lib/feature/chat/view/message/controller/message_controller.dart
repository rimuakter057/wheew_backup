import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

import '../../../../../utils/language/app_string.dart';

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

  /// GET /chat/message-requests/counts — dedicated badge-count endpoint,
  /// used instead of deriving the count from a full inbox/sent list fetch.
  Future<void> fetchMessageRequestCounts() async {
    try {
      final response = await ApiClient.getData(uri: ApiUrl.getMessageRequestCounts);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Response shape: { "received": { "pending": n }, "sent": { "pending": n, ... } }
          final dynamic receivedRaw = decoded['received'];
          final dynamic sentRaw = decoded['sent'];

          final int? receivedCount = receivedRaw is Map
              ? int.tryParse((receivedRaw['pending'] ?? 0).toString())
              : int.tryParse((receivedRaw ?? '').toString());
          final int? sentCount = sentRaw is Map
              ? int.tryParse((sentRaw['pending'] ?? 0).toString())
              : int.tryParse((sentRaw ?? '').toString());

          totalRequestsCount.value = receivedCount ?? 0;
          totalSentRequestsCount.value = sentCount ?? 0;
        }
      } else {
        debugPrint('Failed to load message request counts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchMessageRequestCounts error: $e');
    }
  }

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

  /// Returns the newly-created room's id on success (so callers can jump
  /// straight into the chat), or null on failure.
  Future<String?> acceptMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.acceptMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(
          context: context,
          message: AppStrings.requestAccepted.tr,
        );
        messageRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalRequestsCount.value = (totalRequestsCount.value - 1).clamp(0, 999999);

        String roomId = '';
        try {
          final decoded = jsonDecode(response.body);
          roomId = decoded['room']?['id']?.toString() ?? '';
        } catch (_) {}
        return roomId.isNotEmpty ? roomId : '';
      } else {
        String errMsg =
            AppStrings.failedToAcceptMessageRequest.tr;
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return null;
      }
    } catch (e) {
      debugPrint('acceptMessageRequest error: $e');
      CustomSnackbar.error(
        context: context,
        message: AppStrings.failedToAcceptRequest.tr,
      );
      return null;
    }
  }

  Future<bool> rejectMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.rejectMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(
          context: context,
          message: AppStrings.requestRejected.tr,
        );
        messageRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalRequestsCount.value = (totalRequestsCount.value - 1).clamp(0, 999999);
        return true;
      } else {
        String errMsg =
            AppStrings.failedToAcceptMessageRequest.tr;
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('rejectMessageRequest error: $e');
      CustomSnackbar.success(
        context: context,
        message: AppStrings.requestRejected.tr,
      );
      return false;
    }
  }

  Future<bool> blockMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.blockMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(
          context: context,
          message: AppStrings.userBlocked.tr,
        );
        messageRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalRequestsCount.value = (totalRequestsCount.value - 1).clamp(0, 999999);
        return true;
      } else {
        String errMsg = AppStrings.failedToBlock.tr;
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('blockMessageRequest error: $e');
      CustomSnackbar.error(
        context: context,
        message: AppStrings.failedToBlock.tr,
      );
      return false;
    }
  }

  Future<bool> withdrawMessageRequest({
    required String requestId,
    required BuildContext context,
  }) async {
    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.withdrawMessageRequest(requestId),
        body: {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.success(context: context, message: 'Request withdrawn.');
        sentRequests.removeWhere((req) => req['id']?.toString() == requestId);
        totalSentRequestsCount.value = (totalSentRequestsCount.value - 1).clamp(0, 999999);
        return true;
      } else {
        String errMsg =
            AppStrings.failedToWithdrawMessageRequest.tr;
        try {
          final decoded = jsonDecode(response.body);
          errMsg = decoded['message'] ?? decoded['error'] ?? errMsg;
        } catch (_) {}
        CustomSnackbar.error(context: context, message: errMsg);
        return false;
      }
    } catch (e) {
      debugPrint('withdrawMessageRequest error: $e');
      CustomSnackbar.error(
        context: context,
        message: AppStrings.failedToWithdrawRequest.tr,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchMessageRequestThread(String requestId) async {
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.getMessageRequestThread(requestId),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (e) {
      debugPrint('fetchMessageRequestThread error: $e');
    }
    return null;
  }
}
