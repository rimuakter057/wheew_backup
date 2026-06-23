// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Response;
// import 'package:platchatapp/core/service/api_client.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'notification_model.dart';
// import 'faq_model.dart';
//
// class NotificationFaqController extends GetxController {
//
//   // ── Notification ─────────────────────────────────────────────
//   RxList<NotificationModel> notifications = <NotificationModel>[].obs;
//   RxBool isLoadingNotification = false.obs;
//   RxInt unreadCount = 0.obs;
//
//   Future<void> fetchNotifications({bool refresh = false}) async {
//     if (refresh) notifications.clear();
//     isLoadingNotification.value = true;
//
//     try {
//       final response = await ApiClient.getData(uri: ApiUrl.notifications);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         List list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['notifications'] != null) {
//           list = data['notifications'];
//         } else if (data['data'] != null) {
//           list = data['data'];
//         }
//
//         notifications.value = list
//             .map((e) => NotificationModel.fromJson(e))
//             .toList();
//
//         unreadCount.value = notifications.where((n) => !n.isRead).length;
//         debugPrint('✅ Notifications loaded: ${notifications.length}');
//       }
//     } catch (e) {
//       debugPrint('❌ fetchNotifications error: $e');
//     } finally {
//       isLoadingNotification.value = false;
//     }
//   }
//
//   Future<void> markAllAsRead() async {
//     try {
//       final response = await ApiClient.patchData(
//         uri: ApiUrl.markAllNotificationsRead,
//         body: {},
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         notifications.value = notifications
//             .map((n) => NotificationModel(
//           id: n.id,
//           title: n.title,
//           body: n.body,
//           isRead: true,
//           createdAt: n.createdAt,
//           type: n.type,
//         ))
//             .toList();
//         unreadCount.value = 0;
//         debugPrint('✅ All notifications marked as read');
//       }
//     } catch (e) {
//       debugPrint('❌ markAllAsRead error: $e');
//     }
//   }
//
//   Future<void> markOneAsRead(String id) async {
//     try {
//       final response = await ApiClient.patchData(
//         uri: ApiUrl.markNotificationRead(id: id),
//         body: {},
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final index = notifications.indexWhere((n) => n.id == id);
//         if (index != -1) {
//           final n = notifications[index];
//           notifications[index] = NotificationModel(
//             id: n.id,
//             title: n.title,
//             body: n.body,
//             isRead: true,
//             createdAt: n.createdAt,
//             type: n.type,
//           );
//           unreadCount.value = notifications.where((n) => !n.isRead).length;
//           notifications.refresh();
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ markOneAsRead error: $e');
//     }
//   }
//
//   // ── FAQ ──────────────────────────────────────────────────────
//   RxList<FaqModel> faqs = <FaqModel>[].obs;
//   RxBool isLoadingFaq = false.obs;
//
//   Future<void> fetchFaqs() async {
//     isLoadingFaq.value = true;
//
//     try {
//       final response = await ApiClient.getData(uri: ApiUrl.faqs);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         List list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['faqs'] != null) {
//           list = data['faqs'];
//         } else if (data['data'] != null) {
//           list = data['data'];
//         }
//
//         faqs.value = list.map((e) => FaqModel.fromJson(e)).toList();
//         debugPrint('✅ FAQs loaded: ${faqs.length}');
//       }
//     } catch (e) {
//       debugPrint('❌ fetchFaqs error: $e');
//     } finally {
//       isLoadingFaq.value = false;
//     }
//   }
// }