
import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:convert';
import 'dart:ui' as ui;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/feature/parking/repository/parking_repository.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/routes.dart';
import '../../../helper/data_converter/data_converter.dart';

class ParkingShowController extends GetxController {
  final ParkingRepository _repository = ParkingRepository();
  BuildContext? get _dialogContext =>
      AppRouter.navigatorKey.currentState?.overlay?.context ??
          AppRouter.navigatorKey.currentContext;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );

  // Fallback map center shown instantly while the real flow resolves
  // in the background (matches the "show map immediately" requirement).
  static const LatLng kApproxDefaultLocation = LatLng(34.052235, -118.243683);

  // Parking areas are queried with a fixed, wider radius; handoffs use
  // the user-adjustable radius filter (default 300m).
  static const int _parkingAreaRadiusMeters = 20000;

  final RxBool isLoading = false.obs;
  final RxBool isLocating = true.obs;
  final RxString status = 'IDLE'.obs;
  final Rxn<LatLng> gpsPosition = Rxn<LatLng>();
  final Rxn<LatLng> mapCenter = Rxn<LatLng>();
  final RxBool showLocationPulse = false.obs;
  final RxInt selectedRadiusMeter = 300.obs;
  final RxInt mapOverlayVersion = 0.obs;

  final RxBool isRealLocationLoaded = false.obs;

  // ── SavePark, ParkMode, and Parktime States ──────────────────────
  final Rxn<LatLng> savedParkingLocation = Rxn<LatLng>();
  final RxInt confidenceLevel = 98.obs;
  final RxBool isParkModeActive = false.obs;
  final RxBool isPaidSpot = false.obs;
  final RxString remainingTimeString = ''.obs;
  final RxBool isTimerActive = false.obs;
  Timer? _parkingCountdownTimer;

  final RxSet<Circle> circles = <Circle>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxList<dynamic> handoffList = <dynamic>[].obs;
  final RxList<dynamic> parkingAreaList = <dynamic>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polygon> polygons = <Polygon>{}.obs;

  final RxBool _blinkToggle = true.obs;
  Timer? _blinkTimer;
  bool _isRefreshing = false;

  GoogleMapController? mapController;
  final Map<String, BitmapDescriptor> _carIconCache = {};

  @override
  void onInit() {
    super.onInit();
    _startBlinkTimer();
  }

  @override
  void onClose() {
    _blinkTimer?.cancel();
    _parkingCountdownTimer?.cancel();
    super.onClose();
  }

  void _startBlinkTimer() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _blinkToggle.value = !_blinkToggle.value;
      _updateBlinkingOverlays();
    });
  }

  void _showMessage(String message, {required bool isError}) {
    final ctx = _dialogContext;

    if (ctx == null) return;
    if (isError) {
      CustomSnackbar.error(context: ctx, message: message);
    } else {
      CustomSnackbar.success(context: ctx, message: message);
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (gpsPosition.value != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(gpsPosition.value!, 15),
      );
    }
  }

  /// Entry point every time the screen opens.
  /// 1. Shows an approximate default location immediately so the map
  ///    renders with no delay.
  /// 2. In the background, checks /parking-mode/me and branches the flow.
  Future<void> initializeFlow({required VoidCallback onShowPopup}) async {
    // Wipe any stale data from a previous visit to this screen before
    // doing anything else — every navbar entry must start from a clean
    // state and be driven purely by the fresh API response below.
    _resetSearchState();

    isLocating.value = false;
    isRealLocationLoaded.value = false;
    gpsPosition.value = kApproxDefaultLocation;
    mapCenter.value = kApproxDefaultLocation;

    await checkParkingModeMe(onShowPopup: onShowPopup);
  }

  /// Clears everything that came from the last /parking-mode/me +
  /// nearby-data cycle. Keeps `savedParkingLocation` and the paid-spot
  /// timer intact since those represent a real, still-valid car
  /// location and shouldn't disappear just from switching tabs.
  void _resetSearchState() {
    handoffList.clear();
    parkingAreaList.clear();
    polygons.clear();
    polylines.clear();
    circles.clear();
    markers.removeWhere(
          (m) => m.markerId.value != 'saved_car_location',
    );
    status.value = 'IDLE';
    // Must be false until the flow actually confirms SEARCHING or the
    // user answers the popup — otherwise the search bar / map-type
    // dropdown (which are gated on this flag) can leak in from a
    // previous visit and appear underneath the popup before Yes/No.
    showLocationPulse.value = false;
    mapOverlayVersion.value++;
  }

  /// Lightweight refresh used on app resume — re-checks status without
  /// resetting the map back to the approximate default location.
  Future<void> refreshStatus({required VoidCallback onShowPopup}) async {
    await checkParkingModeMe(onShowPopup: onShowPopup);
  }

  /// Fetches the real device GPS position.
  /// Returns true only if a real fix was obtained.
  Future<bool> getUserLocation() async {
    isLocating.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLocating.value = false;
        _showMessage('Please enable location service', isError: true);
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLocating.value = false;
        _showMessage('Location permission denied', isError: true);
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      gpsPosition.value = latLng;
      mapCenter.value = latLng;
      isLocating.value = false;
      isRealLocationLoaded.value = true;

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );
      }
      return true;
    } catch (e) {
      isLocating.value = false;
      _logger.e('Error getting location', error: e);
      return false;
    }
  }

  /// GET /park-relay/parking-mode/me
  /// SEARCHING  -> no popup, just load real location + nearby overlays.
  /// IDLE/PARKED -> show the "are you leaving a spot" popup.
  Future<void> checkParkingModeMe({required VoidCallback onShowPopup}) async {
    isLoading.value = true;
    _logger.i('=== checkParkingModeMe START ===');
    try {
      final response = await _repository.getParkingModeMe();
      print("PARKING_MODE_ME_RESPONSE: status=${response.statusCode}, body=${response.body}");
      _logger.d('checkParkingModeMe status: ${response.statusCode}\n'
          'body: ${response.body}');
      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        final String modeStatus =
            data?['status']?.toString().toUpperCase() ?? 'IDLE';
        status.value = modeStatus;

        if (modeStatus == 'SEARCHING') {
          await getUserLocation();
          showLocationPulse.value = true;
          final lat = gpsPosition.value?.latitude;
          final lng = gpsPosition.value?.longitude;
          if (lat != null && lng != null) {
            await fetchNearbyData(lat, lng);
          }
        } else {
          // IDLE or PARKED
          onShowPopup();
        }
      } else {
        String errorMsg = 'Failed to retrieve parking status';
        try {
          final decoded = jsonDecode(response.body);
          final map = _asMap(decoded);
          if (map?['message'] != null) {
            errorMsg = map!['message'].toString();
          }
        } catch (_) {}
        _showMessage(errorMsg, isError: true);
        onShowPopup();
      }
    } catch (e) {
      _showMessage('Failed to connect to parking service: $e', isError: true);
      onShowPopup();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /park-relay/handoffs/nearby (adjustable radius)
  /// GET /park-relay/parking-areas/nearby (fixed 1000m radius)
  Future<void> fetchNearbyData(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      _logger.w('fetchNearbyData SKIPPED: lat/lng is null');
      return;
    }
    isLoading.value = true;

    _logger.i('=== fetchNearbyData START ===\n'
        'lat=$lat, lng=$lng, '
        'handoffRadius=${selectedRadiusMeter.value}m, '
        'parkingAreaRadius=${_parkingAreaRadiusMeters}m');

    try {
      final results = await Future.wait([
        _repository.getNearbyHandoffs(
          latitude: lat,
          longitude: lng,
          radiusMeters: selectedRadiusMeter.value,
        ),
        _repository.getNearbyParkingAreas(
          latitude: lat,
          longitude: lng,
          radiusMeters: _parkingAreaRadiusMeters,
        ),
      ]);

      final handoffsResponse = results[0];
      final areasResponse = results[1];

      print("GET_NEARBY_HANDOFFS_RESPONSE: status=${handoffsResponse.statusCode}, body=${handoffsResponse.body}");
      print("GET_NEARBY_PARKING_AREAS_RESPONSE: status=${areasResponse.statusCode}, body=${areasResponse.body}");

      _logger.d('GET /handoffs/nearby -> status: ${handoffsResponse.statusCode}\n'
          'body: ${handoffsResponse.body}');
      _logger.d('GET /parking-areas/nearby -> status: ${areasResponse.statusCode}\n'
          'body: ${areasResponse.body}');

      if (handoffsResponse.statusCode == 200) {
        handoffList.value = jsonDecode(handoffsResponse.body) as List<dynamic>;
      } else {
        _showMessage('Failed to load nearby handoff spots', isError: true);
      }

      if (areasResponse.statusCode == 200) {
        parkingAreaList.value = jsonDecode(areasResponse.body) as List<dynamic>;
      } else {
        _showMessage('Failed to load nearby parking areas', isError: true);
      }

      _logger.d('Parsed -> handoffList: ${handoffList.length} items, '
          'parkingAreaList: ${parkingAreaList.length} items');

      await _buildMarkersAndPolygons();

      // Adjust camera bounds to fit user location and all markers/polygons
      if (mapController != null && gpsPosition.value != null) {
        double minLat = gpsPosition.value!.latitude;
        double maxLat = gpsPosition.value!.latitude;
        double minLng = gpsPosition.value!.longitude;
        double maxLng = gpsPosition.value!.longitude;

        bool hasItems = false;
        for (final m in markers) {
          minLat = math.min(minLat, m.position.latitude);
          maxLat = math.max(maxLat, m.position.latitude);
          minLng = math.min(minLng, m.position.longitude);
          maxLng = math.max(maxLng, m.position.longitude);
          hasItems = true;
        }
        for (final p in polygons) {
          for (final pt in p.points) {
            minLat = math.min(minLat, pt.latitude);
            maxLat = math.max(maxLat, pt.latitude);
            minLng = math.min(minLng, pt.longitude);
            maxLng = math.max(maxLng, pt.longitude);
          }
          hasItems = true;
        }

        if (hasItems) {
          final bounds = LatLngBounds(
            southwest: LatLng(minLat - 0.005, minLng - 0.005),
            northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
          );
          print("Map camera bounds adjusted to show spots: minLat=$minLat, maxLat=$maxLat");
          await mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50),
          );
        }
      }

      _logger.i('=== fetchNearbyData END -> markers: ${markers.length}, '
          'polygons: ${polygons.length}, circles: ${circles.length} ===');
    } catch (e, st) {
      _logger.e('fetchNearbyData ERROR', error: e, stackTrace: st);
      _showMessage('Failed to load nearby parking spots: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Popup -> "No" (not leaving). Re-runs the same 2 GET calls used for
  /// the SEARCHING flow and marks the backend mode as searching.
  Future<void> onLeavingPopupNo() async {
    _logger.i('=== onLeavingPopupNo CLICKED ===');
    await getUserLocation();
    showLocationPulse.value = true;
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;
    _logger.d('onLeavingPopupNo coordinates: lat=$lat, lng=$lng');
    if (lat == null || lng == null) {
      _logger.w('onLeavingPopupNo SKIPPED: location is null');
      return;
    }

    try {
      _logger.d('onLeavingPopupNo calling setParkingModeSearching');
      final response = await _repository.setParkingModeSearching(latitude: lat, longitude: lng);
      _logger.d('setParkingModeSearching response status: ${response.statusCode}\n'
          'body: ${response.body}');
    } catch (e, st) {
      _logger.e('Error setting searching mode', error: e, stackTrace: st);
    }
    await fetchNearbyData(lat, lng);
  }

  /// Popup -> "Yes" (leaving the spot).
  /// POST /park-relay/handoffs {latitude, longitude}
  /// This ONLY reports the handoff to the backend. The UI response is
  /// just the plain Google Map centered on the user's real location —
  /// no blinking, no markers/polygons, no search bar / pulse overlay.
  Future<void> onLeavingPopupYes() async {
    await getUserLocation();
    // Intentionally NOT setting showLocationPulse — Yes should show a
    // clean map only, not the search bar / pulse UI.
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;
    if (lat == null || lng == null) {
      _showMessage(
        'Location is not active or available to report handoff',
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    try {
      _logger.i('=== YES CLICK -> 2 API CALLS ===\n'
          '1. POST /park-relay/handoffs\n'
          '2. POST /park-relay/parking-mode/idle\n'
          'body: {"latitude": $lat, "longitude": $lng}');

      // Call 1: Handoff
      final responseHandoff =
      await _repository.createHandoff(latitude: lat, longitude: lng);
      _logger.d('createHandoff status: ${responseHandoff.statusCode}\n'
          'body: ${responseHandoff.body}');

      // Call 2: Idle mode
      final responseIdle =
      await _repository.setParkingModeIdle(latitude: lat, longitude: lng);
      _logger.d('setParkingModeIdle status: ${responseIdle.statusCode}\n'
          'body: ${responseIdle.body}');

      if ((responseHandoff.statusCode == 200 || responseHandoff.statusCode == 201) &&
          (responseIdle.statusCode == 200 || responseIdle.statusCode == 201)) {
        _showMessage(
            'Parking spot handoff reported successfully!', isError: false);
        if (mapController != null) {
          await mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
          );
        }
      } else {
        String msg = '';
        if (responseHandoff.statusCode != 200 && responseHandoff.statusCode != 201) {
          msg += 'Failed to record spot handoff. ';
        }
        if (responseIdle.statusCode != 200 && responseIdle.statusCode != 201) {
          msg += 'Failed to set parking mode to idle.';
        }
        _showMessage(msg.trim(), isError: true);
      }
    } catch (e) {
      _showMessage('Network error reporting spot handoff: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _buildMarkersAndPolygons() async {
    final Set<Marker> newMarkers = {};
    final Set<Polygon> newPolygons = {};
    final Set<Polyline> newPolylines = {};
    final Set<Circle> newCircles = {};
    final now = DateTime.now();

    final freeCarIcon = await _getCarIcon(AssetsPath.freeCar);
    final paidCarIcon = await _getCarIcon(AssetsPath.paidCar);
    bool needRefresh = false;

    // Saved parking location marker
    if (savedParkingLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('saved_car_location'),
          position: savedParkingLocation.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(
            title: 'Your Saved Parking Spot',
            snippet: 'Tap to see walking route',
          ),
          onTap: () => showSavedSpotDetails(),
        ),
      );
    }

    // Handoff markers — blink while AVAILABLE and not yet expired
    for (final rawHandoff in handoffList) {
      final handoff = _asMap(rawHandoff);
      if (handoff == null) continue;

      final lat = _toDouble(handoff['latitude']);
      final lng = _toDouble(handoff['longitude']);
      if (lat == null || lng == null) continue;

      final id = handoff['id']?.toString() ?? '';
      final handoffStatus =
          handoff['status']?.toString().toUpperCase() ?? '';
      final expiresAtStr = handoff['expiresAt']?.toString() ?? '';
      var isBlinking = false;

      if (handoffStatus == 'AVAILABLE' && expiresAtStr.isNotEmpty) {
        try {
          final expiryTime = DateTime.parse(expiresAtStr).toLocal();
          if (expiryTime.isAfter(now)) {
            isBlinking = true;
          } else {
            needRefresh = true;
          }
        } catch (_) {}
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId('handoff_$id'),
          position: LatLng(lat, lng),
          icon: freeCarIcon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow.noText,
          onTap: () => showHandoffDetails(handoff),
        ),
      );

      if (isBlinking) {
        newCircles.add(_buildBlinkCircle(id: id, lat: lat, lng: lng));
      }
    }

    // Parking areas — red polygon outline
    for (var idx = 0; idx < parkingAreaList.length; idx++) {
      final area = _asMap(parkingAreaList[idx]);
      if (area == null) {
        _logger.w('parkingArea[$idx] SKIPPED: not a valid map -> ${parkingAreaList[idx]}');
        continue;
      }

      final areaId = area['id']?.toString() ?? 'area_$idx';
      final polyPoints = area['polygon'];
      final points = _parsePolygonPoints(polyPoints);

      _logger.d('parkingArea[$idx] id=$areaId -> raw polygon: $polyPoints '
          '-> parsed points: ${points.length}');

      if (points.length >= 3) {
        newPolygons.add(
          Polygon(
            polygonId: PolygonId(areaId),
            points: points,
            strokeWidth: 3,
            strokeColor: Colors.red,
            fillColor: Colors.red.withValues(alpha: 0.15),
            consumeTapEvents: true,
            onTap: () => showParkingAreaDetails(area),
          ),
        );

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('outline_$areaId'),
            points: [...points, points.first],
            color: Colors.red,
            width: 3,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }

      final centerLat = _toDouble(area['centerLat']);
      final centerLng = _toDouble(area['centerLng']);
      if (centerLat != null && centerLng != null) {
        final isPaid =
            area['parkingCost']?.toString().toUpperCase() == 'PAID';
        newMarkers.add(
          Marker(
            markerId: MarkerId('area_marker_$areaId'),
            position: LatLng(centerLat, centerLng),
            icon: isPaid ? paidCarIcon : freeCarIcon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow.noText,
            onTap: () => showParkingAreaDetails(area),
          ),
        );
      }
    }

    _applyOverlaySets(
      newMarkers: newMarkers,
      newPolygons: newPolygons,
      newPolylines: newPolylines,
      newCircles: newCircles,
    );

    _logger.i(
      '_buildMarkersAndPolygons DONE -> markers: ${newMarkers.length}, '
          'polygons: ${newPolygons.length}, polylines: ${newPolylines.length}, '
          'circles: ${newCircles.length} (handoffList=${handoffList.length}, '
          'parkingAreaList=${parkingAreaList.length})',
    );

    if (needRefresh) {
      _refreshExpiredHandoffs();
    }
  }

  void _applyOverlaySets({
    required Set<Marker> newMarkers,
    required Set<Polygon> newPolygons,
    required Set<Polyline> newPolylines,
    required Set<Circle> newCircles,
  }) {
    markers
      ..clear()
      ..addAll(newMarkers);
    polygons
      ..clear()
      ..addAll(newPolygons);
    polylines
      ..clear()
      ..addAll(newPolylines);
    circles
      ..clear()
      ..addAll(newCircles);
    mapOverlayVersion.value++;
  }

  void _updateBlinkingOverlays() {
    if (handoffList.isEmpty) return;

    final Set<Circle> newCircles = {};
    final Set<Marker> updatedMarkers = Set<Marker>.from(markers);
    final now = DateTime.now();
    var needRefresh = false;

    final freeCarIcon =
        _carIconCache[AssetsPath.freeCar] ?? BitmapDescriptor.defaultMarker;

    for (final rawHandoff in handoffList) {
      final handoff = _asMap(rawHandoff);
      if (handoff == null) continue;

      final lat = _toDouble(handoff['latitude']);
      final lng = _toDouble(handoff['longitude']);
      if (lat == null || lng == null) continue;

      final id = handoff['id']?.toString() ?? '';
      final handoffStatus =
          handoff['status']?.toString().toUpperCase() ?? '';
      final expiresAtStr = handoff['expiresAt']?.toString() ?? '';
      var isBlinking = false;

      if (handoffStatus == 'AVAILABLE' && expiresAtStr.isNotEmpty) {
        try {
          final expiryTime = DateTime.parse(expiresAtStr).toLocal();
          if (expiryTime.isAfter(now)) {
            isBlinking = true;
          } else {
            needRefresh = true;
          }
        } catch (_) {}
      }

      if (isBlinking) {
        newCircles.add(_buildBlinkCircle(id: id, lat: lat, lng: lng));

        final markerId = MarkerId('handoff_$id');
        updatedMarkers.removeWhere((m) => m.markerId == markerId);
        updatedMarkers.add(
          Marker(
            markerId: markerId,
            position: LatLng(lat, lng),
            icon: freeCarIcon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow.noText,
            alpha: _blinkToggle.value ? 1.0 : 0.2,
            onTap: () => showHandoffDetails(handoff),
          ),
        );
      }
    }

    circles
      ..clear()
      ..addAll(newCircles);
    markers
      ..clear()
      ..addAll(updatedMarkers);
    mapOverlayVersion.value++;

    if (needRefresh) {
      _refreshExpiredHandoffs();
    }
  }

  Circle _buildBlinkCircle({
    required String id,
    required double lat,
    required double lng,
  }) {
    return Circle(
      circleId: CircleId('glow_$id'),
      center: LatLng(lat, lng),
      radius: _blinkToggle.value ? 18 : 30,
      fillColor: Colors.red.withValues(
        alpha: _blinkToggle.value ? 0.30 : 0.12,
      ),
      strokeColor: Colors.red.withValues(alpha: 0.7),
      strokeWidth: 2,
      consumeTapEvents: false,
    );
  }

  void _refreshExpiredHandoffs() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;
    if (lat != null && lng != null) {
      await fetchNearbyData(lat, lng);
    }
    _isRefreshing = false;
  }

  List<LatLng> _parsePolygonPoints(dynamic rawPoints) {
    if (rawPoints is! List) return [];

    final List<LatLng> points = [];
    for (final rawPoint in rawPoints) {
      final point = _asMap(rawPoint);
      if (point == null) continue;
      final lat = _toDouble(point['latitude']);
      final lng = _toDouble(point['longitude']);
      if (lat != null && lng != null) {
        points.add(LatLng(lat, lng));
      }
    }
    return points;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Future<BitmapDescriptor> _getCarIcon(String assetPath) async {
    if (_carIconCache.containsKey(assetPath)) {
      return _carIconCache[assetPath]!;
    }

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 48,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        return BitmapDescriptor.defaultMarker;
      }
      final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      _carIconCache[assetPath] = icon;
      return icon;
    } catch (e) {
      _logger.e('Error loading custom car icon: $assetPath', error: e);
      return BitmapDescriptor.defaultMarker;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ── SavePark, ParkMode, and Parktime Operations ──────────────────
  void toggleParkMode() {
    showLocationPulse.value = !showLocationPulse.value;
    if (showLocationPulse.value) {
      _showMessage('ParkMode active: Fusing GPS and Accelerometer signals.',
          isError: false);
      final lat = gpsPosition.value?.latitude;
      final lng = gpsPosition.value?.longitude;
      if (lat != null && lng != null) {
        fetchNearbyData(lat, lng);
      }
    } else {
      _showMessage('ParkMode deactivated.', isError: false);
    }
  }

  void simulateAutoParkDetection() {
    _showMessage('Auto-Park Detected by Confidence Engine!', isError: false);
    saveCurrentParkingLocation();
  }

  void saveCurrentParkingLocation() {
    final latLng = gpsPosition.value;
    if (latLng == null) {
      _showMessage('GPS Location not available to save spot.', isError: true);
      return;
    }

    confidenceLevel.value =
        93 + (DateTime.now().second % 7); // simulated background signals
    savedParkingLocation.value = latLng;
    _buildMarkersAndPolygons();

    showParkingTypeDialog();
  }

  void clearSavedParkingLocation() {
    _parkingCountdownTimer?.cancel();
    isTimerActive.value = false;
    remainingTimeString.value = '';
    savedParkingLocation.value = null;
    _buildMarkersAndPolygons();
    _showMessage('Saved parking spot removed.', isError: false);
  }

  void launchSavedParkingRoute() {
    final destination = savedParkingLocation.value;
    final origin = gpsPosition.value;
    if (destination == null || origin == null) return;

    final url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&travelmode=walking';

    _launchURL(url);
  }

  void startParkingTimer(int minutes) {
    _parkingCountdownTimer?.cancel();
    final totalSeconds = minutes * 60;
    _startTimerUpdate(totalSeconds);
    _showMessage(
        'Paid spot timer started for $minutes minutes.', isError: false);
  }

  void _startTimerUpdate(int totalSeconds) {
    int remainingSeconds = totalSeconds;

    _parkingCountdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (remainingSeconds <= 0) {
            timer.cancel();
            isTimerActive.value = false;
            remainingTimeString.value = '';
            savedParkingLocation.value = null; // spot removed after expiration
            _buildMarkersAndPolygons();
            _showMessage('Parking spot duration has expired. Spot is now free.',
                isError: false);
            return;
          }

          remainingSeconds--;

          final int mins = remainingSeconds ~/ 60;
          final int secs = remainingSeconds % 60;
          remainingTimeString.value =
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

          // Expiring warning alert
          final bool triggerAlert = (totalSeconds > 600 &&
              remainingSeconds == 600) ||
              (totalSeconds <= 600 && remainingSeconds == 60);
          if (triggerAlert) {
            _showExpirationAlert();
          }
        });
    isTimerActive.value = true;
  }

  void showParkingTypeDialog() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  child: Icon(Icons.local_parking,
                      size: 40, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 20),
                const Text(
                  'The car has been parked.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Is it a free spot or is it a paid spot?',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          isPaidSpot.value = false;
                          isTimerActive.value = false;
                          remainingTimeString.value = '';
                          _showMessage('Parking location saved as Free Spot.',
                              isError: false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.freeSpot.tr,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          isPaidSpot.value = true;
                          showDurationPickerDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF185FA5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.paidSpot.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showDurationPickerDialog() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Staying Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                 Text(
                  AppStrings.forHowLongIsTheUserStayingInThatSpot.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...[15, 30, 45, 60, 120].map((mins) {
                  String label = '$mins Minutes';
                  if (mins >= 60) {
                    label = '${mins ~/ 60} Hour${mins == 60 ? "" : "s"}';
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          startParkingTimer(mins);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(label,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child:
                  Text(AppStrings.cancel.tr, style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExpirationAlert() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 40, color: Colors.amber),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Parking Expiring',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you leaving the paid spot? Your paid spot is expiring in 10 minutes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _showMessage(AppStrings.acknowledgedKeepingSpotActive.tr,
                              isError: false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.noStaying.tr,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          clearSavedParkingLocation();
                          _showMessage(
                              AppStrings.parkingClearedReleasedSpotStatus.tr,
                              isError: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.yesLeaving.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }


  // ── Handoff Details Dialog: Status, Expires At, Navigate only ──
  Future<void> showHandoffDetails(Map<String, dynamic> handoff) async {
    final id = handoff['id']?.toString();
    if (id == null || id.isEmpty) {
      _showHandoffDialog(handoff);
      return;
    }

    isLoading.value = true;
    try {
      _logger.i('=== showHandoffDetails: fetching /handoffs/$id ===');
      final response = await _repository.getHandoffById(handoffId: id);
      print("GET_HANDOFF_BY_ID_RESPONSE: status=${response.statusCode}, body=${response.body}");

      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        if (data != null) {
          _showHandoffDialog(data);
          return;
        }
      }
      _showMessage('Failed to load handoff details', isError: true);
      _showHandoffDialog(handoff); // fallback to cached data
    } catch (e, st) {
      _logger.e('showHandoffDetails ERROR', error: e, stackTrace: st);
      _showMessage('Network error loading handoff details: $e', isError: true);
      _showHandoffDialog(handoff);
    } finally {
      isLoading.value = false;
    }
  }

  void _showHandoffDialog(Map<String, dynamic> handoff) {
    final status = handoff['status']?.toString() ?? '';
    final expiresAtStr = handoff['expiresAt']?.toString() ?? '';
    final expiresAt = DateTime.tryParse(expiresAtStr);
    final expiresDisplay = expiresAt != null
        ? DateConverter.formatDateTime(dateTime: expiresAt.toLocal())
        : expiresAtStr;
    final distanceMeters = handoff['distanceMeters'];
    final distanceDisplay = distanceMeters != null
        ? '$distanceMeters m (from your location)'
        : '';
    final googleMapsLink = handoff['googleMapsLink']?.toString();

    _showFixedDetailsDialog(
      title: 'Details',
      rows: [
        _DetailField('Status', status),
        _DetailField('Expires At', expiresDisplay),
        _DetailField('Distance', distanceDisplay),
      ],
      googleMapsLink: googleMapsLink,
    );
  }

  // ── Parking Area Details Dialog: Name, Description, Parking Cost,
  //    Is Active, Distance (with hint), Navigate only ──
  void showParkingAreaDetails(Map<String, dynamic> area) {
    final name = area['name']?.toString() ?? '';
    final description = area['description']?.toString() ?? '';
    final parkingCost = area['parkingCost']?.toString() ?? '';
    final isActive = area['isActive'] == true ? 'Yes' : 'No';
    final distanceMeters = area['distanceMeters'];
    final distanceDisplay = distanceMeters != null
        ? '$distanceMeters m (from your location)'
        : '';
    final googleMapsLink = area['googleMapsLink']?.toString();

    _showFixedDetailsDialog(
      title: name.isNotEmpty ? name : 'Details',
      rows: [
        _DetailField('Name', name),
        _DetailField('Description', description),
        _DetailField('Parking Cost', parkingCost),
        _DetailField('Is Active', isActive),
        _DetailField('Distance', distanceDisplay),
      ],
      googleMapsLink: googleMapsLink,
    );
  }

  // ── Shared dialog shell used by both dialogs above ──
  void _showFixedDetailsDialog({
    required String title,
    required List<_DetailField> rows,
    String? googleMapsLink,
  }) {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...rows
                    .where((r) => r.value.isNotEmpty)
                    .map((r) => _buildDetailRow(r.label, r.value)),
                if (googleMapsLink != null && googleMapsLink.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(googleMapsLink),
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text(
                      'Navigate',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSavedSpotDetails() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
               Text(

                AppStrings.savedParkingLocation.tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(AppStrings.confidenceLevel.tr,
                  '${confidenceLevel.value}% (High Accuracy)'),
              _buildDetailRow(
                  AppStrings.spotType.tr, isPaidSpot.value ? AppStrings.paidSpot.tr : AppStrings.freeSpot.tr),
              if (isTimerActive.value)
                _buildDetailRow(AppStrings.timeRemaining.tr, remainingTimeString.value),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  launchSavedParkingRoute();
                },
                icon: const Icon(Icons.directions_walk, color: Colors.white),
                label: Text(AppStrings.walkBackToCar.tr,
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  clearSavedParkingLocation();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label:
                Text(AppStrings.removeSpot.tr, style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }



  void showDetailsDialog(Map<String, dynamic> data, String title) {
    _logger.i('=== showDetailsDialog: title="$title" ===\n'
        'data: ${jsonEncode(data)}');
    final ctx = _dialogContext;

    if (ctx == null) return;

    final visibleEntries = data.entries.where((entry) {
      if (entry.value is List || entry.value is Map) {
        return entry.key == 'polygon';
      }
      return entry.key != 'id' && entry.key != 'createdById';
    }).toList();

    showDialog(
      context: ctx,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: visibleEntries.map((entry) {
                        if (entry.value is List || entry.value is Map) {
                          if (entry.key == 'polygon') {
                            return _buildDetailRow(
                              'Polygon Points',
                              '${(entry.value as List).length} points',
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        // final valStr = entry.value?.toString() ?? '';
                        // if (valStr.isEmpty) return const SizedBox.shrink();
                        //
                        // final displayKey = _formatKey(entry.key);


                        final displayKey = _formatKey(entry.key);
                        final valStr = _formatFieldValue(entry.key, entry.value);
                        if (valStr.isEmpty) return const SizedBox.shrink();

                        if (entry.key == 'googleMapsLink') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton.icon(
                              onPressed: () => _launchURL(valStr),
                              icon: const Icon(Icons.directions,
                                  color: Colors.white),
                              label: const Text(
                                'Navigate',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          );
                        }

                        return _buildDetailRow(displayKey, valStr);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    final RegExp camelCase = RegExp(r'(?<=[a-z])(?=[A-Z])');
    final formatted = key.replaceAll(camelCase, ' ').replaceAll('_', ' ');
    return formatted.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }


  static const _dateFieldKeys = {
    'expiresAt',
    'acceptedAt',
    'cancelledAt',
    'occupiedAt',
    'createdAt',
    'updatedAt',
  };

  String _formatFieldValue(String key, dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';

    if (_dateFieldKeys.contains(key)) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return DateConverter.formatDateTime(dateTime: parsed.toLocal());
      }
    }
    return raw;
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _logger.e('Could not launch URL: $url', error: e);
    }
  }
}

class _DetailField {
  final String label;
  final String value;
  const _DetailField(this.label, this.value);
}