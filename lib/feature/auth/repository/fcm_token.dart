import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return token;
}