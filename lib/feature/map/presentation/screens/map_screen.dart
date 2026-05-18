import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/presentation/widgets/drop_pin_button.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  LatLng _mapCenter = MapScreen.kInitialMapTarget;
  LatLng? _gpsPosition;
  bool _isLocating = true;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;

  @override
  void initState() {
    super.initState();
    _parkingCtrl = Get.isRegistered<ParkingReportController>()
        ? Get.find<ParkingReportController>()
        : Get.put(ParkingReportController());
    mapDebug('screen init → resolve GPS and fetch parking');
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();
    final location = _gpsPosition;
    await _parkingCtrl.fetchParkingReport(
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
  }

  Future<void> _getUserLocation() async {
    mapDebug('location: start');
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        mapDebug('location: services disabled → stop');
        setState(() => _isLocating = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        mapDebug('location: permission denied ($permission)');
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      mapDebug(
        'location: GPS ok lat=${position.latitude.toStringAsFixed(6)} '
            'lng=${position.longitude.toStringAsFixed(6)} '
            'accuracy=${position.accuracy.toStringAsFixed(1)}m',
      );

      setState(() {
        _gpsPosition = latLng;
        _mapCenter = latLng;
        _isLocating = false;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
      mapDebug('location: camera animated to GPS');
    } catch (e, st) {
      mapDebug('location: error $e');
      mapDebug('location: stack $st');
      setState(() => _isLocating = false);
    }
  }

  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    mapDebug(
      'parking dialog open (submit will use map center '
          'lat=${_mapCenter.latitude.toStringAsFixed(6)} '
          'lng=${_mapCenter.longitude.toStringAsFixed(6)})',
    );
    _showParkingDialog();
  }

  void _showParkingDialog() {
    _parkingCtrl.reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParkingInfoDialog(
        controller: _parkingCtrl,
        onSubmit: () async {
          Navigator.of(context).pop();
          final success = await _parkingCtrl.submitParkingReport(
            latitude: _mapCenter.latitude,
            longitude: _mapCenter.longitude,
          );
          if (!mounted) return;
          if (success) {
       //
            showCustomSnackBar(
              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
                  : 'map_parking_report_submitted'.tr,
              isError: false,
            );
            await _parkingCtrl.fetchParkingReport(
              latitude: _gpsPosition?.latitude,
              longitude: _gpsPosition?.longitude,
            );
          } else {
            showCustomSnackBar(
              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
                  : 'map_failed_to_submit_parking_report'.tr,
              isError: true,
            );
          }
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }



  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingCtrl.mapController.value = controller;
    mapDebug('GoogleMap created');

    if (_gpsPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_gpsPosition!, 15),
      );
      mapDebug('onMapCreated: camera synced to GPS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _parkingCtrl.clearSelectedReport();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            /// ── Map সবসময় visible — parking থাক বা না থাক ──────────────
            // ── Map / Shimmer ──────────────────────────────────────────────
            if (_isLocating && _gpsPosition == null)
              const MapInitialShimmer()
            else
              Obx(() {
                final markers = {
                  ..._markers,
                  ..._parkingCtrl.markers,  // observable always read, no early return
                };
                return GoogleMap(
                  key: const ValueKey<Object>('platechat_google_map'),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: MapScreen.kInitialMapTarget,
                    zoom: 14,
                  ),
                  markers: markers,
                 // myLocationEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  onTap: (_) => _parkingCtrl.clearSelectedReport(),
                );
              }),

            // ── GPS locating banner (plain bool, Obx নেই) ────────────────
            if (_isLocating) const LocatingBanner(),

            // ── Parking API fetching indicator ────────────────────────────
            Obx(
                  () => _parkingCtrl.isLoadingShowDetails.value
                  ? const FetchingParkingBanner()
                  : const SizedBox.shrink(),
            ),

            /// ── Selected parking marker info card ─────────────────────────
            Obx(() {
              final selected = _parkingCtrl.selectedReport.value;
              if (selected == null) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).padding.top +
                    ResponsiveHelper.padding(92),
                child: ParkingReportDropdown(
                  controller: _parkingCtrl,
                  report: selected,
                  onClose: _parkingCtrl.clearSelectedReport,
                ),
              );
            }),

            // // ── Drop pin FAB ──────────────────────────────────────────────
            Positioned(
              left: ResponsiveHelper.padding(24),
              right: ResponsiveHelper.padding(24),
              bottom: ResponsiveHelper.padding(32),
              child: DropPinButton(onTap: _toggleParkingPin),
            ),
          ],
        ),
      ),
    );
  }
}