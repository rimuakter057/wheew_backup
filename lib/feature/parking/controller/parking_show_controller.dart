import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/map/utils/marker_icon_loader.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/parking_confirmation_overlay.dart';
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

  /// Active spot card data floating inline above the bottom navigation bar.
  final Rxn<SpotDetailsCardData> activeSpotDetailsCard = Rxn<SpotDetailsCardData>();

  void clearSpotDetailsCard() {
    activeSpotDetailsCard.value = null;
  }

  // -- SavePark, ParkMode, and Parktime States ----------------------
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

  // Captured opportunistically from /parking-mode/me when status is PARKED,
  // if the backend includes it (spotId/parkingAreaId/areaId). No "current
  // session" endpoint exists yet to fetch this directly, so it stays null
  // until the backend response actually carries one — used as the
  // handoff's spotId on exit and as the ratings endpoint's parkingAreaId.
  final Rxn<String> currentParkingAreaId = Rxn<String>();
  final RxString parkedLocationName = ''.obs;
  final RxString parkedSpotCode = ''.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polygon> polygons = <Polygon>{}.obs;

  bool _isRefreshing = false;

  GoogleMapController? mapController;

  @override
  void onClose() {
    _parkingCountdownTimer?.cancel();
    super.onClose();
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
    currentParkingAreaId.value = null;
    clearSpotDetailsCard();
    if (setIdleStatus) {
      status.value = 'IDLE';
    } else {
      status.value = '';
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

      // timeLimit guards against a hung GPS fetch (seen after returning to
      // this tab from another screen) stalling checkParkingModeMe() forever
      // — without it, a SEARCHING session that can't get a quick fix never
      // reaches fetchNearbyHandoffsOnly or re-asserts `status`, so the
      // screen looks stuck instead of falling back to the last known /
      // approx position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
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
    print("CHECK_PARKING_MODE_ME_CALLED (about to GET /parking-mode/me)");
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

        currentParkingAreaId.value = modeStatus == 'PARKED'
            ? (data?['spotId'] ?? data?['parkingAreaId'] ?? data?['areaId'])
                ?.toString()
            : null;

        if (modeStatus == 'PARKED') {
          // Fetch real active saved parking session details from /park-relay/saved-parking/me
          await fetchSavedParkingMe();
        }

        print("CHECK_PARKING_MODE_ME_RESOLVED_STATUS: $modeStatus");

        // getUserLocation() may fail/timeout (permissions, hung GPS fix,
        // etc.) — that's fine, gpsPosition already holds at least the
        // approx default set by initializeFlow(), so it's never null here.
        // The nearby-data GET below must fire unconditionally once we know
        // the mode, the same way for SEARCHING as it already does for IDLE.
        await getUserLocation();
        final lat = gpsPosition.value?.latitude ?? kApproxDefaultLocation.latitude;
        final lng = gpsPosition.value?.longitude ?? kApproxDefaultLocation.longitude;

        if (modeStatus == 'IDLE') {
          // IDLE -> same nearby parking areas the map (home tab) shows,
          // while the "Find Parking Spot" button is visible. Single GET,
          // no handoffs call (that's only for SEARCHING).
          print("CHECK_PARKING_MODE_ME: fetching nearby parking areas (IDLE)");
          await fetchNearbyParkingAreasOnly(lat, lng);
          showLocationPulse.value = false;
        } else if (modeStatus == 'SEARCHING') {
          // SEARCHING -> fetch both nearby handoffs AND parking areas (same as IDLE/PARKED)
          print("CHECK_PARKING_MODE_ME: fetching nearby data (SEARCHING)");
          await fetchNearbyData(lat, lng);
          showLocationPulse.value = true;
        } else if (modeStatus == 'PARKED') {
          // PARKED still needs the real location + nearby markers loaded so
          // the map behind the "You're Parked" card isn't empty — it just
          // skips the search-mode pulse/search-bar UI (handled by the
          // screen from `status`).
          print("CHECK_PARKING_MODE_ME: fetching nearby data (PARKED)");
          await fetchNearbyData(lat, lng);
          // PARKED — make sure a stale pulse from a previous SEARCHING
          // session doesn't keep the screen blinking now.
          showLocationPulse.value = false;
        }

        // Only reveal the resolved status — and therefore the matching
        // button/card — once any loading it triggered above has fully
        // finished. Setting this earlier let the Find Parking Spot button
        // (or the parked card) flash in while location/nearby-data was
        // still loading underneath it.
        status.value = modeStatus;
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

  /// Calls GET /park-relay/saved-parking/me to parse real active parked session details:
  /// parkingArea['name'], parkingArea['description'], note, spotId, etc.
  Future<void> fetchSavedParkingMe() async {
    try {
      final response = await _repository.getSavedParkingMe();
      _logger.d('fetchSavedParkingMe status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        if (data != null) {
          final parkingArea = _asMap(data['parkingArea']);
          final String name = parkingArea?['name']?.toString() ??
              data['areaName']?.toString() ??
              data['locationName']?.toString() ??
              data['name']?.toString() ??
              '';

          final String desc = parkingArea?['description']?.toString() ?? '';
          final String note = data['note']?.toString() ??
              data['spotCode']?.toString() ??
              data['spotNumber']?.toString() ??
              '';

          String combinedSpot = '';
          if (desc.isNotEmpty && note.isNotEmpty) {
            combinedSpot = '$desc • $note';
          } else if (desc.isNotEmpty) {
            combinedSpot = desc;
          } else if (note.isNotEmpty) {
            combinedSpot = note;
          }

          if (name.isNotEmpty) {
            parkedLocationName.value = name;
          }
          if (combinedSpot.isNotEmpty) {
            parkedSpotCode.value = combinedSpot;
          }

          final String? resolvedAreaId = (parkingArea?['id'] ?? data['spotId'] ?? data['parkingAreaId'])?.toString();
          if (resolvedAreaId != null && resolvedAreaId.isNotEmpty) {
            currentParkingAreaId.value = resolvedAreaId;
          }
        }
      }
    } catch (e) {
      _logger.e('Error fetching saved parking me', error: e);
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
        parkingAreaList.value = _extractAreasList(areasResponse.body);
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

  // /park-relay/parking-areas/search returns {"areas": [...], "total": ...}
  // (not a bare list) — unwrap it, same as the map (home tab) does.
  List<dynamic> _extractAreasList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['areas'];
      if (nested is List) return nested;
      return const [];
    }
    if (decoded is List) return decoded;
    return const [];
  }

  // IDLE -> nearby parking areas only, same endpoint/data the map (home
  // tab) shows. Single GET, no handoffs call.
  Future<void> fetchNearbyParkingAreasOnly(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      _logger.w('fetchNearbyParkingAreasOnly SKIPPED: lat/lng is null');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _repository.getNearbyParkingAreas(
        latitude: lat,
        longitude: lng,
        radiusMeters: _parkingAreaRadiusMeters,
      );
      _logger.d(
        'GET /parking-areas/search -> status: ${response.statusCode}\n'
        'body: ${response.body}',
      );
      if (response.statusCode == 200) {
        parkingAreaList.value = _extractAreasList(response.body);
      } else {
        _showMessage(AppStrings.failedToLoadNearbyParkingAreas.tr, isError: true);
      }
      await _buildMarkersAndPolygons();
      if (mapController != null && gpsPosition.value != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(gpsPosition.value!, _initialSpotsZoom),
        );
      }
    } catch (e, st) {
      _logger.e('fetchNearbyParkingAreasOnly ERROR', error: e, stackTrace: st);
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

  // SEARCHING -> nearby handoffs only — just the 1 API call.
  Future<void> fetchNearbyHandoffsOnly(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      _logger.w('fetchNearbyHandoffsOnly SKIPPED: lat/lng is null');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _repository.getNearbyHandoffs(
        latitude: lat,
        longitude: lng,
        radiusMeters: selectedRadiusMeter.value,
      );
      _logger.d(
        'GET /handoffs/nearby -> status: ${response.statusCode}\n'
        'body: ${response.body}',
      );
      if (response.statusCode == 200) {
        handoffList.value = jsonDecode(response.body) as List<dynamic>;
      } else {
        _showMessage(AppStrings.failedToLoadNearbyHandoffSpots.tr, isError: true);
      }
      await _buildMarkersAndPolygons();
      if (mapController != null && gpsPosition.value != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(gpsPosition.value!, _initialSpotsZoom),
        );
      }
    } catch (e, st) {
      _logger.e('fetchNearbyHandoffsOnly ERROR', error: e, stackTrace: st);
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

  // Guards Find Parking Spot / Stop Searching against rapid repeated taps —
  // without this, tapping again before the previous transition finishes
  // fired overlapping API calls and made the UI flicker between states.
  final RxBool isTransitioningSearch = false.obs;

  Future<void> onLeavingPopupNo() async {
    if (isTransitioningSearch.value) return;
    isTransitioningSearch.value = true;
    try {
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

      // Parking area polygons stay visible across every status (IDLE,
      // SEARCHING, PARKED) — not cleared here, so they carry over as-is
      // into SEARCHING alongside the newly fetched handoffs below.

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
      // SEARCHING -> fetch both nearby handoffs AND nearby parking areas (polygon search).
      await fetchNearbyData(lat, lng);
    } finally {
      isTransitioningSearch.value = false;
    }
  }

  /// "Stop Searching" — sets parking mode back to idle and clears the
  /// in-progress search (markers/pulse), returning the screen to the plain
  /// "Find Parking Spot" view.
  Future<void> stopSearching() async {
    if (isTransitioningSearch.value) return;
    isTransitioningSearch.value = true;
    try {
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
    // Back to IDLE -> same auto-fetch checkParkingModeMe() does for a
    // fresh IDLE resolve, so the map isn't left blank after Stop Searching.
    await fetchNearbyParkingAreasOnly(lat, lng);
    } finally {
      isTransitioningSearch.value = false;
    }
  }

  // Triggered by tapping the search pill on ParkingMapScreen's top bar.
  void openRadiusFilterSheet() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    // -- enter search mode: show the floating button --
    showFindParkingButton.value = true;

    RadiusFilterSheet.show(
      ctx,
      initialRadiusMeter: selectedRadiusMeter.value,
      onApply: (radius) {
        selectedRadiusMeter.value = radius;
        final lat = gpsPosition.value?.latitude;
        final lng = gpsPosition.value?.longitude;
        if (lat != null && lng != null) {
          // Radius filter only affects the handoffs radius — parking areas
          // use a fixed radius.
          fetchNearbyHandoffsOnly(lat, lng);
        }
        // -- sheet applied: hide the floating button --
        showFindParkingButton.value = false;
      },
    ).then((_) {
      // -- sheet dismissed (swipe/tap outside): hide button --
      showFindParkingButton.value = false;
    });
  }

  // Triggered by the "Exit Parking" button on ParkingMapScreen. Yes reuses
  // the existing "I'm leaving this spot" logic unchanged (createHandoff +
  // set idle). No just closes the dialog.
  void showExitParkingConfirmation() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    ParkingConfirmationDialog.show(
      ctx,
      onYes: onLeavingPopupYes,
      onNo: () {},
    );
  }

  Future<void> onLeavingPopupYes() async {
    // Must be a fresh fix taken right now, not whatever gpsPosition already
    // held — if the fetch fails/times out, don't silently fall back to a
    // stale position for the handoff call.
    final gotFreshLocation = await getUserLocation();

    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;

    if (!gotFreshLocation || lat == null || lng == null) {
      _showMessage(AppStrings.locationNotActiveOrAvailable.tr, isError: true);
      return;
    }

    _showExitLoadingDialog();

    try {
      _logger.i(
        '=== YES CLICK -> 1 API CALL ===\n'
        '1. POST /park-relay/handoffs (spotId: ${currentParkingAreaId.value})\n'
        'body: {"latitude": $lat, "longitude": $lng}',
      );

      // Create Handoff — the backend now handles the idle transition as
      // part of this call, so /park-relay/parking-mode/idle is no longer
      // called manually here afterward.
      final responseHandoff = await _repository.createHandoff(
        latitude: lat,
        longitude: lng,
        spotId: currentParkingAreaId.value,
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
      // Back to IDLE -> same auto-fetch checkParkingModeMe() does for a
      // fresh IDLE resolve, so the map isn't left blank after exiting.
      await fetchNearbyParkingAreasOnly(lat, lng);
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
  }

  void _showExitLoadingDialog() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: ResponsiveHelper.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
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

  // Post-exit rating feature removed — Exit Parking now just runs the
  // handoff/idle logic above with no rating dialog afterward.

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

      if (handoffStatus == 'AVAILABLE' && expiresAtStr.isNotEmpty) {
        try {
          final expiryTime = DateTime.parse(expiresAtStr).toLocal();
          if (!expiryTime.isAfter(now)) {
            needRefresh = true;
          }
        } catch (_) {}
      }

      final handoffIcon = await MapMarkerIcons.iconForData(handoff, size: 56);
      newMarkers.add(
        Marker(
          markerId: MarkerId('handoff_$id'),
          position: LatLng(lat, lng),
          icon: handoffIcon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow.noText,
          onTap: () => showHandoffDetails(handoff),
        ),
      );
    }

    // Parking areas — a single pin at the area's center point (no polygon
    // outline). Icon priority: Disabled > Electric > Paid > Free —
    // parkingAreaTypes decides it, falling back to parkingCost only when
    // parkingAreaTypes has neither DISABLED_FACILITY nor ELECTRIC_CHARGING
    // (including when it's empty). See MapMarkerIcons.areaPinForData.
    for (var idx = 0; idx < parkingAreaList.length; idx++) {
      final area = _asMap(parkingAreaList[idx]);
      if (area == null) {
        _logger.w(
          'parkingArea[$idx] SKIPPED: not a valid map -> ${parkingAreaList[idx]}',
        );
        continue;
      }

      final areaId = area['id']?.toString() ?? 'area_$idx';
      final lat = _toDouble(area['centerLat']);
      final lng = _toDouble(area['centerLng']);

      if (lat == null || lng == null) {
        _logger.w(
          'parkingArea[$idx] id=$areaId SKIPPED: missing centerLat/centerLng',
        );
        continue;
      }

      final areaPinIcon = await MapMarkerIcons.areaPinForData(area);
      newMarkers.add(
        Marker(
          markerId: MarkerId('area_$areaId'),
          position: LatLng(lat, lng),
          icon: areaPinIcon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow.noText,
          onTap: () => showParkingAreaDetails(area),
        ),
      );
    }

    _applyOverlaySets(
      newMarkers: newMarkers,
      newPolygons: newPolygons,
      newPolylines: newPolylines,
      newCircles: newCircles,
    );

    _logger.i(
      '=== _buildMarkersAndPolygons END -> markers: ${newMarkers.length}, '
      'polygons: ${newPolygons.length}, circles: ${newCircles.length} ===',
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

  void _refreshExpiredHandoffs() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    final lat = gpsPosition.value?.latitude;
    final lng = gpsPosition.value?.longitude;
    if (lat != null && lng != null) {
      // SEARCHING -> still just the 1 API call (nearby handoffs), even on
      // this auto-refresh triggered by an expired blinking handoff.
      await fetchNearbyHandoffsOnly(lat, lng);
    }
    _isRefreshing = false;
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

  // -- SavePark, ParkMode, and Parktime Operations ------------------
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
      backgroundColor: AppColors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
                      color: AppColors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: ResponsiveHelper.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_parking,
                    size: ResponsiveHelper.iconSize(40),
                    color: AppColors.blue,
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
                    color: AppColors.grey,
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
                            color: AppColors.white,
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
      backgroundColor: AppColors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
                      color: AppColors.grey[350],
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
                    color: AppColors.grey,
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
                          backgroundColor: AppColors.greyShade100,
                          foregroundColor: AppColors.black87,
                          elevation: 0,
                          padding: ResponsiveHelper.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(10),
                            ),
                            side: BorderSide(color: AppColors.greyShade300),
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
                    style: TextStyle(color: AppColors.grey),
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
      backgroundColor: AppColors.transparent,
      builder: (dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
                      color: AppColors.grey[350],
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: ResponsiveHelper.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: ResponsiveHelper.iconSize(40),
                    color: AppColors.amber,
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
                    color: AppColors.grey,
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
                          backgroundColor: AppColors.amber.shade700,
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
                            color: AppColors.white,
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

  // -- Handoff Details Dialog: Status, Expires At, Navigate only --
  Future<void> showHandoffDetails(Map<String, dynamic> handoff) async {
    final id = handoff['id']?.toString();
    if (id == null || id.isEmpty) {
      _showHandoffDialog(handoff);
      return;
    }

    isLoading.value = true;
    try {
      _logger.i('=== showHandoffDetails: fetching /handoffs/$id ===');
      print("GET_HANDOFF_BY_ID_REQUESTED_ID: $id");
      final response = await _repository.getHandoffById(handoffId: id);
      print(
        "GET_HANDOFF_BY_ID_RESPONSE: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 200) {
        final data = _asMap(jsonDecode(response.body));
        if (data != null) {
          // Compare against the requested id — this is also the id
          // _acceptAndParkHandoff will use for Save Park.
          print(
            "GET_HANDOFF_BY_ID_RETURNED_ID: ${data['id']} "
            "(matchesRequested=${data['id']?.toString() == id})",
          );
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
    final area = _asMap(handoff['parkingArea']);

    final name = area?['name']?.toString() ?? '';
    final description = area?['description']?.toString() ?? '';
    final parkingCost = area?['parkingCost']?.toString().trim() ?? '';
    final isFree = parkingCost.isEmpty ||
        parkingCost == '0' ||
        parkingCost.toUpperCase() == 'FREE';

    final distanceDisplay = _formatDistance(handoff['distanceMeters']);
    final lat = _toDouble(handoff['latitude']);
    final lng = _toDouble(handoff['longitude']);
    final handoffId = handoff['id']?.toString();

    // rating == null -> '0.0'; reviewCount, when > 0, appended as "4.5 (2)".
    final ratingRaw = area?['rating'];
    final ratingText = ratingRaw == null
        ? '0.0'
        : (ratingRaw is num ? ratingRaw.toStringAsFixed(1) : ratingRaw.toString());
    final reviewCountRaw = area?['reviewCount'];
    final reviewCount = reviewCountRaw is num
        ? reviewCountRaw.toInt()
        : int.tryParse(reviewCountRaw?.toString() ?? '');
    final ratingLabel = (reviewCount != null && reviewCount > 0)
        ? '$ratingText ($reviewCount)'
        : ratingText;

    // totalSpots == null -> 0.
    final totalSpotsRaw = area?['totalSpots'];
    final totalSpots = totalSpotsRaw is num
        ? totalSpotsRaw.toInt()
        : (int.tryParse(totalSpotsRaw?.toString() ?? '') ?? 0);

    // paid + parkingFee present -> show the fee; else fall back to 'Paid'.
    String priceLabel;
    if (isFree) {
      priceLabel = 'Free';
    } else {
      final feeRaw = area?['parkingFee'];
      final feeNum = feeRaw is num ? feeRaw : num.tryParse(feeRaw?.toString() ?? '');
      priceLabel = feeNum != null
          ? '\$${feeNum % 1 == 0 ? feeNum.toInt() : feeNum}'
          : 'Paid';
    }

    final badge = _areaTypeBadge(area);

    _showSpotDetailsCardSheet(
      title: name.isNotEmpty ? name : 'Handoff Spot',
      subtitle: description.isNotEmpty
          ? description
          : (handoffStatus.isNotEmpty ? handoffStatus : 'Available'),
      badgeLabel: badge.label,
      badgeIcon: badge.icon,
      badgeIconAsset: badge.asset,
      badgeColor: badge.color,
      distanceLabel: distanceDisplay,
      ratingLabel: ratingLabel,
      leftStatLabel: '$totalSpots spots',
      rightStatLabel: priceLabel,
      rightStatIcon: isFree ? Icons.money_off_rounded : Icons.monetization_on_outlined,
      isFree: isFree,
      destination: (lat != null && lng != null) ? LatLng(lat, lng) : null,
      // Save (accept-and-park) is only possible while actively searching.
      onSavePark: (status.value == 'SEARCHING' && handoffId != null)
          ? () => _acceptAndParkHandoff(handoffId)
          : null,
    );
  }

  // ── Distance label shared by the handoff and parking-area detail sheets —
  //    the backend occasionally returns distanceMeters in the millions
  //    (bad seed/test data), so convert to km past 1000m to keep it readable
  //    instead of printing a raw absurd meter count. --
  String _formatDistance(dynamic distanceMeters) {
    final meters = distanceMeters is num
        ? distanceMeters.toDouble()
        : double.tryParse(distanceMeters?.toString() ?? '');
    if (meters == null) return '-- m away';
    return meters >= 1000
        ? '${(meters / 1000).toStringAsFixed(1)} km away'
        : '${meters.round()} m away';
  }

  // ── Badge (label/icon/color) derived from parkingArea.parkingAreaTypes —
  //    mirrors the same Electric/Accessible/Standard classification used on
  //    the Saved Parkings list. --
  ({String label, IconData icon, Color color, String? asset}) _areaTypeBadge(
    Map<String, dynamic>? area,
  ) {
    final raw = area?['parkingAreaTypes'];
    final types = raw is List
        ? raw.map((e) => e.toString().toUpperCase()).toList()
        : const <String>[];

    if (types.contains('ELECTRIC_CHARGING')) {
      return (
        label: 'Electric',
        icon: Icons.electric_bolt_rounded,
        color: AppColors.chargingGreen,
        asset: AssetsPath.electricCharging,
      );
    }
    if (types.contains('DISABLED_FACILITY')) {
      return (
        label: 'Disable',
        icon: Icons.accessible_rounded,
        color: AppColors.disableOrange,
        asset: AssetsPath.disabledFacility,
      );
    }
    return (
      label: 'Standard',
      icon: Icons.local_parking_rounded,
      color: AppColors.paidBlue,
      asset: AssetsPath.standardIcon,
    );
  }

  // -- Parking Area Details: card view (title/badge/distance/rating +
  //    spots/price) with a Save Park action. --
  void showParkingAreaDetails(Map<String, dynamic> area) {
    final name = area['name']?.toString() ?? '';
    final description = area['description']?.toString() ?? '';
    final parkingCost = area['parkingCost']?.toString().trim() ?? '';
    final isFree = parkingCost.isEmpty ||
        parkingCost == '0' ||
        parkingCost.toUpperCase() == 'FREE';
    final distanceDisplay = _formatDistance(area['distanceMeters']);
    final lat = _toDouble(area['centerLat']);
    final lng = _toDouble(area['centerLng']);

    // rating == null -> '0.0'; reviewCount, when > 0, appended as "4.0 (1)".
    final ratingRaw = area['rating'];
    final ratingText = ratingRaw == null
        ? '0.0'
        : (ratingRaw is num ? ratingRaw.toStringAsFixed(1) : ratingRaw.toString());
    final reviewCountRaw = area['reviewCount'];
    final reviewCount = reviewCountRaw is num
        ? reviewCountRaw.toInt()
        : int.tryParse(reviewCountRaw?.toString() ?? '');
    final ratingLabel = (reviewCount != null && reviewCount > 0)
        ? '$ratingText ($reviewCount)'
        : ratingText;

    // totalSpots == null -> 0.
    final totalSpotsRaw = area['totalSpots'];
    final totalSpots = totalSpotsRaw is num
        ? totalSpotsRaw.toInt()
        : (int.tryParse(totalSpotsRaw?.toString() ?? '') ?? 0);

    // paid + parkingFee present -> show the fee; else fall back to 'Paid'.
    String priceLabel;
    if (isFree) {
      priceLabel = 'Free';
    } else {
      final feeRaw = area['parkingFee'];
      final feeNum = feeRaw is num ? feeRaw : num.tryParse(feeRaw?.toString() ?? '');
      priceLabel = feeNum != null
          ? '\$${feeNum % 1 == 0 ? feeNum.toInt() : feeNum}'
          : 'Paid';
    }

    final badge = _areaTypeBadge(area);

    _showSpotDetailsCardSheet(
      title: name.isNotEmpty ? name : 'Parking Area',
      subtitle: description.isNotEmpty ? description : 'Parking area',
      badgeLabel: badge.label,
      badgeIconAsset: badge.asset,
      badgeIcon: badge.icon,
      badgeColor: badge.color,
      distanceLabel: distanceDisplay,
      ratingLabel: ratingLabel,
      leftStatLabel: '$totalSpots spots',
      rightStatLabel: priceLabel,
      rightStatIcon: isFree ? Icons.money_off_rounded : Icons.monetization_on_outlined,
      isFree: isFree,
      destination: (lat != null && lng != null) ? LatLng(lat, lng) : null,
      onSavePark: (status.value != 'PARKED' && lat != null && lng != null)
          ? () => _saveParkingAtArea(area, latitude: lat, longitude: lng)
          : null,
    );
  }

  // Reuses the same /park-relay/saved-parking endpoint the home tab's
  // "Save My Parking" flow already uses — there's no dedicated
  // accept-and-park-style endpoint for parking areas (that one is
  // handoff-specific), so this marks the area's location as parked.
  void _saveParkingAtArea(
    Map<String, dynamic> area, {
    required double latitude,
    required double longitude,
  }) {
    final costRaw = area['parkingCost']?.toString().toUpperCase();
    final parkingType = costRaw == 'PAID' ? 'PAID' : 'FREE';

    if (parkingType == 'PAID') {
      final feeRaw = area['parkingFee'];
      final feeNum = feeRaw is num ? feeRaw : num.tryParse(feeRaw?.toString() ?? '');
      final feeLabel = feeNum != null
          ? '\$${feeNum % 1 == 0 ? feeNum.toInt() : feeNum}'
          : null;

      _showDurationInputDialog(
        feeLabel: feeLabel,
        onConfirm: (durationMin) => _submitSaveParkingAtArea(
          area,
          latitude: latitude,
          longitude: longitude,
          parkingType: parkingType,
          durationMin: durationMin,
        ),
      );
      return;
    }

    _submitSaveParkingAtArea(
      area,
      latitude: latitude,
      longitude: longitude,
      parkingType: parkingType,
    );
  }

  Future<void> _submitSaveParkingAtArea(
    Map<String, dynamic> area, {
    required double latitude,
    required double longitude,
    required String parkingType,
    int? durationMin,
  }) async {
    isLoading.value = true;
    try {
      final response = await _repository.saveMyParking(
        latitude: latitude,
        longitude: longitude,
        parkingType: parkingType,
        spotId: area['id']?.toString(),
        durationMin: durationMin,
      );
      print(
        "SAVE_MY_PARKING_RESPONSE: status=${response.statusCode}, body=${response.body}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        currentParkingAreaId.value = area['id']?.toString();
        // Load the real parked-session name/spot from
        // /park-relay/saved-parking/me before flipping to PARKED, so the
        // "You're Parked" card never has to fall back to placeholder text.
        await fetchSavedParkingMe();
        status.value = 'PARKED';
        showLocationPulse.value = false;
        handoffList.clear();
        parkingAreaList.clear();
        polygons.clear();
        polylines.clear();
        circles.clear();
        markers.removeWhere((m) => m.markerId.value != 'saved_car_location');
        mapOverlayVersion.value++;
        _showMessage('Parking spot saved', isError: false);
      } else {
        String errorMsg = AppStrings.somethingWentWrong.tr;
        try {
          final data = _asMap(jsonDecode(response.body));
          if (data?['message'] != null) errorMsg = data!['message'].toString();
        } catch (_) {}
        _showMessage(errorMsg, isError: true);
      }
    } catch (e, st) {
      _logger.e('_saveParkingAtArea ERROR', error: e, stackTrace: st);
      _showMessage(AppStrings.somethingWentWrong.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Duration prompt for PAID areas — mirrors the home tab's Save My
  //    Parking dialog validation (>=15 min) since this "Save Park" flow
  //    from a parking area's details doesn't have its own duration field. --
  void _showDurationInputDialog({
    required void Function(int durationMin) onConfirm,
    String? feeLabel,
  }) {
    final ctx = _dialogContext;
    if (ctx == null) return;

    final durationController = TextEditingController();
    bool hasError = false;
    String errorText = '';

    showDialog(
      context: ctx,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          backgroundColor: AppColors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(24),
          ),
          child: Container(
            padding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.parkingType.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(17),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (feeLabel != null) ...[
                  SizedBox(height: ResponsiveHelper.spacing(6)),
                  Container(
                    padding: ResponsiveHelper.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF185FA5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(20),
                      ),
                    ),
                    child: Text(
                      'Fee: $feeLabel',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF185FA5),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveHelper.spacing(16)),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  onChanged: (_) {
                    if (hasError) setState(() => hasError = false);
                  },
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.durationMin15Minutes.tr,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    errorText: hasError ? errorText : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: hasError
                          ? BorderSide(
                              color: const Color(0xFFEF4444),
                              width: ResponsiveHelper.borderWidth(1),
                            )
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide(
                        color: hasError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF185FA5),
                        width: ResponsiveHelper.borderWidth(1.4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(22)),
                Row(
                  children: [
                    Expanded(
                      child: CustomGradientButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        label: AppStrings.cancel.tr,
                        backgroundColor: AppColors.blueShadeConBg,
                        shadowColor: AppColors.transparent,
                        textColor: AppColors.black,
                        borderColor: AppColors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(14)),
                    Expanded(
                      child: CustomGradientButton(
                        onPressed: () {
                          final input = durationController.text.trim();
                          final parsed = int.tryParse(input);
                          if (input.isEmpty) {
                            setState(() {
                              hasError = true;
                              errorText = AppStrings.timeIsRequired.tr;
                            });
                            return;
                          }
                          if (parsed == null || parsed <= 0) {
                            setState(() {
                              hasError = true;
                              errorText = AppStrings.enterValidNumber.tr;
                            });
                            return;
                          }
                          if (parsed < 15) {
                            setState(() {
                              hasError = true;
                              errorText = AppStrings.minimum15MinutesRequired.tr;
                            });
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          onConfirm(parsed);
                        },
                        label: AppStrings.confirm.tr,
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

  // ── Shared "found spot" details bottom sheet — same card design used
  //    on the Saved Parkings screen. [onSavePark] is supplied by the
  //    caller so only IDLE (parking areas) and SEARCHING (handoffs) get
  //    a working save action, each wired to the right endpoint. --
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
    required bool isFree,
    String? badgeIconAsset,
    IconData rightStatIcon = Icons.monetization_on_outlined,
    LatLng? destination,
    VoidCallback? onSavePark,
  }) {
    activeSpotDetailsCard.value = SpotDetailsCardData(
      title: title,
      subtitle: subtitle,
      badgeLabel: badgeLabel,
      badgeIcon: badgeIcon,
      badgeColor: badgeColor,
      distanceLabel: distanceLabel,
      ratingLabel: ratingLabel,
      leftStatLabel: leftStatLabel,
      rightStatLabel: rightStatLabel,
      isFree: isFree,
      badgeIconAsset: badgeIconAsset,
      rightStatIcon: rightStatIcon,
      destination: destination,
      onSavePark: onSavePark,
    );
  }

  // ── Handoff accept — POST /park-relay/handoffs/{id}/accept-and-park.
  //    Only ever wired up while status == SEARCHING (see _showHandoffDialog).
  //    Just this 1 API call — status flips to PARKED locally from this
  //    response directly, no follow-up GET /parking-mode/me.



  Future<void> _acceptAndParkHandoff(String handoffId) async {
    print("ACCEPT_AND_PARK_HANDOFF_ID (Save Park tapped): $handoffId");
    isLoading.value = true;
    try {
      final response = await _repository.acceptAndParkHandoff(handoffId: handoffId);
      print(
        "ACCEPT_AND_PARK_RESPONSE: status=${response.statusCode}, body=${response.body}",
      );
      _logger.d(
        'acceptAndParkHandoff status: ${response.statusCode}\n'
        'body: ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _asMap(jsonDecode(response.body));
        // Capture whatever id the backend hands back, for the exit/rating
        // calls later — same fallback chain as checkParkingModeMe.
        currentParkingAreaId.value =
            (data?['spotId'] ?? data?['parkingAreaId'] ?? data?['areaId'])
                ?.toString();

        // Load the real parked-session name/spot from
        // /park-relay/saved-parking/me before flipping to PARKED, so the
        // "You're Parked" card never has to fall back to placeholder text.
        await fetchSavedParkingMe();
        status.value = 'PARKED';
        showLocationPulse.value = false;
        handoffList.clear();
        parkingAreaList.clear();
        polygons.clear();
        polylines.clear();
        circles.clear();
        markers.removeWhere((m) => m.markerId.value != 'saved_car_location');
        mapOverlayVersion.value++;

        _showMessage('Parking spot saved', isError: false);
      } else {
        String errorMsg = AppStrings.somethingWentWrong.tr;
        try {
          final data = _asMap(jsonDecode(response.body));
          if (data?['message'] != null) errorMsg = data!['message'].toString();
        } catch (_) {}
        _showMessage(errorMsg, isError: true);
      }
    } catch (e, st) {
      _logger.e('acceptAndParkHandoff ERROR', error: e, stackTrace: st);
      _showMessage(AppStrings.somethingWentWrong.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Old "Save Park" paid-duration prompt — no longer wired up (parking-area
  // details are read-only now; the handoff flow saves via accept-and-park
  // directly, with no duration step). Left here for reference.
  // ignore: unused_element
  void _showSaveDurationPickerSheet() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    final durationController = TextEditingController();
    bool hasError = false;
    String errorText = '';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.all(24).copyWith(
              bottom: ResponsiveHelper.padding(24) +
                  MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveHelper.width(40),
                    height: ResponsiveHelper.height(5),
                    margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(16)),
                    decoration: BoxDecoration(
                      color: AppColors.grey[350],
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
                  'How long will you park here?',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),

                // -- Custom minutes input --
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (hasError) setState(() => hasError = false);
                  },
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                  decoration: InputDecoration(
                    hintText: 'Enter minutes',
                    suffixText: 'min',
                    errorText: hasError ? errorText : null,
                    filled: true,
                    fillColor: AppColors.greyShade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: ResponsiveHelper.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),

                Text(
                  'Quick select',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyShade600,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Wrap(
                  spacing: ResponsiveHelper.spacing(8),
                  runSpacing: ResponsiveHelper.spacing(8),
                  children: [15, 30, 45, 60, 120].map((mins) {
                    String label = '$mins min';
                    if (mins >= 60) {
                      label = '${mins ~/ 60} hr${mins == 60 ? "" : "s"}';
                    }
                    return GestureDetector(
                      onTap: () => setState(() {
                        durationController.text = mins.toString();
                        hasError = false;
                      }),
                      child: Container(
                        padding: ResponsiveHelper.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyShade100,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(20),
                          ),
                          border: Border.all(color: AppColors.greyShade300),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final minutes =
                          int.tryParse(durationController.text.trim());
                      if (minutes == null || minutes <= 0) {
                        setState(() {
                          hasError = true;
                          errorText = 'Enter a valid duration';
                        });
                        return;
                      }

                      final label = minutes >= 60
                          ? '${minutes ~/ 60} hr${minutes == 60 ? "" : "s"}'
                              '${minutes % 60 == 0 ? "" : " ${minutes % 60} min"}'
                          : '$minutes min';

                      Navigator.of(sheetContext).pop();
                      _showMessage(
                        'Parking spot saved for $label',
                        isError: false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: ResponsiveHelper.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSize(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(
                    AppStrings.cancel.tr,
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSavedSpotDetails() {
    final ctx = _dialogContext;

    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
                    color: AppColors.grey[350],
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
                  color: AppColors.black87,
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
                icon: const Icon(Icons.directions_walk, color: AppColors.white),
                label: Text(
                  AppStrings.walkBackToCar.tr,
                  style: TextStyle(color: AppColors.white),
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
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                label: Text(
                  AppStrings.removeSpot.tr,
                  style: TextStyle(color: AppColors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.red,
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
      backgroundColor: AppColors.transparent,
      builder: (dialogContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
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
                      color: AppColors.grey[350],
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
                    color: AppColors.black87,
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
                                color: AppColors.white,
                              ),
                              label: Text(
                                AppStrings.navigate.tr,
                                style: TextStyle(color: AppColors.white),
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
                      color: AppColors.grey,
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
                color: AppColors.grey[600],
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
                color: AppColors.black87,
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

class SpotDetailsCardData {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData badgeIcon;
  final Color badgeColor;
  final String distanceLabel;
  final String ratingLabel;
  final String leftStatLabel;
  final String rightStatLabel;
  final bool isFree;
  final String? badgeIconAsset;
  final IconData rightStatIcon;
  final LatLng? destination;
  final VoidCallback? onSavePark;

  SpotDetailsCardData({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.badgeColor,
    required this.distanceLabel,
    required this.ratingLabel,
    required this.leftStatLabel,
    required this.rightStatLabel,
    required this.isFree,
    this.badgeIconAsset,
    this.rightStatIcon = Icons.monetization_on_outlined,
    this.destination,
    this.onSavePark,
  });
}



