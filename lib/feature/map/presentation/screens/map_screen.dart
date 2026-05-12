import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/presentation/widgets/drop_pin_button.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_fab.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  /// Last camera target (map center). Updated from GPS once, then from `onCameraIdle` only (no per-frame rebuild).
  LatLng _mapCenter = MapScreen.kInitialMapTarget;

  /// Device GPS from Geolocator — used for blue dot alignment & “my location” FAB.
  LatLng? _gpsPosition;

  bool _isLocating = true;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;

  @override
  void initState() {
    super.initState();
    _parkingCtrl = Get.put(ParkingReportController());
    mapDebug('screen init → fetch parking + resolve GPS');
    _getUserLocation();
    _parkingCtrl.fetchParkingReport();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
      'lat=${_mapCenter.latitude.toStringAsFixed(6)} lng=${_mapCenter.longitude.toStringAsFixed(6)})',
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
          if (success) _dropPinOnMap();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _dropPinOnMap() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('parking_pin'),
          position: _mapCenter,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'parking_pin'.tr.isNotEmpty ? 'parking_pin'.tr : 'Parking Pin',
          ),
        ),
      );
    });
    mapDebug('dropped local parking pin at map center');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingCtrl.mapController.value = controller;
    mapDebug('GoogleMap created');

    if (!_isLocating && _gpsPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_gpsPosition!, 15),
      );
      mapDebug('onMapCreated: camera synced to existing GPS');
    } else if (!_isLocating) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_mapCenter, 15),
      );
    }
  }

  void _recenterOnUser() {
    final target = _gpsPosition ?? _mapCenter;
    mapDebug(
      'FAB my location → ${ _gpsPosition != null ? "GPS" : "last map center" } '
      'lat=${target.latitude.toStringAsFixed(6)} lng=${target.longitude.toStringAsFixed(6)}',
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              key: const ValueKey<Object>('platechat_google_map'),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: MapScreen.kInitialMapTarget,
                zoom: 14,
              ),
              markers: {
                ..._markers,
                ..._parkingCtrl.markers.toSet(),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onCameraMove: (pos) {
                _mapCenter = pos.target;
              },
            ),
          ),
          if (_isLocating) const LocatingBanner(),
          Obx(
            () => _parkingCtrl.isLoadingShowDetails.value
                ? const FetchingParkingBanner()
                : const SizedBox.shrink(),
          ),
          Positioned(
            right: ResponsiveHelper.padding(16),
            bottom: ResponsiveHelper.padding(168),
            child: MapFab(
              icon: Icons.warning_amber_rounded,
              color: AppColors.red,
              iconColor: AppColors.white,
              onTap: () => context.pushNamed(RouteName.usefulMemberScreen),
            ),
          ),
          Positioned(
            right: ResponsiveHelper.padding(16),
            bottom: ResponsiveHelper.padding(104),
            child: MapFab(
              icon: Icons.my_location_rounded,
              color: Colors.white,
              iconColor: const Color(0xFF3D72E8),
              onTap: _recenterOnUser,
            ),
          ),
          Positioned(
            left: ResponsiveHelper.padding(24),
            right: ResponsiveHelper.padding(24),
            bottom: ResponsiveHelper.padding(32),
            child: DropPinButton(onTap: _toggleParkingPin),
          ),
        ],
      ),
    );
  }
}
