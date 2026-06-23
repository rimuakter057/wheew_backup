// // ignore_for_file: depend_on_referenced_packages
//
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// // ══════════════════════════════════════════════════════════════════
// //  Background handler — top-level function, isolate-safe
// // ══════════════════════════════════════════════════════════════════
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Firebase is already initialised by main() before this is called on Android
//   debugPrint('🔔 [BG] Message received: ${message.messageId}');
//   await NotificationService.instance.showNotification(message);
// }
//
// // ══════════════════════════════════════════════════════════════════
// //  NotificationService
// // ══════════════════════════════════════════════════════════════════
// class NotificationService {
//   NotificationService._();
//   static final NotificationService instance = NotificationService._();
//
//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();
//
//   // Android notification channel (sound = message_chime.wav in res/raw)
//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'messages_channel',        // id
//     'Messages',                // name
//     description: 'New message notifications',
//     importance: Importance.high,
//     playSound: true,
//     sound: RawResourceAndroidNotificationSound('message_chime'),
//   );
//
//   // ── init ──────────────────────────────────────────────────────
//   Future<void> init() async {
//     // 1. Create channel on Android
//     await _plugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel);
//
//     // 2. Initialise plugin
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _plugin.initialize(
//       settings: initSettings,
//       onDidReceiveNotificationResponse: _onTap,
//     );
//
//     // 3. Request permission
//     await _requestPermission();
//
//     // 4. FCM foreground presentation (iOS)
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // 5. Listen for foreground messages
//     FirebaseMessaging.onMessage.listen(_onForegroundMessage);
//
//     // 6. App opened from a notification (background → foreground)
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
//
//     debugPrint('✅ NotificationService initialized');
//   }
//
//   // ── Permission ────────────────────────────────────────────────
//   Future<void> _requestPermission() async {
//     if (Platform.isIOS) {
//       await FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     } else if (Platform.isAndroid) {
//       await _plugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     }
//   }
//
//   // ── Foreground message → show local notification + sound via FCM ─
//   Future<void> _onForegroundMessage(RemoteMessage message) async {
//     debugPrint('🔔 [FG] Message: ${message.notification?.title}');
//     // On iOS foreground is handled by setForegroundNotificationPresentationOptions
//     // On Android we must show manually because FCM won't show a heads-up while app is open
//     if (Platform.isAndroid) {
//       await showNotification(message);
//     }
//   }
//
//   // ── Show local notification ───────────────────────────────────
//   Future<void> showNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     if (notification == null) return;
//
//     final title = notification.title ?? 'New Message';
//     final body = notification.body ?? '';
//
//     final AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       _channel.id,
//       _channel.name,
//       channelDescription: _channel.description,
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       sound: const RawResourceAndroidNotificationSound('message_chime'),
//       icon: '@mipmap/ic_launcher',
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: 'message_chime.wav',  // must be in Runner/Runner in Xcode
//     );
//
//     final NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _plugin.show(
//       id: message.hashCode,
//       title: title,
//       body: body,
//       notificationDetails: details,
//       payload: message.data['chatRoomId'] ?? '',
//     );
//   }
//
//   // ── Notification tap ──────────────────────────────────────────
//   void _onTap(NotificationResponse response) {
//     debugPrint('🔔 Notification tapped, payload: ${response.payload}');
//     // TODO: navigate to specific chat room using response.payload (chatRoomId)
//   }
//
//   void _onMessageOpenedApp(RemoteMessage message) {
//     debugPrint('🔔 App opened from notification: ${message.data}');
//     // TODO: navigate to specific chat room
//   }
// }




// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';

// ══════════════════════════════════════════════════════════════════
//  Background handler — top-level function, isolate-safe
// ══════════════════════════════════════════════════════════════════
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by main() before this is called on Android
  debugPrint('🔔 [BG] Message received: ${message.messageId}');
  await NotificationService.instance.showNotification(message);
}

// ══════════════════════════════════════════════════════════════════
//  NotificationService
// ══════════════════════════════════════════════════════════════════
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // Android notification channel (sound = message_chime.wav in res/raw)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'messages_channel',        // id
    'Messages',                // name
    description: 'New message notifications',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('message_chime'),
  );

  // ── init ──────────────────────────────────────────────────────
  Future<void> init() async {
    // 1. Create channel on Android
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 2. Initialise plugin
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // 3. Request permission
    await _requestPermission();

    // 4. FCM foreground presentation (iOS)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 6. App opened from a notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 7. Auto-upload FCM token on token refreshes and app launch
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _uploadToken(token);
    });
    _uploadCurrentToken();

    debugPrint('✅ NotificationService initialized');
  }

  Future<void> _uploadCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _uploadToken(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _uploadToken(String token) async {
    try {
      final bool isLoggedIn = await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        debugPrint('Skipping FCM token upload: User is not logged in');
        return;
      }

      final response = await ApiClient.patchData(
        uri: ApiUrl.updateProfile,
        body: {'fcm_token': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ FCM token successfully updated on backend: $token');
      } else {
        debugPrint('❌ Failed to update FCM token on backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading FCM token: $e');
    }
  }

  // ── Permission ────────────────────────────────────────────────
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // ── Foreground message → show local notification + sound via FCM ─
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 [FG] Message: ${message.notification?.title}');
    // On iOS foreground is handled by setForegroundNotificationPresentationOptions
    // On Android we must show manually because FCM won't show a heads-up while app is open
    if (Platform.isAndroid) {
      await showNotification(message);
    }
  }

  // ── Show local notification ───────────────────────────────────
  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'New Message';
    final body = notification.body ?? '';

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('message_chime'),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'message_chime.wav',  // must be in Runner/Runner in Xcode
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      message.hashCode,
      title,
      body,
      details,
      payload: message.data['chatRoomId'] ?? '',
    );
  }

  // ── Notification tap ──────────────────────────────────────────
  void _onTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped, payload: ${response.payload}');
    // TODO: navigate to specific chat room using response.payload (chatRoomId)
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 App opened from notification: ${message.data}');
    // TODO: navigate to specific chat room
  }
}