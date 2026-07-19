import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/feature/navigation/repository/directions_repository.dart';
import 'package:platchatapp/utils/language/app_string.dart';

enum TravelMode {
  walking,
  driving;

  /// Google Directions API `mode` query value.
  String get apiValue => switch (this) {
        TravelMode.walking => 'walking',
        TravelMode.driving => 'driving',
      };

  IconData get icon => switch (this) {
        TravelMode.walking => Icons.directions_walk,
        TravelMode.driving => Icons.directions_car,
      };

  String get label => switch (this) {
        TravelMode.walking => AppStrings.navModeWalking.tr,
        TravelMode.driving => AppStrings.navModeDriving.tr,
      };
}

class InAppNavigationController extends GetxController {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 3, lineLength: 100),
  );

  final Rxn<LatLng> origin = Rxn<LatLng>();
  final Rxn<LatLng> liveUserPosition = Rxn<LatLng>();
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rxn<DirectionsResult> routeInfo = Rxn<DirectionsResult>();

  // Walking is the default mode whenever the navigation screen opens.
  final Rx<TravelMode> selectedMode = TravelMode.walking.obs;

  final RxBool isLoadingRoute = true.obs;
  final RxBool hasRouteError = false.obs;
  final RxBool isLocationPermissionDenied = false.obs;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _destination;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> init({required LatLng destination}) async {
    _destination = destination;
    selectedMode.value = TravelMode.walking;
    isLoadingRoute.value = true;
    hasRouteError.value = false;
    isLocationPermissionDenied.value = false;

    final granted = await _ensureLocationPermission();
    if (!granted) {
      isLocationPermissionDenied.value = true;
      isLoadingRoute.value = false;
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);
      origin.value = currentLatLng;
      liveUserPosition.value = currentLatLng;

      await _fetchRoute();
    } catch (e, st) {
      _logger.e('InAppNavigationController.init error', error: e, stackTrace: st);
      hasRouteError.value = true;
      isLoadingRoute.value = false;
    }

    _startLiveTracking();
  }

  /// Switches travel mode (walking/driving) and re-fetches the
  /// route for the same origin/destination — live tracking keeps running.
  Future<void> changeMode(TravelMode mode) async {
    if (selectedMode.value == mode) return;
    selectedMode.value = mode;
    if (origin.value == null || _destination == null) return;
    await _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final currentOrigin = origin.value;
    final destination = _destination;
    if (currentOrigin == null || destination == null) return;

    isLoadingRoute.value = true;
    hasRouteError.value = false;
    try {
      final result = await DirectionsRepository.getRoute(
        origin: currentOrigin,
        destination: destination,
        travelMode: selectedMode.value.apiValue,
      );

      if (result == null) {
        hasRouteError.value = true;
      } else {
        routePoints.value = result.polylinePoints;
        routeInfo.value = result;
        _logger.i(
          'Route fetched (${selectedMode.value.apiValue}): '
          'distance="${result.distanceText}" duration="${result.durationText}"',
        );
      }
    } catch (e, st) {
      _logger.e('InAppNavigationController._fetchRoute error', error: e, stackTrace: st);
      hasRouteError.value = true;
    } finally {
      isLoadingRoute.value = false;
    }
  }

  Future<void> retry() async {
    final destination = _destination;
    if (destination != null) {
      await init(destination: destination);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
      return true;
    } catch (e) {
      _logger.e('Error checking navigation location permission', error: e);
      return false;
    }
  }

  void _startLiveTracking() {
    _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        liveUserPosition.value = latLng;
        mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      },
      onError: (e) {
        _logger.e('Navigation position stream error', error: e);
      },
    );
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    super.onClose();
  }
}
