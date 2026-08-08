import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/feature/navigation/repository/directions_repository.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
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

  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    _ttsReady = true;
  }

  Future<void> _speak(String text) async {
    _logger.i('ðŸ”Š [TTS] speak() called: "$text" (isVoiceOn=${isVoiceOn.value}, ready=$_ttsReady)');
    if (!isVoiceOn.value || !_ttsReady) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  final Rxn<LatLng> origin = Rxn<LatLng>();
  final Rxn<LatLng> liveUserPosition = Rxn<LatLng>();

  // All routes Google returned (index 0 = recommended); routePoints/routeInfo
  // always mirror whichever one is selected so existing UI code that reads
  // them doesn't need to know about alternates.
  final RxList<DirectionsResult> allRoutes = <DirectionsResult>[].obs;
  final RxInt selectedRouteIndex = 0.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rxn<DirectionsResult> routeInfo = Rxn<DirectionsResult>();

  /// "Similar ETA" / "+X min" pill bitmap for each alternate route, keyed by
  /// its index in allRoutes — rendered once per fetch, not on every build.
  final RxMap<int, BitmapDescriptor> routeLabels = <int, BitmapDescriptor>{}.obs;

  /// Mode-icon + duration pill for the selected route (e.g. "ðŸš¶ 7 min"),
  /// shown along the walking route the way Google Maps does.
  final Rxn<BitmapDescriptor> primaryRouteBadge = Rxn<BitmapDescriptor>();

  // Walking is the default mode whenever the navigation screen opens.
  final Rx<TravelMode> selectedMode = TravelMode.walking.obs;

  final RxBool isLoadingRoute = true.obs;
  final RxBool hasRouteError = false.obs;
  final RxBool isLocationPermissionDenied = false.obs;

  /// Turn-by-turn progress — which step of routeInfo.steps we're currently
  /// on, and how far the live position still is from that step's end.
  final RxInt currentStepIndex = 0.obs;
  final RxInt distanceToTurnMeters = 0.obs;
  bool _announcedCurrentStep = false;

  /// Live speed (km/h), derived from the position stream's `speed` (m/s).
  final RxDouble speedKmh = 0.0.obs;

  /// Voice-guidance toggle — gates every _speak() call.
  final RxBool isVoiceOn = true.obs;

  List<NavigationStep> get steps => routeInfo.value?.steps ?? [];

  NavigationStep? get currentStep =>
      currentStepIndex.value < steps.length ? steps[currentStepIndex.value] : null;

  NavigationStep? get nextStep =>
      currentStepIndex.value + 1 < steps.length ? steps[currentStepIndex.value + 1] : null;

  /// Current camera bearing (0 = north-up) — drives the compass button's
  /// N-face vs red-arrow states, same as Google Maps.
  final RxDouble cameraBearing = 0.0.obs;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _destination;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onCameraMove(CameraPosition position) {
    cameraBearing.value = position.bearing;
  }

  Future<void> init({required LatLng destination}) async {
    unawaited(_initTts());
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
      final results = await DirectionsRepository.getRoutes(
        origin: currentOrigin,
        destination: destination,
        travelMode: selectedMode.value.apiValue,
      );

      if (results == null || results.isEmpty) {
        hasRouteError.value = true;
      } else {
        allRoutes.value = results;
        selectedRouteIndex.value = 0;
        _applySelectedRoute();
        _logger.i(
          'Route fetched (${selectedMode.value.apiValue}): '
          '${results.length} option(s), primary distance="${results.first.distanceText}" '
          'duration="${results.first.durationText}"',
        );
        unawaited(_buildRouteLabels());
      }
    } catch (e, st) {
      _logger.e('InAppNavigationController._fetchRoute error', error: e, stackTrace: st);
      hasRouteError.value = true;
    } finally {
      isLoadingRoute.value = false;
    }
  }

  /// User tapped an alternate route (either its polyline or its "Similar
  /// ETA"-style pill) — make it the active route.
  void selectRoute(int index) {
    if (index < 0 || index >= allRoutes.length || index == selectedRouteIndex.value) return;
    selectedRouteIndex.value = index;
    _applySelectedRoute();
  }

  void _applySelectedRoute() {
    final selected = allRoutes[selectedRouteIndex.value];
    routeInfo.value = selected;
    routePoints.value = selected.polylinePoints;
    currentStepIndex.value = 0;
    distanceToTurnMeters.value = 0;
    _announcedCurrentStep = false;
    unawaited(_buildPrimaryRouteBadge());
    if (selected.steps.isNotEmpty) {
      unawaited(_speak(selected.steps.first.instruction));
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
        _updateNavigationProgress(latLng);
        // Position.speed is m/s and occasionally reports small negative
        // noise at a standstill — clamp to a sane non-negative km/h.
        speedKmh.value = (position.speed * 3.6).clamp(0, 999).toDouble();
      },
      onError: (e) {
        _logger.e('Navigation position stream error', error: e);
      },
    );
  }

  /// Advances currentStepIndex as the live position reaches the end of the
  /// step it's currently on — same idea as typing/online status elsewhere
  /// in the app: derived purely from the latest event, no polling.
  void _updateNavigationProgress(LatLng position) {
    final step = currentStep;
    if (step == null) return;

    final distanceToStepEnd = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      step.endLocation.latitude,
      step.endLocation.longitude,
    );
    distanceToTurnMeters.value = distanceToStepEnd.round();

    const announceThresholdMeters = 50;
    if (distanceToStepEnd <= announceThresholdMeters && !_announcedCurrentStep) {
      _announcedCurrentStep = true;
      final upcoming = nextStep;
      if (upcoming != null) {
        unawaited(_speak(upcoming.instruction));
      }
    }

    const arrivalThresholdMeters = 20;
    if (distanceToStepEnd <= arrivalThresholdMeters) {
      if (currentStepIndex.value < steps.length - 1) {
        currentStepIndex.value++;
        _announcedCurrentStep = false;
      } else {
        unawaited(_speak('You have arrived'));
      }
    }
  }

  void toggleVoice() => isVoiceOn.value = !isVoiceOn.value;

  /// Compass button — recenters on the live position and resets the camera
  /// to north-up (bearing 0), same as tapping the compass in Google Maps.
  void recenterNorth() {
    final target = liveUserPosition.value ?? origin.value;
    if (target == null || mapController == null) return;
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 17, bearing: 0),
      ),
    );
  }

  /// Zoom/search button — fits the entire active route in view.
  void fitRouteBounds() {
    if (routePoints.isEmpty || mapController == null) return;

    var minLat = routePoints.first.latitude;
    var maxLat = routePoints.first.latitude;
    var minLng = routePoints.first.longitude;
    var maxLng = routePoints.first.longitude;
    for (final point in routePoints) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  /// Renders a "Similar ETA" / "+X min" pill bitmap for every alternate
  /// route so it can be dropped on the map as a normal Marker — Google Maps
  /// itself does this the same way, since GoogleMap has no "floating text
  /// at a LatLng" primitive.
  Future<void> _buildRouteLabels() async {
    final primaryDurationSeconds = allRoutes.isNotEmpty ? allRoutes.first.durationSeconds : null;
    final newLabels = <int, BitmapDescriptor>{};

    for (var i = 1; i < allRoutes.length; i++) {
      final alt = allRoutes[i];
      final text = _etaDiffLabel(primaryDurationSeconds, alt.durationSeconds);
      newLabels[i] = await _renderPillBitmap(text);
    }

    routeLabels.value = newLabels;
  }

  String _etaDiffLabel(int? primarySeconds, int? altSeconds) {
    if (primarySeconds == null || altSeconds == null) return AppStrings.similarEta.tr;
    final diffMinutes = ((altSeconds - primarySeconds) / 60).round();
    if (diffMinutes.abs() < 2) return AppStrings.similarEta.tr;
    return diffMinutes > 0 ? '$diffMinutes min slower' : '${diffMinutes.abs()} min faster';
  }

  /// Mode-icon + duration pill on the selected route (e.g. walking-icon +
  /// "7 min"), same as the badge Google Maps drops along an active route.
  Future<void> _buildPrimaryRouteBadge() async {
    final info = routeInfo.value;
    if (info == null || info.durationText.isEmpty) {
      primaryRouteBadge.value = null;
      return;
    }
    primaryRouteBadge.value = await _renderPillBitmap(
      info.durationText,
      icon: selectedMode.value.icon,
      background: AppColors.blue,
      foreground: AppColors.white,
    );
  }

  Future<BitmapDescriptor> _renderPillBitmap(
    String text, {
    IconData? icon,
    Color background = AppColors.white,
    Color foreground = AppColors.black87,
    Color? border,
  }) async {
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: foreground,
          fontSize: 13 * dpr,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    TextPainter? iconPainter;
    if (icon != null) {
      iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 16 * dpr,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: foreground,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    final paddingH = 14.0 * dpr;
    final paddingV = 8.0 * dpr;
    final iconGap = iconPainter != null ? 6.0 * dpr : 0.0;
    final contentWidth = (iconPainter?.width ?? 0) + iconGap + textPainter.width;
    final contentHeight = [textPainter.height, iconPainter?.height ?? 0].reduce((a, b) => a > b ? a : b);

    final width = contentWidth + paddingH * 2;
    final height = contentHeight + paddingV * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(height / 2),
    );

    canvas.drawRRect(rrect, Paint()..color = background);
    if (border != null) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * dpr,
      );
    }

    var dx = paddingH;
    final dy = paddingV;
    if (iconPainter != null) {
      iconPainter.paint(canvas, Offset(dx, dy + (contentHeight - iconPainter.height) / 2));
      dx += iconPainter.width + iconGap;
    }
    textPainter.paint(canvas, Offset(dx, dy + (contentHeight - textPainter.height) / 2));

    final image = await recorder.endRecording().toImage(width.round(), height.round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List(), imagePixelRatio: dpr);
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _tts.stop();
    super.onClose();
  }
}


