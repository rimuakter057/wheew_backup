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

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver{
  GoogleMapController? _mapController;

  LatLng _mapCenter = MapScreen.kInitialMapTarget;
  LatLng? _gpsPosition;
  bool _isLocating = true;
  LatLng? _pickedLocation;        // ম্যাপে ট্যাপ করে পিক করা location
  bool _isPickingLocation = false; // pick mode চালু আছে কিনা

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parkingCtrl = Get.isRegistered<ParkingReportController>()
        ? Get.find<ParkingReportController>()
        : Get.put(ParkingReportController());
    mapDebug('screen init → resolve GPS and fetch parking');
    _initializeMap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _gpsPosition == null) {
      _initializeMap(); // settings থেকে ফিরলে আবার try করবে
    }
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();
    final location = _gpsPosition;

    // ✅ GPS না পেলে fetch করবেন না বা default দেখাবেন
    if (location == null) {
      mapDebug('No GPS — skipping parking fetch or using default');
      return; // অথবা default location দিয়ে fetch করুন
    }

    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  Future<void> _getUserLocation() async {
    mapDebug('location: start');
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        mapDebug('location: services disabled → stop');
        setState(() => _isLocating = false);
        // ✅ এখানে বসান
        showCustomSnackBar('Please enable location service', isError: true);
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
        // ✅ এখানে বসান
        showCustomSnackBar('Location permission denied', isError: true);
        return;
      }

      // ... বাকি কোড একই থাকবে
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
  //
  // void _toggleParkingPin() {
  //   HapticFeedback.mediumImpact();
  //
  //   if (_gpsPosition == null) {
  //     showCustomSnackBar('Unable to get current location', isError: true);
  //     return;
  //   }
  //
  //   mapDebug(
  //     'parking dialog open (submit will use GPS location '
  //         'lat=${_gpsPosition!.latitude.toStringAsFixed(6)} '
  //         'lng=${_gpsPosition!.longitude.toStringAsFixed(6)})',
  //   );
  //   _showParkingDialog();
  // }

  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedLocation = null; // ⚠️ গত বারের picked location cache থেকে মুছে ফেলা
    mapDebug('parking dialog open');
    _showParkingDialog();
  }

  ///fetch parking======================================================
  // void _showParkingDialog() {
  //   _parkingCtrl.reset();
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => ParkingInfoDialog(
  //       controller: _parkingCtrl,
  //       onSubmit: () async {
  //         Navigator.of(context).pop();
  //         final success = await _parkingCtrl.addParking(
  //           latitude: _mapCenter.latitude,
  //           longitude: _mapCenter.longitude,
  //         );
  //         if (!mounted) return;
  //         if (success) {
  //      //
  //           showCustomSnackBar(
  //             _parkingCtrl.submitMessage.value.isNotEmpty
  //                 ? _parkingCtrl.submitMessage.value
  //                 : 'map_parking_report_submitted'.tr,
  //             isError: false,
  //           );
  //           await _parkingCtrl.fetchParkingReport(
  //             latitude: _gpsPosition!.latitude,
  //             longitude: _gpsPosition!.longitude,
  //           );
  //         } else {
  //           showCustomSnackBar(
  //             _parkingCtrl.submitMessage.value.isNotEmpty
  //                 ? _parkingCtrl.submitMessage.value
  //                 : 'map_failed_to_submit_parking_report'.tr,
  //             isError: true,
  //           );
  //         }
  //       },
  //       onCancel: () => Navigator.of(context).pop(),
  //     ),
  //   );
  // }



  void _showParkingDialog() {
    _parkingCtrl.reset(); // ⚠️ আগে থেকেই আছে — controller এর পুরনো cost/charging/disabled state রিসেট করে, রাখুন

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParkingInfoDialog(
        controller: _parkingCtrl,
        pickedLocation: _pickedLocation,
        onPickOnMap: () {
          Navigator.of(context).pop();
          _startPickingLocation();
        },
        onSubmit: () async {
          Navigator.of(context).pop();

          if (_pickedLocation == null && _gpsPosition == null) {
            showCustomSnackBar('Location not available', isError: true);
            return;
          }

          final LatLng useLocation = _pickedLocation ?? _gpsPosition!;

          final success = await _parkingCtrl.addParking(
            latitude: useLocation.latitude,
            longitude: useLocation.longitude,
          );
          if (!mounted) return;
          if (success) {
            showCustomSnackBar(
              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
                  : 'map_parking_report_submitted'.tr,
              isError: false,
            );
            await _parkingCtrl.fetchParkingReport(
              latitude: useLocation.latitude,
              longitude: useLocation.longitude,
            );
            _pickedLocation = null; // ⚠️ সফল submit এর পর picked location মুছে ফেলা — পরের বার আবার GPS default এ ফিরবে
          } else {
            showCustomSnackBar(
              _parkingCtrl.submitMessage.value.isNotEmpty
                  ? _parkingCtrl.submitMessage.value
                  : 'map_failed_to_submit_parking_report'.tr,
              isError: true,
            );
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
          _pickedLocation = null; // ⚠️ cancel করলেও picked location মুছে ফেলা, যাতে পরের বার stale lat/lng না থাকে
        },
      ),
    );
  }


  void _startPickingLocation() {
    setState(() => _isPickingLocation = true);
    showCustomSnackBar('Tap on the map to select a location', isError: false);
  }

  void _onMapTapped(LatLng position) {
    if (!_isPickingLocation) {
      _parkingCtrl.clearSelectedReport(); // আগের behavior অক্ষত রাখা হলো
      return;
    }
    setState(() {
      _pickedLocation = position;
      _isPickingLocation = false;
    });
    HapticFeedback.selectionClick();
    mapDebug(
      'picked location lat=${position.latitude.toStringAsFixed(6)} '
          'lng=${position.longitude.toStringAsFixed(6)}',
    );
    _showParkingDialog();
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

            if (!_isLocating && _gpsPosition == null)
              _buildLocationOffPrompt()
            else if (_isLocating && _gpsPosition == null)
              const MapInitialShimmer()
///see marker =======================
            else
              Obx(() {
                // final markers = {
                //   ..._markers,
                //   ..._parkingCtrl.markers,
                // };



                final markers = {
                  ..._markers,
                  ..._parkingCtrl.markers,
                  if (_pickedLocation != null)
                    Marker(
                      markerId: const MarkerId('picked_location'),
                      position: _pickedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    ),
                };






                return GoogleMap(
                  mapType: MapType.hybrid,
                  key: const ValueKey<Object>('platechat_google_map'),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: MapScreen.kInitialMapTarget,
                    zoom: 14,
                  ),
                  markers: markers,
                 myLocationEnabled: true,
                 // myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                 // onTap: (_) => _parkingCtrl.clearSelectedReport(),
                  onTap: _onMapTapped,
                );
              }),

            // ── GPS locating banner (plain bool, Obx নেই) ────────────────
            if (_isLocating) const LocatingBanner(),




            // ── Pick location mode banner ──────────────────────────────
            if (_isPickingLocation)
              Positioned(
                top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(16),
                left: ResponsiveHelper.padding(16),
                right: ResponsiveHelper.padding(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tap on the map to select parking location',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),



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

           /// // ── Drop pin add ──────────────────────────────────────────────
            Positioned(
              right: ResponsiveHelper.padding(24),
              bottom: ResponsiveHelper.padding(32),
              child: AddParkingButton(
                onPressed: _toggleParkingPin,
              ),
            ),


          ],
        ),
      ),
    );
  }







///default location=================

  Widget _buildLocationOffPrompt() {
    return Container(
      color: const Color(0xFF1a1a2e), // blurred map feel
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F1FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off, color: Color(0xFF185FA5), size: 26),
              ),
              const SizedBox(height: 12),
              const Text(
                'Location is turned off',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please enable location from your device to see nearby parking reports on the map.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),

              // ✅ Enable location button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await Geolocator.openLocationSettings(); // system settings খুলবে
                  },
                  child: const Text('Enable location', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),

            ],
          ),
        ),
      ),
    );
  }




}









