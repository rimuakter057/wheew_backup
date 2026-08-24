import 'package:platchatapp/utils/color/app_colors.dart';

import 'dart:convert';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as vg;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/feature/map/model/saved_parking_model.dart';

/// Disabled facility location options
enum DisabledLocation { all, top, back, right, left, none }

extension DisabledLocationX on DisabledLocation {
  String get value => name.toUpperCase();
}

class ParkingReportController extends GetxController {

  final selectedMapType = MapType.normal.obs;

  void changeMapType(MapType type) {
    selectedMapType.value = type;
  }
  // -- Form State ------------------------------------------------------------


  final TextEditingController nameController = TextEditingController();
  final RxString parkingCost = 'FREE'.obs;
  final RxBool electricCharging = false.obs;
  final RxBool disabledFacility = false.obs;
  final Rx<DisabledLocation> disabledLocation = DisabledLocation.none.obs;

  // -- UI State --------------------------------------------------------------
  final RxBool isLoading = false.obs;
  final RxString submitMessage = ''.obs;
  final RxBool submitSuccess = false.obs;


  // -- Reset -----------------------------------------------------------------
  void reset() {
    nameController.clear();
    parkingCost.value = 'FREE';
    electricCharging.value = false;
    disabledFacility.value = false;
    disabledLocation.value = DisabledLocation.none;
  }

  // -- Submit ----------------------------------------------------------------
  // Old flow — POST /parking-report/spot. Superseded by the /park-relay/
  // parking-areas call below; kept here, commented, for reference.
  // Future<bool> addParking({
  //   required double latitude,
  //   required double longitude,
  // }) async
  // {
  //   isLoading.value = true;
  //   submitMessage.value = '';
  //   submitSuccess.value = false;
  //
  //   final Map<String, dynamic> body = {
  //     'latitude': latitude,
  //     'longitude': longitude,
  //     'parking_cost': parkingCost.value,
  //     'electric_charging': electricCharging.value,
  //     'disabled_facility': disabledFacility.value,
  //     if (disabledFacility.value)
  //       'disabled_facility_location': disabledLocation.value.value,
  //   };
  //
  //   try {
  //     final response = await ApiClient.postData(
  //       uri: ApiUrl.addParking,
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       submitSuccess.value = true;
  //       submitMessage.value = AppStrings.mapParkingReportSubmitted.tr;
  //       mapDebug('parking POST: success');
  //       return true;
  //     } else {
  //       final decoded = jsonDecode(response.body);
  //       final msg =
  //       (decoded is Map<String, dynamic> && decoded['message'] != null)
  //           ? decoded['message'].toString()
  //           : AppStrings.somethingWentWrong.tr;
  //       submitMessage.value = msg;
  //       mapDebug('parking POST: failed ${response.statusCode} message=$msg');
  //       return false;
  //     }
  //   } catch (e) {
  //     submitMessage.value = e.toString();
  //     mapDebug('parking POST: exception $e');
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  /// POST /park-relay/parking-areas — home tab "Add Parking" flow.
  Future<bool> addParking({
    required double latitude,
    required double longitude,
    String? name,
    int totalSpots = 1,
  }) async {
    isLoading.value = true;
    submitMessage.value = '';
    submitSuccess.value = false;

    final String areaName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : 'My Parking Spot');

    final List<String> areaTypes = [
      if (electricCharging.value) 'ELECTRIC_CHARGING',
      if (disabledFacility.value) 'DISABLED_FACILITY',
    ];

    final Map<String, dynamic> body = {
      'name': areaName,
      // 'description': description, // no description input in the UI yet
      'centerLat': latitude,
      'centerLng': longitude,
      'parkingCost': parkingCost.value,
      // 'parkingFee': parkingFee, // no fee input in the UI yet (PAID only)
      'parkingAreaTypes': areaTypes,
      if (disabledFacility.value)
        'disabledFacilityLocation': disabledLocation.value.value,
      'totalSpots': totalSpots,
    };

    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.createParkingArea,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        submitSuccess.value = true;
        submitMessage.value = AppStrings.mapParkingReportSubmitted.tr;
        mapDebug('parking area POST: success');
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final msg =
        (decoded is Map<String, dynamic> && decoded['message'] != null)
            ? decoded['message'].toString()
            : AppStrings.somethingWentWrong.tr;
        submitMessage.value = msg;
        mapDebug('parking area POST: failed ${response.statusCode} message=$msg');
        return false;
      }
    } catch (e) {
      submitMessage.value = e.toString();
      mapDebug('parking area POST: exception $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- Saved Parking State (New Feature) ------------------------------------
  final Rxn<SavedParkingModel> mySavedParking = Rxn<SavedParkingModel>();
  final RxBool isLoadingSaveParking = false.obs;
  final RxBool isLoadingGetSavedParking = false.obs;

  Future<bool> saveMyParking({
    required double latitude,
    required double longitude,
    required String parkingType,
    int? durationMin,
    String? name,
  }) async {
    isLoadingSaveParking.value = true;
    submitMessage.value = '';
    submitSuccess.value = false;

    final Map<String, dynamic> body = {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': 10,
      'confidence': 0.91,
      'source': 'AUTO',
      'parkingType': parkingType,
      if (parkingType == 'PAID' && durationMin != null) 'durationMin': durationMin,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
    };

    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.saveParking,
        body: body,
      );

      debugPrint('ðŸŸ¢ SAVE PARKING STATUS CODE: ${response.statusCode}');
      debugPrint('ðŸŸ¢ SAVE PARKING BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        submitSuccess.value = true;
        submitMessage.value = 'Parking location saved successfully';
        mapDebug('save parking POST: success');

        // Refresh the saved parking, but skip the parking-mode/parked POST —
        // saving already establishes the parked state, no need to re-notify.
        await fetchMySavedParking(notifyParkedMode: false);
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final msg = (decoded is Map<String, dynamic> && decoded['message'] != null)
            ? decoded['message'].toString()
            : AppStrings.somethingWentWrong.tr;
        submitMessage.value = msg;
        mapDebug('save parking POST: failed ${response.statusCode} message=$msg');
        return false;
      }
    } catch (e) {
      submitMessage.value = e.toString();
      mapDebug('save parking POST: exception $e');
      return false;
    } finally {
      isLoadingSaveParking.value = false;
    }
  }

  Future<void> fetchMySavedParking({bool notifyParkedMode = true}) async {
    isLoadingGetSavedParking.value = true;
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.getMySavedParking,
      );

      debugPrint('ðŸŸ¢ GET MY SAVED PARKING STATUS CODE: ${response.statusCode}');
      debugPrint('ðŸŸ¢ GET MY SAVED PARKING BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded is Map<String, dynamic>) {
          final model = SavedParkingModel.fromJson(decoded);
          mySavedParking.value = model;
          mapDebug('get saved parking GET: success');

          // POST /park-relay/parking-mode/parked is called upon GET success
          if (notifyParkedMode && model.latitude != null && model.longitude != null) {
            try {
              final responseParked = await ApiClient.postData(
                uri: ApiUrl.parkingModeParked,
                body: {
                  'latitude': model.latitude,
                  'longitude': model.longitude,
                  'accuracy': model.accuracy ?? 8,
                  'confidence': model.confidence ?? 0.9,
                },
              );
              debugPrint('ðŸŸ¢ PARKING MODE PARKED STATUS CODE: ${responseParked.statusCode}');
              debugPrint('ðŸŸ¢ PARKING MODE PARKED BODY: ${responseParked.body}');
            } catch (e) {
              mapDebug('parking mode parked POST: exception $e');
            }
          }
        } else {
          mySavedParking.value = null;
        }
      } else {
        mySavedParking.value = null;
        mapDebug('get saved parking GET: failed ${response.statusCode}');
      }
    } catch (e) {
      mySavedParking.value = null;
      mapDebug('get saved parking GET: exception $e');
    } finally {
      isLoadingGetSavedParking.value = false;
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  GET PARKING
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  // --- State ----------------------------------------------------------------
  final RxBool isLoadingShowDetails = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> parkingList =
      <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedReport = Rxn<Map<String, dynamic>>();

  // icon cache
  final Map<String, BitmapDescriptor> _locationIconCache = {};

  // Map controller, markers & polygons
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  // Old outline — Polyline has no tap support, so only the center marker
  // was tappable. Superseded by areaPolygons below.
  // final RxSet<Polyline> areaPolylines = <Polyline>{}.obs;
  final RxSet<Polygon> areaPolygons = <Polygon>{}.obs;

  // -- Build Markers ---------------------------------------------------------
  // Future<void> _buildMarkers() async {
  //   final Set<Marker> newMarkers = {};
  //
  //   for (int i = 0; i < parkingList.length; i++) {
  //     final parking = parkingList[i];
  //
  //     final double? lat = _toDouble(parking['latitude']);
  //     final double? lng = _toDouble(parking['longitude']);
  //     if (lat == null || lng == null) continue;
  //
  //     final bool isDisabled = parking['disabled_facility'] == true;
  //     final bool hasCharging = parking['electric_charging'] == true;
  //     final dynamic cost = parking['parking_cost'];
  //     final bool isPaid = _isPaid(cost);
  //
  //     // -- Pin color ----------------------------------------------------------
  //     final Color pinColor;
  //     if (isDisabled) {
  //       pinColor = AppColors.disableOrange;
  //     } else if (hasCharging) {
  //       pinColor = AppColors.chargingGreen;
  //     } else if (isPaid) {
  //       pinColor = AppColors.paidBlue;
  //     } else {
  //       pinColor = AppColors.white;
  //     }
  //
  //     final String locationKey = isDisabled
  //         ? ((parking['disabled_facility_location'] as String?) ?? 'NONE')
  //         .toUpperCase()
  //         : 'NONE';
  //
  //     final BitmapDescriptor icon =
  //     await _getLocationIcon(locationKey, pinColor);
  //
  //     // ✅ Offset নেই — exact lat/lng তে রাখো
  //     // à¦à¦•à¦‡ position-à¦ à¦à¦•à¦¾à¦§à¦¿à¦• marker à¦¥à¦¾à¦•à¦²à§‡ à¦à¦•à¦Ÿà¦¾à¦° à¦‰à¦ªà¦° à¦†à¦°à§‡à¦•à¦Ÿà¦¾ stack à¦¹à¦¬à§‡
  //     // MarkerId à¦†à¦²à¦¾à¦¦à¦¾ à¦°à¦¾à¦–à¦¤à§‡ parking id à¦¬à¦¾ index à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à§‹
  //     newMarkers.add(
  //       Marker(
  //         markerId: MarkerId(parking['id']?.toString() ?? 'parking_$i'),
  //         position: LatLng(lat, lng), // â† exact position, à¦•à§‹à¦¨à§‹ offset à¦¨à§‡à¦‡
  //         icon: icon,
  //         infoWindow: InfoWindow.noText,
  //         onTap: () => _onMarkerTap(parking),
  //       ),
  //     );
  //   }
  //
  //   markers.value = newMarkers;
  //   mapDebug('markers: built ${newMarkers.length} from parking list');
  // }

  // --- Location â†’ Icon (cached) ---------------------------------------------











  Future<void> _buildMarkers() async {
    final Set<Marker> newMarkers = {};
    final Set<Polygon> newPolygons = {};

    for (int i = 0; i < parkingList.length; i++) {
      final parking = parkingList[i];

      // isActive == false â†’ hide this area entirely (no marker, no polygon).
      if (parking['isActive'] == false) continue;

      // -- Center marker (SVG pin at centerLat/centerLng) ------------------
      final double? lat = _toDouble(parking['latitude'] ?? parking['centerLat']);
      final double? lng = _toDouble(parking['longitude'] ?? parking['centerLng']);
      if (lat == null || lng == null) continue;

      // Center icon commented out per user request when getting area
      // final BitmapDescriptor icon = await MapMarkerIcons.parkingPin();
      // final String areaId = parking['id']?.toString() ?? 'parking_$i';

      // newMarkers.add(
      //   Marker(
      //     markerId: MarkerId(areaId),
      //     position: LatLng(lat, lng),
      //     icon: icon,
      //     infoWindow: InfoWindow.noText,
      //     onTap: () => _onMarkerTap(parking),
      //   ),
      // );
      final String areaId = parking['id']?.toString() ?? 'parking_$i';

      // -- Blue polygon outline from polygon array --------------------------
      // Old version used a closed Polyline for the outline, but Polyline
      // has no tap support — only the center marker was tappable. Polygon
      // renders the same blue outline (transparent fill) and is tappable
      // anywhere inside the shape.
      // final dynamic rawPolygon = parking['polygon'];
      // if (rawPolygon is List && rawPolygon.isNotEmpty) {
      //   final List<LatLng> polyPoints = [];
      //   for (final point in rawPolygon) {
      //     if (point is Map) {
      //       final double? pLat = _toDouble(point['latitude']);
      //       final double? pLng = _toDouble(point['longitude']);
      //       if (pLat != null && pLng != null) {
      //         polyPoints.add(LatLng(pLat, pLng));
      //       }
      //     }
      //   }
      //   if (polyPoints.isNotEmpty) {
      //     // Close the polygon by repeating the first point
      //     polyPoints.add(polyPoints.first);
      //     newPolylines.add(
      //       Polyline(
      //         polylineId: PolylineId('area_poly_$areaId'),
      //         points: polyPoints,
      //         color: const Color(0xFF1E88E5),   // blue
      //         width: 2,
      //         patterns: [],
      //       ),
      //     );
      //   }
      // }

      final dynamic rawPolygon = parking['polygon'];
      if (rawPolygon is List && rawPolygon.isNotEmpty) {
        final List<LatLng> polyPoints = [];
        for (final point in rawPolygon) {
          if (point is Map) {
            final double? pLat = _toDouble(point['latitude']);
            final double? pLng = _toDouble(point['longitude']);
            if (pLat != null && pLng != null) {
              polyPoints.add(LatLng(pLat, pLng));
            }
          }
        }
        if (polyPoints.isNotEmpty) {
          newPolygons.add(
            Polygon(
              polygonId: PolygonId('area_poly_$areaId'),
              points: polyPoints,
              strokeColor: const Color(0xFF1E88E5), // blue
              strokeWidth: 2,
              fillColor: AppColors.transparent,
              consumeTapEvents: true,
              onTap: () => _onMarkerTap(parking),
            ),
          );
        }
      }
    }

    markers.value = newMarkers;
    areaPolygons.value = newPolygons;
    mapDebug('markers: built ${newMarkers.length} from parking list');
    mapDebug('polygons: built ${newPolygons.length} area outlines');
  }





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

  /// API value â†’ SVG asset path
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

    // -- Case 1: base64 PNG embedded ---------------------------------------
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

    // -- Case 2: Pure SVG --------------------------------------------------
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
///show single spot details===============
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

  // --- Helpers (UI) ---------------------------------------------------------

  void _onMarkerTap(Map<String, dynamic> parking) {
    selectedReport.value = parking;
    mapDebug('marker tap: id=${parking['id']}');
  }



  String parkingInfoText(Map<String, dynamic> parking) {
    return '${AppStrings.mapCost.tr}: ${parking['parking_cost']}  |  '
        '${AppStrings.mapEv.tr}: ${parking['electric_charging']}  |  '
        '${AppStrings.mapDisabled.tr}: ${parking['disabled_facility']}';
  }

  String parkingCostText(Map<String, dynamic> parking) =>
      (parking['parking_cost'] ?? '-').toString();

  String boolFlag(dynamic value) => value == true ? AppStrings.yes.tr : AppStrings.no.tr;

  void clearSelectedReport() => selectedReport.value = null;

  // --- Map Ready Callback ---------------------------------------------------
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
  }

  // --- Type Helper ---------------------------------------------------------
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // -- Pagination State ------------------------------------------------------
  final RxInt totalParking = 0.obs;
  final RxInt currentPage = 1.obs;

  // --- Fetch Data -----------------------------------------------------------
  Future<void> fetchParkingReport({
    required double latitude,
    required double  longitude,
    required int radius,
  }) async
  {
    _locationIconCache.clear();
    try {
      isLoadingShowDetails.value = true;
      errorMessage.value = '';
      final String uri = ApiUrl.searchParkingAreas(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radius,
      );
      mapDebug('parking API: GET $uri');

      final response = await ApiClient.getData(
        uri: uri,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawList = [];

        if (decoded is Map<String, dynamic>) {
          totalParking.value = decoded['total'] ?? 0;
          currentPage.value = decoded['page'] ?? 1;

          final dynamic nested = decoded['areas'] ??
              decoded['parkingAreas'] ??
              decoded['spots'] ??
              decoded['reports'] ??
              decoded['data'] ??
              decoded['items'];
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
        '${AppStrings.mapFailedToLoadParkingData.tr} (${response.statusCode})';
        mapDebug('parking API: HTTP ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = '${AppStrings.error.tr}: $e';
      mapDebug('parking API: exception $e');
    } finally {
      isLoadingShowDetails.value = false;
      mapDebug('parking API: fetch finished');
    }
  }








  // -- Single Spot Details ------------------------------------------
  final Rxn<Map<String, dynamic>> spotDetails = Rxn<Map<String, dynamic>>();
  final RxBool isLoadingSpotDetails = false.obs;
  final RxBool isLeaving = false.obs;

  Future<void> fetchSpotDetails(String spotId) async {
    try {
      isLoadingSpotDetails.value = true;
      spotDetails.value = null;

      final response = await ApiClient.getData(
        uri: ApiUrl.spotDetails(spotId: spotId), // â† '/parking-report/spot/$spotId'
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        spotDetails.value = Map<String, dynamic>.from(decoded);
        mapDebug('spot details: loaded for $spotId');
      } else {
        mapDebug('spot details: failed ${response.statusCode}');
      }
    } catch (e) {
      mapDebug('spot details: exception $e');
    } finally {
      isLoadingSpotDetails.value = false;
    }
  }

// -- Leave Spot ----------------------------------------------------






  Future<bool> leaveSpot(String spotId) async {
    try {
      isLeaving.value = true;

      final response = await ApiClient.postData(
        uri: ApiUrl.leaveSpot,
        body: {"spotId": spotId},
      );

      // â† debugPrint add à¦•à¦°à¦¾ à¦¹à¦²à§‹
      debugPrint('ðŸŸ¡ LEAVE STATUS CODE: ${response.statusCode}');
      debugPrint('ðŸŸ¡ LEAVE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        mapDebug('leave spot: success $spotId');
        return true;
      } else {
        mapDebug('leave spot: failed ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('ðŸ”´ LEAVE EXCEPTION: $e'); // â† à¦à¦Ÿà¦¾à¦“ add à¦•à¦°à¦¾ à¦¹à¦²à§‹
      mapDebug('leave spot: exception $e');
      return false;
    } finally {
      isLeaving.value = false;
    }
  }














  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  PARK-RELAY: PARKING AREAS & HANDOFFS (Home tab)
  //  addParking() above already covers POST /park-relay/parking-areas.
  //  The GET endpoints below are callable API methods only; not yet wired
  //  into any marker/UI on the home tab (no design change).
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  // --- Search nearby parking areas ------------------------------------------
  final RxList<Map<String, dynamic>> parkingAreaList = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingParkingAreas = false.obs;

  /// GET /park-relay/parking-areas/search
  Future<void> searchParkingAreas({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    isLoadingParkingAreas.value = true;
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.searchParkingAreas(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded is List ? decoded : [];
        parkingAreaList.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        mapDebug('search parking areas GET: loaded ${parkingAreaList.length}');
      } else {
        mapDebug('search parking areas GET: failed ${response.statusCode}');
      }
    } catch (e) {
      mapDebug('search parking areas GET: exception $e');
    } finally {
      isLoadingParkingAreas.value = false;
    }
  }

  // --- Nearby handoffs -------------------------------------------------------
  final RxList<Map<String, dynamic>> handoffList = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHandoffs = false.obs;

  /// GET /park-relay/handoffs/nearby
  Future<void> fetchNearbyHandoffs({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    isLoadingHandoffs.value = true;
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.nearbyHandoffs(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded is List ? decoded : [];
        handoffList.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        mapDebug('nearby handoffs GET: loaded ${handoffList.length}');
      } else {
        mapDebug('nearby handoffs GET: failed ${response.statusCode}');
      }
    } catch (e) {
      mapDebug('nearby handoffs GET: exception $e');
    } finally {
      isLoadingHandoffs.value = false;
    }
  }

  // --- Handoff details (show details) ----------------------------------------
  final Rxn<Map<String, dynamic>> handoffDetails = Rxn<Map<String, dynamic>>();
  final RxBool isLoadingHandoffDetails = false.obs;

  /// GET /park-relay/handoffs/{handoffId}
  Future<void> fetchHandoffDetails({
    required String handoffId,
    required double latitude,
    required double longitude,
  }) async {
    isLoadingHandoffDetails.value = true;
    handoffDetails.value = null;
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.handoffDetails(
          handoffId: handoffId,
          latitude: latitude,
          longitude: longitude,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          handoffDetails.value = Map<String, dynamic>.from(decoded);
        }
        mapDebug('handoff details GET: loaded for $handoffId');
      } else {
        mapDebug('handoff details GET: failed ${response.statusCode}');
      }
    } catch (e) {
      mapDebug('handoff details GET: exception $e');
    } finally {
      isLoadingHandoffDetails.value = false;
    }
  }

  void toggleDisabledFacility() {
    disabledFacility.value = !disabledFacility.value;
    if (disabledFacility.value) {
      parkingCost.value = 'FREE'; // disabled facility à¦¥à¦¾à¦•à¦²à§‡ auto FREE
    }
  }



}

