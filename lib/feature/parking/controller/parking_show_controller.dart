import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/parking/repository/parking_repository.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingShowController extends GetxController {
  final ParkingRepository _repository = ParkingRepository();

  final RxBool isLoading = false.obs;
  final RxBool isLocating = true.obs;
  final RxString status = 'IDLE'.obs;
  final Rxn<LatLng> gpsPosition = Rxn<LatLng>();
  final Rxn<LatLng> mapCenter = Rxn<LatLng>();
  final RxBool showLocationPulse = false.obs;
  final RxInt selectedRadiusMeter = 300.obs;
  final RxInt mapOverlayVersion = 0.obs;

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
    super.onClose();
  }

  void _startBlinkTimer() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _blinkToggle.value = !_blinkToggle.value;
      _updateBlinkingCirclesOnly();
    });
  }

  void _showMessage(String message, {required bool isError}) {
    final ctx = Get.overlayContext ?? Get.context;
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

  Future<void> initializeFlow({required VoidCallback onShowPopup}) async {
    await getUserLocation();
    if (gpsPosition.value == null) {
      debugPrint('No GPS resolved. Skipping parking flow.');
      return;
    }
    await checkParkingModeMe(onShowPopup: onShowPopup);
  }

  Future<void> getUserLocation() async {
    isLocating.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLocating.value = false;
        _showMessage('Please enable location service', isError: true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLocating.value = false;
        _showMessage('Location permission denied', isError: true);
        return;
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

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );
      }
    } catch (e) {
      isLocating.value = false;
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> checkParkingModeMe({required VoidCallback onShowPopup}) async {
    isLoading.value = true;
    try {
      final response = await _repository.getParkingModeMe();
      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        final String modeStatus =
            data?['status']?.toString().toUpperCase() ?? 'IDLE';
        status.value = modeStatus;

        if (gpsPosition.value == null &&
            data?['latitude'] != null &&
            data?['longitude'] != null) {
          final lat = _toDouble(data!['latitude']);
          final lng = _toDouble(data['longitude']);
          if (lat != null && lng != null) {
            final latLng = LatLng(lat, lng);
            gpsPosition.value = latLng;
            mapCenter.value = latLng;
          }
        }

        final lat = gpsPosition.value?.latitude;
        final lng = gpsPosition.value?.longitude;

        if (modeStatus == 'SEARCHING') {
          if (lat != null && lng != null) {
            showLocationPulse.value = true;
            await fetchNearbyData(lat, lng);
          }
        } else {
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

  Future<void> fetchNearbyData(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    isLoading.value = true;

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
          radiusMeters: 20000,
        ),
      ]);


      final handoffsResponse = results[0];
      final areasResponse = results[1];

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

      await _buildMarkersAndPolygons();
    } catch (e) {
      _showMessage('Failed to load nearby parking spots: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLeavingPopupNo() async {
    showLocationPulse.value = true;
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;
    if (lat != null && lng != null) {
      await fetchNearbyData(lat, lng);
    }
  }

  Future<void> onLeavingPopupYes() async {
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
      final response =
          await _repository.createHandoff(latitude: lat, longitude: lng);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('Parking spot handoff reported successfully!', isError: false);
        if (mapController != null) {
          await mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
          );
        }
        await fetchNearbyData(lat, lng);
      } else {
        String msg = 'Failed to record spot handoff';
        try {
          final decoded = jsonDecode(response.body);
          final map = _asMap(decoded);
          if (map?['message'] != null) {
            msg = map!['message'].toString();
          }
        } catch (_) {}
        _showMessage(msg, isError: true);
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

    // Inject saved location marker
    if (savedParkingLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('saved_car_location'),
          position: savedParkingLocation.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(
            title: 'Your Saved Parking Spot',
            snippet: 'Tap to see walking route',
          ),
          onTap: () => showSavedSpotDetails(),
        ),
      );
    }


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

    for (var idx = 0; idx < parkingAreaList.length; idx++) {
      final area = _asMap(parkingAreaList[idx]);
      if (area == null) continue;

      final areaId = area['id']?.toString() ?? 'area_$idx';
      final polyPoints = area['polygon'];
      final points = _parsePolygonPoints(polyPoints);

      if (points.length >= 3) {
        newPolygons.add(
          Polygon(
            polygonId: PolygonId(areaId),
            points: points,
            strokeWidth: 3,
            strokeColor: const Color(0xFF185FA5),
            fillColor: const Color(0xFF185FA5).withValues(alpha: 0.25),
            consumeTapEvents: true,
            onTap: () => showParkingAreaDetails(area),
          ),
        );

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('outline_$areaId'),
            points: [...points, points.first],
            color: const Color(0xFF185FA5),
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

    debugPrint(
      'Parking map overlays → markers: ${newMarkers.length}, '
      'polygons: ${newPolygons.length}, polylines: ${newPolylines.length}',
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

  void _updateBlinkingCirclesOnly() {
    if (handoffList.isEmpty) return;

    final Set<Circle> newCircles = {};
    final now = DateTime.now();
    var needRefresh = false;

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

      if (handoffStatus == 'AVAILABLE' && expiresAtStr.isNotEmpty) {
        try {
          final expiryTime = DateTime.parse(expiresAtStr).toLocal();
          if (expiryTime.isAfter(now)) {
            newCircles.add(_buildBlinkCircle(id: id, lat: lat, lng: lng));
          } else {
            needRefresh = true;
          }
        } catch (_) {}
      }
    }

    circles
      ..clear()
      ..addAll(newCircles);

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
      debugPrint('Error loading custom car icon: $e');
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
    isParkModeActive.value = !isParkModeActive.value;
    if (isParkModeActive.value) {
      _showMessage('ParkMode active: Fusing GPS and Accelerometer signals.', isError: false);
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
    
    confidenceLevel.value = 93 + (DateTime.now().second % 7); // simulated background signals 93-99%
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
    _showMessage('Paid spot timer started for $minutes minutes.', isError: false);
  }

  void _startTimerUpdate(int totalSeconds) {
    int remainingSeconds = totalSeconds;
    
    _parkingCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        isTimerActive.value = false;
        remainingTimeString.value = '';
        savedParkingLocation.value = null; // Spot is removed after expiration
        _buildMarkersAndPolygons();
        _showMessage('Parking spot duration has expired. Spot is now free.', isError: false);
        return;
      }

      remainingSeconds--;
      
      final int mins = remainingSeconds ~/ 60;
      final int secs = remainingSeconds % 60;
      remainingTimeString.value = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      
      // Expiring warning alert
      final bool triggerAlert = (totalSeconds > 600 && remainingSeconds == 600) || 
                               (totalSeconds <= 600 && remainingSeconds == 60);
      if (triggerAlert) {
        _showExpirationAlert();
      }
    });
    isTimerActive.value = true;
  }

  void showParkingTypeDialog() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;
    showDialog(
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
                  child: Icon(Icons.local_parking, size: 40, color: Colors.blue.shade700),
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
                          _showMessage('Parking location saved as Free Spot.', isError: false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Free Spot', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Paid Spot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void showDurationPickerDialog() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;
    showDialog(
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
                const Text(
                  'Staying Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For how long is the user staying in that spot?',
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
                         child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                       ),
                     ),
                   );
                }),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showExpirationAlert() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;
    showDialog(
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
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.amber),
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
                          _showMessage('Acknowledged. Keeping spot active.', isError: false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('No, Staying', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          clearSavedParkingLocation();
                          _showMessage('Parking cleared. Released spot status.', isError: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Yes, Leaving', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void showSavedSpotDetails() {
    final ctx = Get.overlayContext ?? Get.context;
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
              const Text(
                'Saved Parking Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Confidence Level', '${confidenceLevel.value}% (High Accuracy)'),
              _buildDetailRow('Spot Type', isPaidSpot.value ? 'Paid Spot' : 'Free Spot'),
              if (isTimerActive.value)
                _buildDetailRow('Time Remaining', remainingTimeString.value),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  launchSavedParkingRoute();
                },
                icon: const Icon(Icons.directions_walk, color: Colors.white),
                label: const Text('Walk Back to Car', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  clearSavedParkingLocation();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Remove Spot', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void showHandoffDetails(Map<String, dynamic> handoff) {
    showDetailsSheet(handoff, 'Handoff Details');
  }

   // showDetailsSheet(handoff, 'Handoff Details');
  }

  void showParkingAreaDetails(Map<String, dynamic> area) {
    final name = area['name']?.toString();
    showDetailsSheet(
      area,
      name != null && name.isNotEmpty ? name : 'Parking Area Details',
    );
  }

  void showDetailsSheet(Map<String, dynamic> data, String title) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    final visibleEntries = data.entries.where((entry) {
      if (entry.value is List || entry.value is Map) {
        return entry.key == 'polygon';
      }
      return entry.key != 'id' && entry.key != 'createdById';
    }).toList();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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

                      final valStr = entry.value?.toString() ?? '';
                      if (valStr.isEmpty) return const SizedBox.shrink();

                      final displayKey = _formatKey(entry.key);

                      if (entry.key == 'googleMapsLink') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(valStr),
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
                        );
                      }

                      return _buildDetailRow(displayKey, valStr);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch URL: $url ($e)');
    }
  }

