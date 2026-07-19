
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
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
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
  Future<bool> addParking({
    required double latitude,
    required double longitude,
  }) async
  {
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
        uri: ApiUrl.addParking,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        submitSuccess.value = true;
        submitMessage.value = AppStrings.mapParkingReportSubmitted.tr;
        mapDebug('parking POST: success');
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final msg =
        (decoded is Map<String, dynamic> && decoded['message'] != null)
            ? decoded['message'].toString()
            : AppStrings.somethingWentWrong.tr;
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

  // ─── Saved Parking State (New Feature) ────────────────────────────────────
  final Rxn<SavedParkingModel> mySavedParking = Rxn<SavedParkingModel>();
  final RxBool isLoadingSaveParking = false.obs;
  final RxBool isLoadingGetSavedParking = false.obs;

  Future<bool> saveMyParking({
    required double latitude,
    required double longitude,
    required String parkingType,
    int? durationMin,
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
    };

    try {
      final response = await ApiClient.postData(
        uri: ApiUrl.saveParking,
        body: body,
      );

      debugPrint('🟢 SAVE PARKING STATUS CODE: ${response.statusCode}');
      debugPrint('🟢 SAVE PARKING BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        submitSuccess.value = true;
        submitMessage.value = 'Parking location saved successfully';
        mapDebug('save parking POST: success');

        await fetchMySavedParking(); // Refresh the saved parking (will trigger parked API)
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        final msg = (decoded is Map<String, dynamic> && decoded['message'] != null)
            ? decoded['message'].toString()
            : 'Something went wrong';
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

  Future<void> fetchMySavedParking() async {
    isLoadingGetSavedParking.value = true;
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.getMySavedParking,
      );

      debugPrint('🟢 GET MY SAVED PARKING STATUS CODE: ${response.statusCode}');
      debugPrint('🟢 GET MY SAVED PARKING BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded is Map<String, dynamic>) {
          final model = SavedParkingModel.fromJson(decoded);
          mySavedParking.value = model;
          mapDebug('get saved parking GET: success');

          // POST /park-relay/parking-mode/parked is called upon GET success
          if (model.latitude != null && model.longitude != null) {
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
              debugPrint('🟢 PARKING MODE PARKED STATUS CODE: ${responseParked.statusCode}');
              debugPrint('🟢 PARKING MODE PARKED BODY: ${responseParked.body}');
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
  // API থেকে "FREE" language আসে — সব case handle করে
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
  //     // ── Pin color ──────────────────────────────────────────────────────────
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
  //     // একই position-এ একাধিক marker থাকলে একটার উপর আরেকটা stack হবে
  //     // MarkerId আলাদা রাখতে parking id বা index ব্যবহার করো
  //     newMarkers.add(
  //       Marker(
  //         markerId: MarkerId(parking['id']?.toString() ?? 'parking_$i'),
  //         position: LatLng(lat, lng), // ← exact position, কোনো offset নেই
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

  // ─── Location → Icon (cached) ─────────────────────────────────────────────











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

      // ===== Icon Condition =====

      String iconPath;

      if (isDisabled) {
      //  iconPath = AssetsPath.disableCar;
        iconPath = AssetsPath.bluePin;
      } else if (hasCharging) {
       // iconPath = AssetsPath.electricCar;
        iconPath = AssetsPath.bluePin;
      } else if (isPaid) {
       // iconPath = AssetsPath.paidCar;
        iconPath = AssetsPath.bluePin;
      } else {
       // iconPath = AssetsPath.freeCar;
        iconPath = AssetsPath.bluePin;
      }

      final BitmapDescriptor icon =
      await _getCarIcon(iconPath);

      newMarkers.add(
        Marker(
          markerId: MarkerId(
            parking['id']?.toString() ?? 'parking_$i',
          ),
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow.noText,
          onTap: () => _onMarkerTap(parking),
        ),
      );
    }

    markers.value = newMarkers;
    mapDebug('markers: built ${newMarkers.length} from parking list');
  }





  final Map<String, BitmapDescriptor> _carIconCache = {};

  Future<BitmapDescriptor> _getCarIcon(String assetPath) async {
    if (_carIconCache.containsKey(assetPath)) {
      return _carIconCache[assetPath]!;
    }

    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List resizedBytes = await _resizeIcon(
      data.buffer.asUint8List(),
      targetWidth: 48, // ← এখানে size adjust করো (কম মানে ছোট icon)
    );

    final icon = BitmapDescriptor.bytes(resizedBytes);

    _carIconCache[assetPath] = icon;
    return icon;
  }

// ── নতুন helper ───────────────────────────────────────────────
  Future<Uint8List> _resizeIcon(Uint8List data, {required int targetWidth}) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      data,
      targetWidth: targetWidth,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
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

  // ─── Helpers (UI) ─────────────────────────────────────────────────────────

  void _onMarkerTap(Map<String, dynamic> parking) {
    selectedReport.value = parking;

    final spotId = parking['id']?.toString();
    if (spotId != null) {
      fetchSpotDetails(spotId); // ← নতুন call
    }

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
    required double latitude,
    required double  longitude,
    required int radius,
  }) async
  {
    _locationIconCache.clear();
    try {
      isLoadingShowDetails.value = true;
      errorMessage.value = '';
      mapDebug('parking API: GET ${ApiUrl.showMapDetails}');

      final response = await ApiClient.getData(
        uri: ApiUrl.showMapDetails(latitude:latitude ,longitude:longitude,radius: radius ),
        // queryParams: {
        //   'latitude': latitude.toString(),
        //   'longitude': longitude.toString(),
        // },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawList = [];

        if (decoded is Map<String, dynamic>) {
          totalParking.value = decoded['total'] ?? 0;
          currentPage.value = decoded['page'] ?? 1;

          final dynamic nested = decoded['spots'] ?? decoded['reports'] ?? decoded['data'];
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








  // ── Single Spot Details ──────────────────────────────────────────
  final Rxn<Map<String, dynamic>> spotDetails = Rxn<Map<String, dynamic>>();
  final RxBool isLoadingSpotDetails = false.obs;
  final RxBool isLeaving = false.obs;

  Future<void> fetchSpotDetails(String spotId) async {
    try {
      isLoadingSpotDetails.value = true;
      spotDetails.value = null;

      final response = await ApiClient.getData(
        uri: ApiUrl.spotDetails(spotId: spotId), // ← '/parking-report/spot/$spotId'
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

// ── Leave Spot ────────────────────────────────────────────────────






  Future<bool> leaveSpot(String spotId) async {
    try {
      isLeaving.value = true;

      final response = await ApiClient.postData(
        uri: ApiUrl.leaveSpot,
        body: {"spotId": spotId},
      );

      // ← debugPrint add করা হলো
      debugPrint('🟡 LEAVE STATUS CODE: ${response.statusCode}');
      debugPrint('🟡 LEAVE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        mapDebug('leave spot: success $spotId');
        return true;
      } else {
        mapDebug('leave spot: failed ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 LEAVE EXCEPTION: $e'); // ← এটাও add করা হলো
      mapDebug('leave spot: exception $e');
      return false;
    } finally {
      isLeaving.value = false;
    }
  }














  void toggleDisabledFacility() {
    disabledFacility.value = !disabledFacility.value;
    if (disabledFacility.value) {
      parkingCost.value = 'FREE'; // disabled facility থাকলে auto FREE
    }
  }



}