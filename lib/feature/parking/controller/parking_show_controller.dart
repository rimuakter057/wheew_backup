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

  void showHandoffDetails(Map<String, dynamic> handoff) {
    showDetailsSheet(handoff, 'Handoff Details');
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
}
