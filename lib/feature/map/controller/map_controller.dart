// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as vg;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

/// Disabled facility location options
enum DisabledLocation { all, top, back, right, left, none }

extension DisabledLocationX on DisabledLocation {
  String get value => name.toUpperCase(); // ALL, TOP, BACK, RIGHT, LEFT, NONE
}

class ParkingReportController extends GetxController {
  // ── Form State ───────────────────────────────────────────────────────────────
  final RxString parkingCost = 'FREE'.obs; // FREE | PAID
  final RxBool electricCharging = false.obs;
  final RxBool disabledFacility = false.obs;
  final Rx<DisabledLocation> disabledLocation = DisabledLocation.none.obs;

  // ── UI State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString submitMessage = ''.obs;
  final RxBool submitSuccess = false.obs;

  // ── Reset ────────────────────────────────────────────────────────────────────
  void reset() {
    parkingCost.value = 'FREE';
    electricCharging.value = false;
    disabledFacility.value = false;
    disabledLocation.value = DisabledLocation.none;
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<bool> submitParkingReport({
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;
    submitMessage.value = '';
    submitSuccess.value = false;

    final Map<String, dynamic> body = {
      'latitude': latitude,
      'longitude': longitude,
      'parking_cost': parkingCost.value,
      'electric_charging': electricCharging.value,
      'disabled_facility': disabledFacility.value,
      if (disabledFacility.value)
        'disabled_facility_location': disabledLocation.value.value,
    };

    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.parkingReport,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        submitSuccess.value = true;
        submitMessage.value = 'map_parking_report_submitted'.tr;
        mapDebug('parking POST: success');
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final msg =
        (decoded is Map<String, dynamic> && decoded['message'] != null)
            ? decoded['message'].toString()
            : 'something_went_wrong'.tr;
        submitMessage.value = msg;
        mapDebug('parking POST: failed ${response.statusCode} message=$msg');
        return false;
      }
    } catch (e) {
      submitMessage.value = e.toString();
      mapDebug('parking POST: exception $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  GET PARKING
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── State ───────────────────────────────────────────────────────────────
  final RxBool isLoadingShowDetails = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> parkingList =
      <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedReport =
  Rxn<Map<String, dynamic>>();

  // Per-location icon cache — key: "ALL" | "BACK" | "RIGHT" | "LEFT" | "NONE"
  final Map<String, BitmapDescriptor> _locationIconCache = {};

  // Map controller & markers
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;

  // Initial camera position (Dhaka default)
  final Rx<CameraPosition> initialCameraPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 12,
  ).obs;

  // ─── Fetch Data ──────────────────────────────────────────────────────────
  Future<void> fetchParkingReport({
    double? latitude,
    double? longitude,
  }) async {
    try {
      isLoadingShowDetails.value = true;
      errorMessage.value = '';
      mapDebug('parking API: GET ${ApiUrl.showDetails}');

      final response = await ApiClient.getData(
        uri: ApiUrl.showDetails,
        queryParams: {
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final dynamic nested = decoded['reports'] ?? decoded['data'];
          if (nested is List) {
            rawList = nested;
          } else if (nested is Map<String, dynamic>) {
            rawList = [nested];
          } else {
            rawList = [decoded];
          }
        }

        parkingList.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();

        mapDebug('parking API: loaded ${parkingList.length} row(s)');
        await _buildMarkers();
      } else {
        errorMessage.value =
        '${'map_failed_to_load_parking_data'.tr} (${response.statusCode})';
        mapDebug('parking API: HTTP ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = '${'error'.tr}: $e';
      mapDebug('parking API: exception $e');
    } finally {
      isLoadingShowDetails.value = false;
      mapDebug('parking API: fetch finished');
    }
  }

  // ─── Build Map Markers ────────────────────────────────────────────────────
  Future<void> _buildMarkers() async {
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < parkingList.length; i++) {
      final parking = parkingList[i];

      final double? lat = _toDouble(parking['latitude']);
      final double? lng = _toDouble(parking['longitude']);
      if (lat == null || lng == null) continue;

      final bool isPaid = parking['parking_cost'] == 'PAID';
      final bool hasCharging = parking['electric_charging'] == true;
      final bool isDisabled = parking['disabled_facility'] == true;

      // ── Icon: disabled_facility_location → SVG ──────────────────────────
      // disabled হলে → location অনুযায়ী icon (ALL/BACK/RIGHT/LEFT/NONE)
      // disabled না হলে → NONE icon (default parking)
      final String locationKey = isDisabled
          ? ((parking['disabled_facility_location'] as String?) ?? 'NONE')
          .toUpperCase()
          : 'NONE';

      final BitmapDescriptor icon = await _getLocationIcon(locationKey);
      // ────────────────────────────────────────────────────────────────────

      newMarkers.add(
        Marker(
          markerId: MarkerId(parking['id'] ?? 'parking_$i'),
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow(
            title: isPaid
                ? '💰 ${'map_paid_parking'.tr}'
                : '🆓 ${'map_free_parking'.tr}',
            snippet: [
              if (hasCharging) '⚡ ${'map_electric_charging'.tr}',
              if (isDisabled) '♿ ${'map_disabled_facility'.tr}',
            ].join('  |  '),
          ),
          onTap: () => _onMarkerTap(parking),
        ),
      );
    }

    markers.value = newMarkers;
    mapDebug('markers: built ${newMarkers.length} from parking list');
  }

  // ─── Location → Icon (cached) ─────────────────────────────────────────────
  Future<BitmapDescriptor> _getLocationIcon(String location) async {
    final String key = location.toUpperCase();

    if (_locationIconCache.containsKey(key)) {
      return _locationIconCache[key]!;
    }

    final icon = await _svgMarker(_assetForLocation(key));
    _locationIconCache[key] = icon;
    mapDebug('icon cache: loaded "$key"');
    return icon;
  }

  /// API value → SVG asset path
  String _assetForLocation(String location) {
    switch (location) {
      case 'ALL':
        return AssetsPath.all;
      case 'BACK':
        return AssetsPath.back;
      case 'RIGHT':
        return AssetsPath.right;
      case 'LEFT':
        return AssetsPath.left;
      case 'NONE':
      default:
        return AssetsPath.none;
    }
  }

  // ─── SVG → BitmapDescriptor ───────────────────────────────────────────────
  Future<BitmapDescriptor> _svgMarker(String assetPath) async {
    const double size = 88;

    final rawSvg = await rootBundle.loadString(assetPath);

    final pictureInfo = await vg.vg.loadPicture(
      vg.SvgStringLoader(rawSvg),
      null,
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final srcSize = pictureInfo.size;
    canvas.scale(size / srcSize.width, size / srcSize.height);
    canvas.drawPicture(pictureInfo.picture);
    pictureInfo.picture.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    picture.dispose();

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // ─── Marker Tap ───────────────────────────────────────────────────────────
  void _onMarkerTap(Map<String, dynamic> parking) {
    selectedReport.value = parking;
    mapDebug(
      'marker tap: id=${parking['id']} '
          'cost=${parking['parking_cost']} '
          'ev=${parking['electric_charging']} '
          'disabled=${parking['disabled_facility']} '
          'location=${parking['disabled_facility_location']}',
    );
  }

  // ─── Helpers (UI) ─────────────────────────────────────────────────────────
  String parkingInfoText(Map<String, dynamic> parking) {
    return '${'map_cost'.tr}: ${parking['parking_cost']}  |  '
        '${'map_ev'.tr}: ${parking['electric_charging']}  |  '
        '${'map_disabled'.tr}: ${parking['disabled_facility']}';
  }

  String parkingCostText(Map<String, dynamic> parking) =>
      (parking['parking_cost'] ?? '-').toString();

  String boolFlag(dynamic value) => value == true ? 'yes'.tr : 'no'.tr;

  void clearSelectedReport() => selectedReport.value = null;

  // ─── Map Ready Callback ───────────────────────────────────────────────────
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
  }

  // ─── Type Helper ─────────────────────────────────────────────────────────
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}