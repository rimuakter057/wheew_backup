import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'dart:async';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../core/router/routes.dart';

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

  // Ensures the permission flow only runs once per app session — the
  // first time a parking function actually needs the user's location,
  // never eagerly at login.
  bool _hasBootstrapped = false;

  BuildContext? get _dialogContext =>
      AppRouter.navigatorKey.currentState?.overlay?.context ??
          AppRouter.navigatorKey.currentContext;

  // ─── onClose ──────────────────────────────────────────────
  @override
  void onClose() {
    _log('🔴', 'onClose', 'Cancelling location stream...');
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _log('🔴', 'onClose', 'Controller disposed');
    super.onClose();
  }

  // ─── Call the first time a parking function is used ──────
  Future<void> initLocationTracking() async {
    if (_hasBootstrapped) return;
    _hasBootstrapped = true;

    _divider();
    _log('🛰️', 'initLocationTracking', 'CALLED — first parking function use');
    _divider();

    try {
      final foregroundGranted = await _ensureForegroundPermission();
      if (!foregroundGranted) {
        _hasBootstrapped = false; // allow retrying next time a parking function runs
        return;
      }

      // প্রথমে একবার POST করো
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _log('📍', 'initLocationTracking', 'Initial position — lat: ${position.latitude}, lng: ${position.longitude}');
      await _postLocation(latitude: position.latitude, longitude: position.longitude);

      // তারপর tracking শুরু করো
      _startLocationTracking();

      // Background/"Always" access is a distinct second step, requested
      // only after foreground location is already granted — with an
      // in-app explanation shown before the system dialog appears.
      await _maybeUpgradeToBackgroundLocation();

    } catch (e, stack) {
      _divider();
      _log('💥', 'initLocationTracking', 'ERROR: $e');
      _log('💥', 'initLocationTracking', 'StackTrace:\n$stack');
      _divider();
    }
  }

  // ─── Foreground permission (step 1) ───────────────────────
  Future<bool> _ensureForegroundPermission() async {
    _log('📍', 'permission', 'Checking location service...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log('❌', 'permission', 'Location service is OFF');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _log('❌', 'permission', 'Foreground permission not granted');
      return false;
    }

    _log('✅', 'permission', 'Foreground permission granted');
    return true;
  }

  // ─── Background/"Always" permission (step 2) ──────────────
  Future<void> _maybeUpgradeToBackgroundLocation() async {
    final status = await ph.Permission.locationAlways.status;
    if (status.isGranted || status.isPermanentlyDenied) {
      _log('📍', 'permission', 'Background location status: $status (no prompt needed)');
      return;
    }

    final ctx = _dialogContext;
    if (ctx == null) return;

    final wantsUpgrade = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on_rounded,
                      size: 40, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.backgroundLocationRationaleTitle.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.backgroundLocationRationaleDesc.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.notNow.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF185FA5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.allow.tr,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (wantsUpgrade == true) {
      final result = await ph.Permission.locationAlways.request();
      _log('📍', 'permission', 'Background location request result: $result');
    }
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
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
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

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
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