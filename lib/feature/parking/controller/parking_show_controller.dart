import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/feature/parking/repository/parking_repository.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/routes.dart';
import '../../../core/router/routes_name.dart';
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

  // Zoom level the map rests at once nearby spots load — kept close so the
  // markers/red areas are visible immediately without any manual zoom.
  static const double _initialSpotsZoom = 17;

  final RxBool isLoading = false.obs;
  final RxBool isLocating = true.obs;
  // Empty until /parking-mode/me resolves — the screen treats an empty
  // status as "still loading" so it never falls back to showing IDLE's
  // "Find Parking Spot" button by default before the real status is known.
  final RxString status = ''.obs;
  final Rxn<LatLng> gpsPosition = Rxn<LatLng>();
  final Rxn<LatLng> mapCenter = Rxn<LatLng>();
  final RxBool showLocationPulse = false.obs;
  final RxInt selectedRadiusMeter = 100.obs;
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
  Future<void> initializeFlow() async {
    // Don't assert IDLE yet — leave `status` empty ("still loading") until
    // checkParkingModeMe actually resolves the real status below, so the
    // screen never flashes the IDLE "Find Parking Spot" button by default.
    _resetSearchState(setIdleStatus: false);

    isLocating.value = false;
    isRealLocationLoaded.value = false;
    gpsPosition.value = kApproxDefaultLocation;
    mapCenter.value = kApproxDefaultLocation;

    await checkParkingModeMe();
  }

  void _resetSearchState({bool setIdleStatus = true}) {
    handoffList.clear();
    parkingAreaList.clear();
    polygons.clear();
    polylines.clear();
    circles.clear();
    markers.removeWhere((m) => m.markerId.value != 'saved_car_location');
    if (setIdleStatus) {
      status.value = 'IDLE';
    }

    showLocationPulse.value = false;
    mapOverlayVersion.value++;
  }

  Future<void> refreshStatus() async {
    await checkParkingModeMe();
  }

  Future<bool> getUserLocation() async {
    isLocating.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLocating.value = false;
        _showMessage(AppStrings.pleaseEnableLocationService.tr, isError: true);
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLocating.value = false;
        _showMessage(AppStrings.locationPermissionDenied.tr, isError: true);
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

  /// Checks /parking-mode/me and updates [status] so the screen can branch
  /// on it directly (IDLE -> plain search UI, SEARCHING -> auto-search,
  /// PARKED -> active-session card). No dialog is shown automatically here
  /// anymore — the leaving-confirmation dialog is only triggered explicitly
  /// from the "Exit Parking" button now.
  Future<void> checkParkingModeMe() async {
    isLoading.value = true;
    _logger.i('=== checkParkingModeMe START ===');
    try {
      final response = await _repository.getParkingModeMe();
      print(
        "PARKING_MODE_ME_RESPONSE: status=${response.statusCode}, body=${response.body}",
      );
      _logger.d(
        'checkParkingModeMe status: ${response.statusCode}\n'
        'body: ${response.body}',
      );
      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        final String modeStatus =
            data?['status']?.toString().toUpperCase() ?? 'IDLE';
        status.value = modeStatus;

        if (modeStatus == 'SEARCHING' || modeStatus == 'PARKED') {
          // PARKED still needs the real location + nearby markers loaded so
          // the map behind the "You're Parked" card isn't empty — it just
          // skips the search-mode pulse/search-bar UI (handled by the
          // screen from `status`).
          await getUserLocation();
          final lat = gpsPosition.value?.latitude;
          final lng = gpsPosition.value?.longitude;
          if (lat != null && lng != null) {
            await fetchNearbyData(lat, lng);
          }
          if (modeStatus == 'SEARCHING') {
            showLocationPulse.value = true;
          }
        }
        // IDLE -> plain search UI, no auto-fetch (handled by the screen
        // from `status`).
      } else {
        String errorMsg = AppStrings.failedToRetrieveParkingStatus.tr;
        try {
          final decoded = jsonDecode(response.body);
          final map = _asMap(decoded);
          if (map?['message'] != null) {
            errorMsg = map!['message'].toString();
          }
        } catch (_) {}
        _showMessage(errorMsg, isError: true);
      }
    } catch (e) {
      _showMessage(
        AppStrings.failedToConnectToParkingService.tr.replaceFirst(
          '@error',
          e.toString(),
        ),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNearbyData(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      _logger.w('fetchNearbyData SKIPPED: lat/lng is null');
      return;
    }
    isLoading.value = true;

    _logger.i(
      '=== fetchNearbyData START ===\n'
      'lat=$lat, lng=$lng, '
      'handoffRadius=${selectedRadiusMeter.value}m, '
      'parkingAreaRadius=${_parkingAreaRadiusMeters}m',
    );

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

      print(
        "GET_NEARBY_HANDOFFS_RESPONSE: status=${handoffsResponse.statusCode}, body=${handoffsResponse.body}",
      );
      print(
        "GET_NEARBY_PARKING_AREAS_RESPONSE: status=${areasResponse.statusCode}, body=${areasResponse.body}",
      );

      _logger.d(
        'GET /handoffs/nearby -> status: ${handoffsResponse.statusCode}\n'
        'body: ${handoffsResponse.body}',
      );
      _logger.d(
        'GET /parking-areas/nearby -> status: ${areasResponse.statusCode}\n'
        'body: ${areasResponse.body}',
      );

      if (handoffsResponse.statusCode == 200) {
        handoffList.value = jsonDecode(handoffsResponse.body) as List<dynamic>;
      } else {
        _showMessage(
          AppStrings.failedToLoadNearbyHandoffSpots.tr,
          isError: true,
        );
      }

      if (areasResponse.statusCode == 200) {
        parkingAreaList.value = jsonDecode(areasResponse.body) as List<dynamic>;
      } else {
        _showMessage(
          AppStrings.failedToLoadNearbyParkingAreas.tr,
          isError: true,
        );
      }

      _logger.d(
        'Parsed -> handoffList: ${handoffList.length} items, '
        'parkingAreaList: ${parkingAreaList.length} items',
      );

      await _buildMarkersAndPolygons();

      // Settle the camera at a fixed close zoom centered on the user's
      // location so the map opens already zoomed-in (matching the manual
      // zoom-in look) instead of fitting every far-away parking area.
      if (mapController != null && gpsPosition.value != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(gpsPosition.value!, _initialSpotsZoom),
        );
      }

      _logger.i(
        '=== fetchNearbyData END -> markers: ${markers.length}, '
        'polygons: ${polygons.length}, circles: ${circles.length} ===',
      );
    } catch (e, st) {
      _logger.e('fetchNearbyData ERROR', error: e, stackTrace: st);
      _showMessage(
        AppStrings.failedToLoadNearbyParkingSpotsWithError.tr.replaceFirst(
          '@error',
          e.toString(),
        ),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLeavingPopupNo() async {
    _logger.i('=== onLeavingPopupNo CLICKED ===');
    status.value = 'SEARCHING';
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
      final response = await _repository.setParkingModeSearching(
        latitude: lat,
        longitude: lng,
      );
      _logger.d(
        'setParkingModeSearching response status: ${response.statusCode}\n'
        'body: ${response.body}',
      );
    } catch (e, st) {
      _logger.e('Error setting searching mode', error: e, stackTrace: st);
    }
    await fetchNearbyData(lat, lng);
  }

  /// "Stop Searching" — sets parking mode back to idle and clears the
  /// in-progress search (markers/pulse), returning the screen to the plain
  /// "Find Parking Spot" view.
  Future<void> stopSearching() async {
    _logger.i('=== stopSearching CLICKED ===');
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;

    try {
      if (lat != null && lng != null) {
        final response = await _repository.setParkingModeIdle(
          latitude: lat,
          longitude: lng,
        );
        _logger.d(
          'setParkingModeIdle (stopSearching) response status: ${response.statusCode}\n'
          'body: ${response.body}',
        );
      }
    } catch (e, st) {
      _logger.e('Error stopping search / setting idle', error: e, stackTrace: st);
    }

    _resetSearchState();
  }

  Future<void> onLeavingPopupYes() async {
    await getUserLocation();

    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;

    if (lat == null || lng == null) {
      _showMessage(AppStrings.locationNotActiveOrAvailable.tr, isError: true);
      return;
    }

    _showExitLoadingDialog();
    bool succeeded = false;

    try {
      _logger.i(
        '=== YES CLICK -> 2 API CALLS ===\n'
        '1. POST /park-relay/handoffs\n'
        '2. POST /park-relay/parking-mode/idle\n'
        'body: {"latitude": $lat, "longitude": $lng}',
      );

      // Call 1: Create Handoff
      final responseHandoff = await _repository.createHandoff(
        latitude: lat,
        longitude: lng,
      );

      debugPrint('Handoffs Response Status: ${responseHandoff.statusCode}');

      debugPrint('Handoffs Response Body: ${responseHandoff.body}');

      _logger.d(
        'createHandoff status: ${responseHandoff.statusCode}\n'
        'body: ${responseHandoff.body}',
      );

      final handoffSuccess =
          responseHandoff.statusCode == 200 ||
          responseHandoff.statusCode == 201;

      // Handle backend error directly
      if (!handoffSuccess) {
        try {
          final responseData = jsonDecode(responseHandoff.body);

          final backendMessage = responseData['message']?.toString();

          if (backendMessage != null && backendMessage.isNotEmpty) {
            _showMessage(backendMessage, isError: true);
          }
        } catch (e) {
          debugPrint('Failed to parse handoff error response: $e');
        }

        return;
      }

      // Call 2: Set Parking Mode Idle
      final responseIdle = await _repository.setParkingModeIdle(
        latitude: lat,
        longitude: lng,
      );

      debugPrint('Idle Response Status: ${responseIdle.statusCode}');

      debugPrint('Idle Response Body: ${responseIdle.body}');

      _logger.d(
        'setParkingModeIdle status: ${responseIdle.statusCode}\n'
        'body: ${responseIdle.body}',
      );

      final idleSuccess =
          responseIdle.statusCode == 200 || responseIdle.statusCode == 201;

      // Handle Idle API error
      if (!idleSuccess) {
        try {
          final responseData = jsonDecode(responseIdle.body);

          final backendMessage = responseData['message']?.toString();

          if (backendMessage != null && backendMessage.isNotEmpty) {
            _showMessage(backendMessage, isError: true);
          }
        } catch (e) {
          debugPrint('Failed to parse idle error response: $e');
        }

        return;
      }

      // Both APIs successful
      _showMessage(
        AppStrings.parkingSpotHandoffReportedSuccessfully.tr,
        isError: false,
      );

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
        );
      }

      // Session ended -> back to the plain "not parked" search view.
      _resetSearchState();
      succeeded = true;
    } catch (e) {
      _showMessage(
        AppStrings.networkErrorReportingSpotHandoffWithError.tr.replaceFirst(
          '@error',
          e.toString(),
        ),
        isError: true,
      );
    } finally {
      _closeExitLoadingDialog();
    }

    // Rating dialog only opens once the loader is fully closed and the
    // exit actually succeeded — never stacked on top of the loader dialog.
    if (succeeded) {
      _showRatingDialog();
    }
  }

  void _showExitLoadingDialog() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: ResponsiveHelper.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(20),
              ),
            ),
            child: SizedBox(
              width: ResponsiveHelper.width(36),
              height: ResponsiveHelper.width(36),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF185FA5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _closeExitLoadingDialog() {
    final ctx = _dialogContext;
    if (ctx == null) return;
    if (Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
  }

  // ── Post-exit parking experience rating — UI only for now, no submit
  //    API exists yet, so Skip/Submit both just dismiss the dialog. ──
  String _ratingLabel(double rating) {
    if (rating <= 0) return '';
    if (rating <= 1) return AppStrings.ratingPoor.tr;
    if (rating <= 2) return AppStrings.ratingFair.tr;
    if (rating <= 3) return AppStrings.ratingGood.tr;
    if (rating <= 4) return AppStrings.ratingGreat.tr;
    return AppStrings.ratingExcellent.tr;
  }

  void _showRatingDialog() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    double rating = 0;

    showDialog(
      context: ctx,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(24),
          ),
          child: Container(
            padding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AssetsPath.ratingIcon,
                  width: ResponsiveHelper.iconSize(64),
                  height: ResponsiveHelper.iconSize(64),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                Text(
                  'How was your parking experience?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(17),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final filled = rating >= starValue;
                    return GestureDetector(
                      onTap: () => setState(() {
                        rating = rating == starValue.toDouble()
                            ? 0
                            : starValue.toDouble();
                      }),
                      child: Padding(
                        padding: ResponsiveHelper.symmetric(horizontal: 2),
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: filled
                              ? Colors.amber
                              : Colors.black.withValues(alpha: 0.25),
                          size: ResponsiveHelper.iconSize(36),
                        ),
                      ),
                    );
                  }),
                ),
                if (rating > 0) ...[
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  Container(
                    padding: ResponsiveHelper.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF185FA5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(20),
                      ),
                    ),
                    child: Text(
                      _ratingLabel(rating),
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF185FA5),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveHelper.spacing(22)),
                Row(
                  children: [
                    Expanded(
                      child: CustomGradientButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        label: AppStrings.skip.tr,
                        backgroundColor: AppColors.blueShadeConBg,
                        shadowColor: Colors.transparent,
                        textColor: AppColors.black,
                        borderColor: AppColors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(14)),
                    Expanded(
                      child: CustomGradientButton(
                        onPressed: rating < 1
                            ? null
                            : () {
                                Navigator.of(dialogContext).pop();
                                // No rating API yet — just acknowledge for now.
                                _showMessage(
                                  AppStrings.ratingSubmitted.tr,
                                  isError: false,
                                );
                              },
                        label: AppStrings.submitRating.tr,
                        keepGradientWhenDisabled: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buildMarkersAndPolygons() async {
    final Set<Marker> newMarkers = {};
    final Set<Polygon> newPolygons = {};
    final Set<Polyline> newPolylines = {};
    final Set<Circle> newCircles = {};
    final now = DateTime.now();

    final parkingPinIcon = await MapMarkerIcons.parkingPin();

    bool needRefresh = false;

    // Saved parking location marker
    if (savedParkingLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('saved_car_location'),
          position: savedParkingLocation.value!,
          icon: parkingPinIcon,
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
      final handoffStatus = handoff['status']?.toString().toUpperCase() ?? '';
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
          icon: parkingPinIcon,
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
        _logger.w(
          'parkingArea[$idx] SKIPPED: not a valid map -> ${parkingAreaList[idx]}',
        );
        continue;
      }

      final areaId = area['id']?.toString() ?? 'area_$idx';
      final polyPoints = area['polygon'];
      final points = _parsePolygonPoints(polyPoints);

      _logger.d(
        'parkingArea[$idx] id=$areaId -> raw polygon: $polyPoints '
        '-> parsed points: ${points.length}',
      );

      if (points.length >= 3) {
        newPolygons.add(
          Polygon(
            polygonId: PolygonId(areaId),
            points: points,
            strokeWidth: ResponsiveHelper.borderWidth(3).round(),
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
            width: ResponsiveHelper.borderWidth(3).round(),
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }

      final centerLat = _toDouble(area['centerLat']);
      final centerLng = _toDouble(area['centerLng']);
      if (centerLat != null && centerLng != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('area_marker_$areaId'),
            position: LatLng(centerLat, centerLng),
            icon: parkingPinIcon,
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
    final now = DateTime.now();
    var needRefresh = false;

    for (final rawHandoff in handoffList) {
      final handoff = _asMap(rawHandoff);
      if (handoff == null) continue;

      final lat = _toDouble(handoff['latitude']);
      final lng = _toDouble(handoff['longitude']);
      if (lat == null || lng == null) continue;

      final id = handoff['id']?.toString() ?? '';
      final handoffStatus = handoff['status']?.toString().toUpperCase() ?? '';
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
      }
    }

    circles
      ..clear()
      ..addAll(newCircles);
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
      fillColor: Colors.red.withValues(alpha: _blinkToggle.value ? 0.30 : 0.12),
      strokeColor: Colors.red.withValues(alpha: 0.7),
      strokeWidth: ResponsiveHelper.borderWidth(2).round(),
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
      _showMessage(AppStrings.parkModeActive.tr, isError: false);
      final lat = gpsPosition.value?.latitude;
      final lng = gpsPosition.value?.longitude;
      if (lat != null && lng != null) {
        fetchNearbyData(lat, lng);
      }
    } else {
      _showMessage(AppStrings.parkModeDeactivated.tr, isError: false);
    }
  }

  void simulateAutoParkDetection() {
    _showMessage(AppStrings.autoParkDetected.tr, isError: false);
    saveCurrentParkingLocation();
  }

  void saveCurrentParkingLocation() {
    final latLng = gpsPosition.value;
    if (latLng == null) {
      _showMessage(AppStrings.gpsLocationNotAvailable.tr, isError: true);
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
    _showMessage(AppStrings.savedParkingSpotRemoved.tr, isError: false);
  }

  void launchSavedParkingRoute() {
    final destination = savedParkingLocation.value;
    if (destination == null) return;

    AppRouter.router.pushNamed(
      RouteName.inAppNavigation,
      extra: {'destination': destination},
    );
  }

  void startParkingTimer(int minutes) {
    _parkingCountdownTimer?.cancel();
    final totalSeconds = minutes * 60;
    _startTimerUpdate(totalSeconds);
    _showMessage(
      AppStrings.paidSpotTimerStartedForMinutes.tr.replaceFirst(
        '@minutes',
        minutes.toString(),
      ),
      isError: false,
    );
  }

  void _startTimerUpdate(int totalSeconds) {
    int remainingSeconds = totalSeconds;

    _parkingCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        isTimerActive.value = false;
        remainingTimeString.value = '';
        savedParkingLocation.value = null; // spot removed after expiration
        _buildMarkersAndPolygons();
        _showMessage(AppStrings.parkingSpotDurationExpired.tr, isError: false);
        return;
      }

      remainingSeconds--;

      final int mins = remainingSeconds ~/ 60;
      final int secs = remainingSeconds % 60;
      remainingTimeString.value =
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

      // Expiring warning alert
      final bool triggerAlert =
          (totalSeconds > 600 && remainingSeconds == 600) ||
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
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(5),
                    margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: ResponsiveHelper.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_parking,
                    size: ResponsiveHelper.iconSize(40),
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),
                Text(
                  AppStrings.theCarHasBeenParked.tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Text(
                  AppStrings.isItAFreeSpotOrIsItAPaidSpot.tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          isPaidSpot.value = false;
                          isTimerActive.value = false;
                          remainingTimeString.value = '';
                          _showMessage(
                            AppStrings.parkingLocationSavedAsFreeSpot.tr,
                            isError: false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          AppStrings.freeSpot.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          isPaidSpot.value = true;
                          showDurationPickerDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF185FA5),
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          AppStrings.paidSpot.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }

  void showDurationPickerDialog() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(5),
                    margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Staying Duration',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Text(
                  AppStrings.forHowLongIsTheUserStayingInThatSpot.tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),
                ...[15, 30, 45, 60, 120].map((mins) {
                  String label = '$mins Minutes';
                  if (mins >= 60) {
                    label = '${mins ~/ 60} Hour${mins == 60 ? "" : "s"}';
                  }
                  return Padding(
                    padding: ResponsiveHelper.symmetric(vertical: 6),
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
                          padding: ResponsiveHelper.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    AppStrings.cancel.tr,
                    style: TextStyle(color: Colors.grey),
                  ),
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
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(5),
                    margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: ResponsiveHelper.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: ResponsiveHelper.iconSize(40),
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),
                Text(
                  AppStrings.parkingExpiring.tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Text(
                  AppStrings
                      .areYouLeavingThePaidSpotYourPaidSpotIsExpiringIn10Minutes
                      .tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _showMessage(
                            AppStrings.acknowledgedKeepingSpotActive.tr,
                            isError: false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          AppStrings.noStaying.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          clearSavedParkingLocation();
                          _showMessage(
                            AppStrings.parkingClearedReleasedSpotStatus.tr,
                            isError: false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: ResponsiveHelper.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          AppStrings.yesLeaving.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
      print(
        "GET_HANDOFF_BY_ID_RESPONSE: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        if (data != null) {
          _showHandoffDialog(data);
          return;
        }
      }
      _showMessage(AppStrings.failedToLoadHandoffDetails.tr, isError: true);
      _showHandoffDialog(handoff); // fallback to cached data
    } catch (e, st) {
      _logger.e('showHandoffDetails ERROR', error: e, stackTrace: st);
      _showMessage(
        AppStrings.networkErrorLoadingHandoffDetails.tr.replaceFirst(
          '@error',
          e.toString(),
        ),
        isError: true,
      );
      _showHandoffDialog(handoff);
    } finally {
      isLoading.value = false;
    }
  }

  void _showHandoffDialog(Map<String, dynamic> handoff) {
    final handoffStatus = handoff['status']?.toString() ?? '';
    final distanceMeters = handoff['distanceMeters'];
    final distanceDisplay = distanceMeters != null
        ? '$distanceMeters m away'
        : '-- m away';
    final lat = _toDouble(handoff['latitude']);
    final lng = _toDouble(handoff['longitude']);

    _showSpotDetailsCardSheet(
      title: 'Handoff Spot',
      subtitle: handoffStatus.isNotEmpty ? handoffStatus : 'Available',
      badgeLabel: 'Standard',
      badgeIcon: Icons.local_parking_rounded,
      badgeColor: AppColors.paidBlue,
      distanceLabel: distanceDisplay,
      ratingLabel: '--',
      leftStatLabel: '-- spots',
      rightStatLabel: 'Free',
      rightStatIcon: Icons.money_off_rounded,
      destination: (lat != null && lng != null) ? LatLng(lat, lng) : null,
    );
  }

  // ── Parking Area Details: card view (title/badge/distance/rating +
  //    spots/price) with a Save Park action. No save API yet — the button
  //    is wired up visually only, ready for real submission later. ──
  void showParkingAreaDetails(Map<String, dynamic> area) {
    final name = area['name']?.toString() ?? '';
    final description = area['description']?.toString() ?? '';
    final parkingCost = area['parkingCost']?.toString().trim() ?? '';
    final isFree = parkingCost.isEmpty ||
        parkingCost == '0' ||
        parkingCost.toUpperCase() == 'FREE';
    final isActive = area['isActive'] == true;
    final distanceMeters = area['distanceMeters'];
    final distanceDisplay = distanceMeters != null
        ? '$distanceMeters m away'
        : '-- m away';
    final lat = _toDouble(area['centerLat']);
    final lng = _toDouble(area['centerLng']);

    _showSpotDetailsCardSheet(
      title: name.isNotEmpty ? name : 'Parking Area',
      subtitle: description.isNotEmpty ? description : 'Parking area',
      badgeLabel: isActive ? 'Standard' : 'Inactive',
      badgeIcon: Icons.local_parking_rounded,
      badgeColor: isActive ? AppColors.paidBlue : Colors.grey,
      distanceLabel: distanceDisplay,
      ratingLabel: '--',
      leftStatLabel: '-- spots',
      rightStatLabel: isFree ? 'Free' : '\$$parkingCost/hr',
      rightStatIcon: isFree ? Icons.money_off_rounded : Icons.monetization_on_outlined,
      destination: (lat != null && lng != null) ? LatLng(lat, lng) : null,
    );
  }

  // ── Shared "found spot" details bottom sheet — same card design used
  //    on the Saved Parkings screen, plus a Save Park action. ──
  void _showSpotDetailsCardSheet({
    required String title,
    required String subtitle,
    required String badgeLabel,
    required IconData badgeIcon,
    required Color badgeColor,
    required String distanceLabel,
    required String ratingLabel,
    required String leftStatLabel,
    required String rightStatLabel,
    IconData rightStatIcon = Icons.monetization_on_outlined,
    LatLng? destination,
  }) {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Padding(
          padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ParkingLocationCard(
                title: title,
                subtitle: subtitle,
                badgeLabel: badgeLabel,
                badgeIcon: badgeIcon,
                badgeColor: badgeColor,
                distanceLabel: distanceLabel,
                ratingLabel: ratingLabel,
                leftStatLabel: leftStatLabel,
                rightStatLabel: rightStatLabel,
                rightStatIcon: rightStatIcon,
              ),
              SizedBox(height: ResponsiveHelper.spacing(14)),
              SizedBox(
                width: double.infinity,
                child: CustomGradientButton(
                  // No save-parking-spot API yet — closes the sheet only,
                  // ready to wire up to a real save call later.
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  label: 'Save Park',
                ),
              ),
              if (destination != null) ...[
                SizedBox(height: ResponsiveHelper.spacing(10)),
                SizedBox(
                  width: double.infinity,
                  child: CustomGradientButton(
                    label: AppStrings.navigate.tr,
                    prefixIcon: const Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      AppRouter.router.pushNamed(
                        RouteName.inAppNavigation,
                        extra: {'destination': destination},
                      );
                    },
                  ),
                ),
              ],
            ],
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          padding: ResponsiveHelper.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.height(5),
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                AppStrings.savedParkingLocation.tr,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              _buildDetailRow(
                AppStrings.confidenceLevel.tr,
                '${confidenceLevel.value}% (High Accuracy)',
              ),
              _buildDetailRow(
                AppStrings.spotType.tr,
                isPaidSpot.value
                    ? AppStrings.paidSpot.tr
                    : AppStrings.freeSpot.tr,
              ),
              if (isTimerActive.value)
                _buildDetailRow(
                  AppStrings.timeRemaining.tr,
                  remainingTimeString.value,
                ),
              SizedBox(height: ResponsiveHelper.spacing(24)),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  launchSavedParkingRoute();
                },
                icon: const Icon(Icons.directions_walk, color: Colors.white),
                label: Text(
                  AppStrings.walkBackToCar.tr,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  padding: ResponsiveHelper.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(10)),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  clearSavedParkingLocation();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  AppStrings.removeSpot.tr,
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.red,
                    width: ResponsiveHelper.borderWidth(1),
                  ),
                  padding: ResponsiveHelper.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
            ],
          ),
        );
      },
    );
  }

  void showDetailsDialog(Map<String, dynamic> data, String title) {
    _logger.i(
      '=== showDetailsDialog: title="$title" ===\n'
      'data: ${jsonEncode(data)}',
    );
    final ctx = _dialogContext;

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
      builder: (dialogContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(5),
                    margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
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
                        final valStr = _formatFieldValue(
                          entry.key,
                          entry.value,
                        );
                        if (valStr.isEmpty) return const SizedBox.shrink();

                        if (entry.key == 'googleMapsLink') {
                          return Padding(
                            padding: ResponsiveHelper.symmetric(vertical: 8),
                            child: ElevatedButton.icon(
                              onPressed: () => _launchURL(valStr),
                              icon: const Icon(
                                Icons.directions,
                                color: Colors.white,
                              ),
                              label: Text(
                                AppStrings.navigate.tr,
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.borderRadius(12),
                                  ),
                                ),
                                padding: ResponsiveHelper.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          );
                        }

                        return _buildDetailRow(displayKey, valStr);
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    AppStrings.close.tr,
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
      padding: ResponsiveHelper.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.spacing(8)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
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
    return formatted
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
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
