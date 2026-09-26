
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_service.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/notification/models/notification_model.dart';


class NotificationController extends GetxController {
  // ── State ─────────────────────────────────────────────────────
  RxList<NotificationEvent> notifications = <NotificationEvent>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isDeleting = false.obs;
  RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(refresh: true);
  }

  int _page = 1;
  final int _limit = 20;
  int _total = 0;
  bool _isFetching = false;

  bool get hasMore => notifications.length < _total;

  /// ── GET /notifications/events?page=1&limit=20 ─────────────────
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isFetching) return;
    if (refresh) {
      _page = 1;
      _total = 0;
      notifications.clear();
    }
    if (_page > 1 && !hasMore) return;

    _isFetching = true;
    if (_page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final uri = ApiUrl.getNotifications(page: _page, limit: _limit);
      final response = await ApiClient.getData(uri: uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        _total = body['total'] ?? 0;
        unreadCount.value = body['unreadCount'] ?? 0;

        final List events = body['events'] ?? [];

        final parsed = events
            .map((e) => NotificationEvent.fromJson(e))
            .toList();

        if (_page == 1) {
          notifications.value = parsed;
        } else {
          notifications.addAll(parsed);
        }

        _page++;

        debugPrint(
          '✅ Notifications fetched: ${notifications.length}/$_total',
        );
      }
    } catch (e) {
      debugPrint('❌ fetchNotifications error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isFetching = false;
    }
  }

  /// ── PATCH /notifications/events/:id/read ──────────────────────
  Future<void> markOneAsRead(String id) async {
    try {
      final response = await ApiClient.patchData(
        uri: ApiUrl.markNotificationRead(id: id),
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1 && !notifications[index].isRead) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          notifications.refresh();
          if (unreadCount.value > 0) unreadCount.value--;
          debugPrint('✅ Marked as read: $id');
        }
      }
    } catch (e) {
      debugPrint('❌ markOneAsRead error: $e');
    }
  }

  // ── PATCH /notifications/read-all ─────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      final response = await ApiClient.patchData(
        uri: ApiUrl.markAllNotificationsRead,
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifications.value = notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        unreadCount.value = 0;
        debugPrint('✅ All notifications marked as read');
      }
    } catch (e) {
      debugPrint('❌ markAllAsRead error: $e');
    }
  }

  // ── DELETE /notifications/events/:id ──────────────────────────
  Future<void> deleteOne(String id) async {
    try {
      final response = await ApiClient.deleteData(
        uri: ApiUrl.deleteNotification(id: id),
      );

      final statusCode = response['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        final removed = notifications.firstWhereOrNull((n) => n.id == id);
        notifications.removeWhere((n) => n.id == id);
        if (removed != null && !removed.isRead && unreadCount.value > 0) {
          unreadCount.value--;
        }
        _total = (_total - 1).clamp(0, _total);
        debugPrint('✅ Notification deleted: $id');
      }
    } catch (e) {
      debugPrint('❌ deleteOne error: $e');
    }
  }

  // ── DELETE /notifications/events (delete all) ─────────────────
  Future<void> deleteAll(BuildContext context) async {
    isDeleting.value = true;
    try {
      final response = await ApiClient.deleteData(
        uri: ApiUrl.deleteAllNotifications,
      );

      final statusCode = response['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        notifications.clear();
        unreadCount.value = 0;
        _total = 0;
        _page = 1;
        debugPrint('✅ All notifications deleted');
      }
    } catch (e) {
      debugPrint('❌ deleteAll error: $e');
    } finally {
      isDeleting.value = false;
    }
  }
}