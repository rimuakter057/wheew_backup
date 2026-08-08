import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:platchatapp/core/service/api_client.dart';

import '../../../utils/language/app_string.dart';

// ─── Debug Helper ─────────────────────────────────────────────────────────────
void _log(String emoji, String section, String msg) {
  debugPrint('$emoji [LocationController][$section] $msg');
}

void _divider() {
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// ─── Controller ───────────────────────────────────────────────────────────────
class UserLocationController extends GetxController {
  // ─── Location Stream ──────────────────────────────────────
  StreamSubscription<Position>? _locationSubscription;

  // ─── onClose ──────────────────────────────────────────────
  @override
  void onClose() {
    _log('🔴', 'onClose', 'Cancelling location stream...');
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _log('🔴', 'onClose', 'Controller disposed');
    super.onClose();
  }

  // ─── Login success এর পরে call করবে ──────────────────────
  Future<void> initLocationTracking() async {
    _divider();
    _log('🛰️', 'initLocationTracking', 'CALLED — after login success');
    _divider();

    try {
      // Permission check
      await _checkPermission();

      // প্রথমে একবার POST করো
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _log(
        '📍',
        'initLocationTracking',
        'Initial position — lat: ${position.latitude}, lng: ${position.longitude}',
      );
      await _postLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // তারপর tracking শুরু করো
      _startLocationTracking();
    } catch (e, stack) {
      _divider();
      _log('💥', 'initLocationTracking', 'ERROR: $e');
      _log('💥', 'initLocationTracking', 'StackTrace:\n$stack');
      _divider();
    }
  }

  // ─── Permission Check ─────────────────────────────────────
  Future<void> _checkPermission() async {
    _log('📍', 'permission', 'Checking location service...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log('❌', 'permission', 'Location service is OFF');
      throw Exception(AppStrings.locationServicesDisabled.tr);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _log('❌', 'permission', 'Permission denied by user');
        throw Exception(AppStrings.locationPermissionDenied.tr);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log('❌', 'permission', 'Permission permanently denied');
      throw Exception(AppStrings.locationPermissionDenied.tr);
    }

    _log('✅', 'permission', 'Permission granted');
  }

  // ─── POST location to backend ─────────────────────────────
  Future<void> _postLocation({
    required double latitude,
    required double longitude,
  }) async {
    _divider();
    _log('📤', 'postLocation', 'POST /users/location');
    _log('📤', 'postLocation', 'Latitude  : $latitude');
    _log('📤', 'postLocation', 'Longitude : $longitude');
    _divider();

    try {
      final response = await ApiClient.postData(
        uri: '/users/location',
        body: {'latitude': latitude, 'longitude': longitude},
      );

      _divider();
      _log('📥', 'postLocation', 'Status : ${response.statusCode}');
      _log('📥', 'postLocation', 'Body   : ${response.body}');
      _divider();

      if (response.statusCode == 200) {
        _log('✅', 'postLocation', 'Location updated successfully');
      } else {
        _log('❌', 'postLocation', 'Failed — HTTP ${response.statusCode}');
      }
    } catch (e, stack) {
      _divider();
      _log('💥', 'postLocation', 'EXCEPTION: $e');
      _log('💥', 'postLocation', 'StackTrace:\n$stack');
      _divider();
    }
  }

  // ─── Continuous Tracking (1 মিটার সরলে POST) ─────────────
  void _startLocationTracking() {
    _locationSubscription?.cancel();

    _log('🛰️', 'startTracking', 'Stream started — distanceFilter: 1m');

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // ← 1 মিটার সরলে fire হবে
    );

    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
            _divider();
            _log('📍', 'trackingUpdate', 'User moved!');
            _log('📍', 'trackingUpdate', 'Latitude  : ${position.latitude}');
            _log('📍', 'trackingUpdate', 'Longitude : ${position.longitude}');
            _log('📍', 'trackingUpdate', 'Accuracy  : ${position.accuracy}m');
            _divider();

            await _postLocation(
              latitude: position.latitude,
              longitude: position.longitude,
            );
          },
          onError: (e, stack) {
            _divider();
            _log('💥', 'trackingUpdate', 'Stream ERROR: $e');
            _log('💥', 'trackingUpdate', 'StackTrace:\n$stack');
            _divider();
          },
        );

    _log('✅', 'startTracking', 'Location stream is now active');
  }
}
