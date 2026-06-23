// ignore_for_file: unused_field

import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'api_url.dart';

class AppSocket {
  factory AppSocket() => _instance;
  AppSocket._internal();

  static final AppSocket _instance = AppSocket._internal();
  static io.Socket? socket;
  static bool _isInitialized = false;
  static Function? _onSocketConnectCallback;
  static String? _userId;

  static bool get isConnected => socket?.connected ?? false;

  ///<------------------ Public Init ------------------>
  static Future<void> init({Function? onSocketConnect}) async {
    _onSocketConnectCallback = onSocketConnect;

    // Retrieve userId from SharedPreferences or fallback
    _userId = await SharePrefsHelper.getString(AppConst.userID);

    if (_userId == null || _userId!.isEmpty || _userId == "null") {
      debugPrint(
        '⚠️ No userId found in SharedPreferences. Socket not connecting.',
      );
      return;
    }

    _connectToSocket(_userId!);
    _isInitialized = true;
  }

  ///<------------------ Internal Connect ------------------>
  static void _connectToSocket(String userId) {
    final socketUrl = ApiUrl.socketUrl(userId: userId);
    debugPrint('Connecting socket with userId: $userId → $socketUrl');

    socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _registerListeners();
  }

  ///<------------------ Register Events ------------------>
  static void _registerListeners() {
    if (socket == null) return;

    socket!
      ..onConnect((_) {
        debugPrint('✅ Socket connected as $_userId');
        _onSocketConnectCallback?.call();
      })
      ..onDisconnect((data) {
        debugPrint('🔌 Disconnected: $data');
      })
      ..onReconnectAttempt((attempt) {
        debugPrint('🔁 Reconnect attempt: $attempt');
      })
      ..onReconnectFailed((_) {
        debugPrint('❌ Reconnect failed');
      })
      ..onError((error) {
        debugPrint('⚠️ Socket error: $error');
      })
      ..on('unauthorized', (data) {
        debugPrint('❌ Unauthorized: $data');
      });
  }

  ///<------------------ Listen for Events ------------------>
  // Public method for listening to socket events
  static void onEvent(String eventName, Function(dynamic) callback) {
    if (socket != null) {
      debugPrint('Registering socket listener for event: "$eventName".');
      socket!.on(eventName, callback);
    } else {
      debugPrint('⚠️ Socket is null. Cannot listen for "$eventName".');
    }
  }

  ///<------------------ Emit Events ------------------>
  static void sendEvent(String eventName, dynamic data) {
    if (!isConnected) {
      debugPrint('❌ Socket not connected. Cannot emit "$eventName".');
      return;
    }
    socket!.emit(eventName, data);
  }

  static void emitWithAck(
    String event,
    dynamic data, {
    required Function(dynamic response) ack,
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (!isConnected) {
      debugPrint('❌ Socket not connected. Cannot emit "$event".');
      ack(false);
      return;
    }

    socket!.emitWithAck(
      event,
      data,
      ack: (response) {
        ack(response);
      },
      //timeout: timeout,
    );
  }

  ///<------------------ Cleanup ------------------>
  static void dispose() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _isInitialized = false;
    _userId = null;
    _onSocketConnectCallback = null;
    debugPrint('🧹 Socket disposed');
  }
}

