// // ignore_for_file: invalid_use_of_protected_member
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart' as vg;
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:platchatapp/core/service/api_client.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/feature/map/utils/map_debug.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// /// Disabled facility location options
// enum DisabledLocation { all, top, back, right, left, none }
//
// extension DisabledLocationX on DisabledLocation {
//   String get value => name.toUpperCase(); // ALL, TOP, BACK, RIGHT, LEFT, NONE
// }
//
// class ParkingReportController extends GetxController {
//   // ── Form State ───────────────────────────────────────────────────────────────
//   final RxString parkingCost = 'FREE'.obs; // FREE | PAID
//   final RxBool electricCharging = false.obs;
//   final RxBool disabledFacility = false.obs;
//   final Rx<DisabledLocation> disabledLocation = DisabledLocation.none.obs;
//
//   // ── UI State ─────────────────────────────────────────────────────────────────
//   final RxBool isLoading = false.obs;
//   final RxString submitMessage = ''.obs;
//   final RxBool submitSuccess = false.obs;
//
//   // ── Reset ────────────────────────────────────────────────────────────────────
//   void reset() {
//     parkingCost.value = 'FREE';
//     electricCharging.value = false;
//     disabledFacility.value = false;
//     disabledLocation.value = DisabledLocation.none;
//   }
//
//   // ── Submit ───────────────────────────────────────────────────────────────────
//   Future<bool> submitParkingReport({
//     required double latitude,
//     required double longitude,
//   }) async {
//     isLoading.value = true;
//     submitMessage.value = '';
//     submitSuccess.value = false;
//
//     final Map<String, dynamic> body = {
//       'latitude': latitude,
//       'longitude': longitude,
//       'parking_cost': parkingCost.value,
//       'electric_charging': electricCharging.value,
//       'disabled_facility': disabledFacility.value,
//       if (disabledFacility.value)
//         'disabled_facility_location': disabledLocation.value.value,
//     };
//
//     try {
//       final response = await ApiClient.postData(
//         uri: ApiUrl.parkingReport,
//         body: body,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         submitSuccess.value = true;
//         submitMessage.value = 'map_parking_report_submitted'.tr;
//         mapDebug('parking POST: success');
//         return true;
//       } else {
//         final decoded = jsonDecode(response.body);
//         final msg =
//         (decoded is Map<String, dynamic> && decoded['message'] != null)
//             ? decoded['message'].toString()
//             : 'something_went_wrong'.tr;
//         submitMessage.value = msg;
//         mapDebug('parking POST: failed ${response.statusCode} message=$msg');
//         return false;
//       }
//     } catch (e) {
//       submitMessage.value = e.toString();
//       mapDebug('parking POST: exception $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   //  GET PARKING
// // ═══════════════════════════════════════════════════════════════════════════
//
//   // ─── State ───────────────────────────────────────────────────────────────
//   final RxBool isLoadingShowDetails = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxList<Map<String, dynamic>> parkingList =
//       <Map<String, dynamic>>[].obs;
//   final Rxn<Map<String, dynamic>> selectedReport =
//   Rxn<Map<String, dynamic>>();
//
//   // Per-location icon cache — key: "ALL_colorValue" | "BACK_colorValue" | etc.
//   final Map<String, BitmapDescriptor> _locationIconCache = {};
//
//   // Map controller & markers
//   final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
//   final RxSet<Marker> markers = <Marker>{}.obs;
//
//
//   Future<void> _buildMarkers() async {
//     final Set<Marker> newMarkers = {};
//
//     // ── Same position-এ কতটা marker আছে track করুন ──────────────
//     final Map<String, List<int>> positionGroups = {};
//
//     for (int i = 0; i < parkingList.length; i++) {
//       final parking = parkingList[i];
//       final double? lat = _toDouble(parking['latitude']);
//       final double? lng = _toDouble(parking['longitude']);
//       if (lat == null || lng == null) continue;
//
//       final String posKey =
//           '${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';
//       positionGroups.putIfAbsent(posKey, () => []).add(i);
//     }
//     // ─────────────────────────────────────────────────────────────
//
//     // ── প্রতিটা group process করুন ───────────────────────────────
//     for (final entry in positionGroups.entries) {
//       final List<int> indices = entry.value;
//
//       for (int g = 0; g < indices.length; g++) {
//         final int i = indices[g];
//         final parking = parkingList[i];
//
//         final double lat = _toDouble(parking['latitude'])!;
//         final double lng = _toDouble(parking['longitude'])!;
//
//         // ── Offset: একই position হলে উপর-নিচে সাজাও ─────────────
//         // প্রথমটা original position, পরেরগুলো নিচে নামবে
//         const double offsetStep = 0.00012; // ~13 মিটার
//         final double finalLat = lat - (g * offsetStep);
//         final double finalLng = lng;
//         // ─────────────────────────────────────────────────────────
//
//         final bool isDisabled = parking['disabled_facility'] == true;
//         final bool hasCharging = parking['electric_charging'] == true;
//         final dynamic cost = parking['parking_cost'];
//         // final bool isPaid =
//         //     cost != null && cost != 0 && cost != '0' && cost != '';
//
//
//
//         bool _isPaid(dynamic cost) {
//           if (cost == null) return false;
//           if (cost is int) return cost != 0;
//           if (cost is double) return cost != 0.0;
//           if (cost is String) {
//             final t = cost.trim().toLowerCase();
//             return t.isNotEmpty && t != '0' && t != 'free';
//           }
//           return false;
//         }
//
//
//         final bool isPaid = _isPaid(cost);
//
//
//
//         final Color pinColor;
//         if (isDisabled) {
//           pinColor = AppColors.disableOrange;
//         } else if (hasCharging) {
//           pinColor = AppColors.chargingGreen;
//         } else if (isPaid) {
//           pinColor = AppColors.paidBlue;
//         } else {
//           pinColor = AppColors.white;
//         }
//
//         final String locationKey = isDisabled
//             ? ((parking['disabled_facility_location'] as String?) ?? 'NONE')
//             .toUpperCase()
//             : 'NONE';
//
//         final BitmapDescriptor icon =
//         await _getLocationIcon(locationKey, pinColor);
//
//         newMarkers.add(
//           Marker(
//             markerId: MarkerId(parking['id'] ?? 'parking_$i'),
//             position: LatLng(finalLat, finalLng), // ← offset position
//             icon: icon,
//             infoWindow: InfoWindow.noText,
//             onTap: () => _onMarkerTap(parking),
//           ),
//         );
//       }
//     }
//
//     markers.value = newMarkers;
//     mapDebug('markers: built ${newMarkers.length} from parking list');
//   }
//
//   // ─── Location → Icon (cached) ─────────────────────────────────────────────
//   Future<BitmapDescriptor> _getLocationIcon(String location, Color color) async {
//     final String key = '${location.toUpperCase()}_${color.value}';
//     print('=== ICON KEY: $key ==='); // ← এটা add করুন
//
//     if (_locationIconCache.containsKey(key)) {
//       print('=== FROM CACHE ==='); // ← এটা
//       return _locationIconCache[key]!;
//     }
//
//     print('=== LOADING SVG for location=$location color=$color ==='); // ← এটা
//     final icon = await _svgMarker(_assetForLocation(location.toUpperCase()), color);
//
//
// // এখানে call করুন
//
//
//     _locationIconCache[key] = icon;
//     mapDebug('icon cache: loaded "$key"');
//     return icon;
//   }
//
//   /// API value → SVG asset path
//   String _assetForLocation(String location) {
//     switch (location) {
//       case 'ALL':
//         return AssetsPath.all;
//       case 'BACK':
//         return AssetsPath.back;
//       case 'RIGHT':
//         return AssetsPath.right;
//       case 'LEFT':
//         return AssetsPath.left;
//       case 'NONE':
//       default:
//         return AssetsPath.none;
//     }
//   }
//
//
//
//
//
//   Future<BitmapDescriptor> _svgMarker(String assetPath, Color color) async {
//     const double size = 88;
//
//     final String rawSvg = await rootBundle.loadString(assetPath);
//
//     // ── Case 1: base64 PNG embedded আছে ─────────────────────────
//     final RegExp regex = RegExp(r'(?:xlink:href|href)="data:image/png;base64,([^"]+)"');
//     final match = regex.firstMatch(rawSvg);
//
//     if (match != null) {
//       final String base64Str = match.group(1)!.replaceAll(RegExp(r'\s'), '');
//       final Uint8List pngBytes = base64Decode(base64Str);
//
//       final ui.Codec codec = await ui.instantiateImageCodec(
//         pngBytes,
//         targetWidth: size.toInt(),
//         targetHeight: size.toInt(),
//       );
//       final ui.FrameInfo frame = await codec.getNextFrame();
//       final ui.Image srcImage = frame.image;
//
//       final ui.PictureRecorder recorder = ui.PictureRecorder();
//       final ui.Canvas canvas = ui.Canvas(recorder);
//
//       canvas.drawImage(srcImage, Offset.zero, Paint());
//       canvas.drawImage(
//         srcImage,
//         Offset.zero,
//         Paint()
//           ..colorFilter = ui.ColorFilter.mode(
//             color.withOpacity(0.65),
//             BlendMode.srcATop,
//           ),
//       );
//
//       final ui.Picture picture = recorder.endRecording();
//       final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
//       final ByteData? byteData = await image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );
//
//       srcImage.dispose();
//       return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
//     }
//
//     // ── Case 2: Pure SVG → flutter_svg PictureInfo দিয়ে render ──
//     try {
//       final vg.PictureInfo pictureInfo = await vg.vg.loadPicture(
//         vg.SvgStringLoader(rawSvg),
//         null,
//       );
//
//       final ui.PictureRecorder recorder = ui.PictureRecorder();
//       final ui.Canvas canvas = ui.Canvas(recorder);
//
//       // Scale করো
//       final double scaleX = size / (pictureInfo.size.width);
//       final double scaleY = size / (pictureInfo.size.height);
//       canvas.scale(scaleX, scaleY);
//       canvas.drawPicture(pictureInfo.picture);
//
//       // Color overlay
//       canvas.drawRect(
//         Rect.fromLTWH(0, 0, pictureInfo.size.width, pictureInfo.size.height),
//         Paint()
//           ..colorFilter = ui.ColorFilter.mode(
//             color.withOpacity(0.55),
//             BlendMode.srcATop,
//           ),
//       );
//
//       pictureInfo.picture.dispose();
//
//       final ui.Picture picture = recorder.endRecording();
//       final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
//       final ByteData? byteData = await image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );
//
//       return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
//     } catch (e) {
//       mapDebug('SVG render error: $e');
//       return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
//     }
//   }
//
//
//
//   void _onMarkerTap(Map<String, dynamic> parking) {
//     selectedReport.value = parking;
//     mapDebug(
//       'marker tap: id=${parking['id']} '
//           'cost=${parking['parking_cost']} '
//           'ev=${parking['electric_charging']} '
//           'disabled=${parking['disabled_facility']} '
//           'location=${parking['disabled_facility_location']}',
//     );
//   }
//
//   // ─── Helpers (UI) ─────────────────────────────────────────────────────────
//   String parkingInfoText(Map<String, dynamic> parking) {
//     return '${'map_cost'.tr}: ${parking['parking_cost']}  |  '
//         '${'map_ev'.tr}: ${parking['electric_charging']}  |  '
//         '${'map_disabled'.tr}: ${parking['disabled_facility']}';
//   }
//
//   String parkingCostText(Map<String, dynamic> parking) =>
//       (parking['parking_cost'] ?? '-').toString();
//
//   String boolFlag(dynamic value) => value == true ? 'yes'.tr : 'no'.tr;
//
//   void clearSelectedReport() => selectedReport.value = null;
//
//   // ─── Map Ready Callback ───────────────────────────────────────────────────
//   void onMapCreated(GoogleMapController controller) {
//     mapController.value = controller;
//   }
//
//   // ─── Type Helper ─────────────────────────────────────────────────────────
//   double? _toDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }
//
//
//
//   // Controller এর top এ add করুন
//   final RxInt totalParking = 0.obs;
//   final RxInt currentPage = 1.obs;
//
// // ─── Fetch Data ──────────────────────────────────────────────────────────
//   Future<void> fetchParkingReport({
//     double? latitude,
//     double? longitude,
//   }) async {
//     _locationIconCache.clear();
//     try {
//       isLoadingShowDetails.value = true;
//       errorMessage.value = '';
//       mapDebug('parking API: GET ${ApiUrl.showDetails}');
//
//       final response = await ApiClient.getData(
//         uri: ApiUrl.showDetails,
//         queryParams: {
//           if (latitude != null) 'latitude': latitude.toString(),
//           if (longitude != null) 'longitude': longitude.toString(),
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final dynamic decoded = jsonDecode(response.body);
//
//         List<dynamic> rawList = [];
//
//         if (decoded is Map<String, dynamic>) {
//           // ✅ total, page save করুন
//           totalParking.value = decoded['total'] ?? 0;
//           currentPage.value = decoded['page'] ?? 1;
//
//           final dynamic nested = decoded['reports'] ?? decoded['data'];
//           if (nested is List) {
//             rawList = nested;
//           } else if (nested is Map<String, dynamic>) {
//             rawList = [nested];
//           }
//         } else if (decoded is List) {
//           rawList = decoded;
//           totalParking.value = rawList.length; // fallback
//         }
//
//         parkingList.value =
//             rawList.map((e) => Map<String, dynamic>.from(e)).toList();
//
//         mapDebug('parking API: loaded ${parkingList.length} row(s), total=${totalParking.value}');
//         await _buildMarkers();
//       } else {
//         errorMessage.value =
//         '${'map_failed_to_load_parking_data'.tr} (${response.statusCode})';
//         mapDebug('parking API: HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       errorMessage.value = '${'error'.tr}: $e';
//       mapDebug('parking API: exception $e');
//     } finally {
//       isLoadingShowDetails.value = false;
//       mapDebug('parking API: fetch finished');
//     }
//   }
//
// }

















// ignore_for_file: invalid_use_of_protected_member
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as vg;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Disabled facility location options
enum DisabledLocation { all, top, back, right, left, none }

extension DisabledLocationX on DisabledLocation {
  String get value => name.toUpperCase();
}

class ParkingReportController extends GetxController {
  // ── Form State ────────────────────────────────────────────────────────────
  final RxString parkingCost = 'FREE'.obs;
  final RxBool electricCharging = false.obs;
  final RxBool disabledFacility = false.obs;
  final Rx<DisabledLocation> disabledLocation = DisabledLocation.none.obs;

  // ── UI State ──────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString submitMessage = ''.obs;
  final RxBool submitSuccess = false.obs;

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    parkingCost.value = 'FREE';
    electricCharging.value = false;
    disabledFacility.value = false;
    disabledLocation.value = DisabledLocation.none;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
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

  // ─── State ────────────────────────────────────────────────────────────────
  final RxBool isLoadingShowDetails = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> parkingList =
      <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedReport = Rxn<Map<String, dynamic>>();

  // icon cache
  final Map<String, BitmapDescriptor> _locationIconCache = {};

  // Map controller & markers
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;

  // ── isPaid helper ─────────────────────────────────────────────────────────
  // API থেকে "FREE" string আসে — সব case handle করে
  bool _isPaid(dynamic cost) {
    if (cost == null) return false;
    if (cost is bool) return false;
    if (cost is int) return cost != 0;
    if (cost is double) return cost != 0.0;
    if (cost is String) {
      final t = cost.trim().toLowerCase();
      return t.isNotEmpty && t != '0' && t != 'free';
    }
    return false;
  }

  // ── Build Markers ─────────────────────────────────────────────────────────
  Future<void> _buildMarkers() async {
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < parkingList.length; i++) {
      final parking = parkingList[i];

      final double? lat = _toDouble(parking['latitude']);
      final double? lng = _toDouble(parking['longitude']);
      if (lat == null || lng == null) continue;

      final bool isDisabled = parking['disabled_facility'] == true;
      final bool hasCharging = parking['electric_charging'] == true;
      final dynamic cost = parking['parking_cost'];
      final bool isPaid = _isPaid(cost);

      // ── Pin color ──────────────────────────────────────────────────────────
      final Color pinColor;
      if (isDisabled) {
        pinColor = AppColors.disableOrange;
      } else if (hasCharging) {
        pinColor = AppColors.chargingGreen;
      } else if (isPaid) {
        pinColor = AppColors.paidBlue;
      } else {
        pinColor = AppColors.white;
      }

      final String locationKey = isDisabled
          ? ((parking['disabled_facility_location'] as String?) ?? 'NONE')
          .toUpperCase()
          : 'NONE';

      final BitmapDescriptor icon =
      await _getLocationIcon(locationKey, pinColor);

      // ✅ Offset নেই — exact lat/lng তে রাখো
      // একই position-এ একাধিক marker থাকলে একটার উপর আরেকটা stack হবে
      // MarkerId আলাদা রাখতে parking id বা index ব্যবহার করো
      newMarkers.add(
        Marker(
          markerId: MarkerId(parking['id']?.toString() ?? 'parking_$i'),
          position: LatLng(lat, lng), // ← exact position, কোনো offset নেই
          icon: icon,
          infoWindow: InfoWindow.noText,
          onTap: () => _onMarkerTap(parking),
        ),
      );
    }

    markers.value = newMarkers;
    mapDebug('markers: built ${newMarkers.length} from parking list');
  }

  // ─── Location → Icon (cached) ─────────────────────────────────────────────
  Future<BitmapDescriptor> _getLocationIcon(
      String location, Color color) async {
    final String key = '${location.toUpperCase()}_${color.value}';

    if (_locationIconCache.containsKey(key)) {
      return _locationIconCache[key]!;
    }

    final icon =
    await _svgMarker(_assetForLocation(location.toUpperCase()), color);
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

  Future<BitmapDescriptor> _svgMarker(String assetPath, Color color) async {
    const double size = 45;

    final String rawSvg = await rootBundle.loadString(assetPath);

    // ── Case 1: base64 PNG embedded ───────────────────────────────────────
    final RegExp regex =
    RegExp(r'(?:xlink:href|href)="data:image/png;base64,([^"]+)"');
    final match = regex.firstMatch(rawSvg);

    if (match != null) {
      final String base64Str =
      match.group(1)!.replaceAll(RegExp(r'\s'), '');
      final Uint8List pngBytes = base64Decode(base64Str);

      final ui.Codec codec = await ui.instantiateImageCodec(
        pngBytes,
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image srcImage = frame.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      canvas.drawImage(srcImage, Offset.zero, Paint());
      canvas.drawImage(
        srcImage,
        Offset.zero,
        Paint()
          ..colorFilter = ui.ColorFilter.mode(
            color.withOpacity(0.65),
            BlendMode.srcATop,
          ),
      );

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image =
      await picture.toImage(size.toInt(), size.toInt());
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      srcImage.dispose();
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    }

    // ── Case 2: Pure SVG ──────────────────────────────────────────────────
    try {
      final vg.PictureInfo pictureInfo = await vg.vg.loadPicture(
        vg.SvgStringLoader(rawSvg),
        null,
      );

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      final double scaleX = size / pictureInfo.size.width;
      final double scaleY = size / pictureInfo.size.height;
      canvas.scale(scaleX, scaleY);
      canvas.drawPicture(pictureInfo.picture);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, pictureInfo.size.width, pictureInfo.size.height),
        Paint()
          ..colorFilter = ui.ColorFilter.mode(
            color.withOpacity(0.55),
            BlendMode.srcATop,
          ),
      );

      pictureInfo.picture.dispose();

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image =
      await picture.toImage(size.toInt(), size.toInt());
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      mapDebug('SVG render error: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

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

  // ── Pagination State ──────────────────────────────────────────────────────
  final RxInt totalParking = 0.obs;
  final RxInt currentPage = 1.obs;

  // ─── Fetch Data ───────────────────────────────────────────────────────────
  Future<void> fetchParkingReport({
    double? latitude,
    double? longitude,
  }) async
  {
    _locationIconCache.clear();
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

        if (decoded is Map<String, dynamic>) {
          totalParking.value = decoded['total'] ?? 0;
          currentPage.value = decoded['page'] ?? 1;

          final dynamic nested = decoded['reports'] ?? decoded['data'];
          if (nested is List) {
            rawList = nested;
          } else if (nested is Map<String, dynamic>) {
            rawList = [nested];
          }
        } else if (decoded is List) {
          rawList = decoded;
          totalParking.value = rawList.length;
        }

        parkingList.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();

        mapDebug(
            'parking API: loaded ${parkingList.length} row(s), total=${totalParking.value}');
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
}