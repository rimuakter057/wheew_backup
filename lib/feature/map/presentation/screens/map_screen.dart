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
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  int _selectedRadiusMeter = 100;

  LatLng _mapCenter = MapScreen.kInitialMapTarget;
  LatLng? _gpsPosition;
  bool _isLocating = true;
  LatLng? _pickedLocation;
  bool _isPickingLocation = false;
  MapType _selectedMapType = MapType.hybrid; // ✅ নতুন

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
      _initializeMap();
    }
  }
  //
  // Future<void> _initializeMap() async {
  //   await _getUserLocation();
  //   final location = _gpsPosition;
  //
  //   if (location == null) {
  //     mapDebug('No GPS — skipping parking fetch or using default');
  //     return;
  //   }
  //
  //   await _parkingCtrl.fetchParkingReport(
  //     latitude: location.latitude,
  //     longitude: location.longitude,
  //     radius: _selectedRadiusMeter,
  //   );
  // }

  Future<void> _initializeMap() async {
    await _getUserLocation();

    if (!mounted) return;

    final location = _gpsPosition;

    if (location == null) {
      mapDebug('No GPS — skipping parking fetch');
      return;
    }

    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );
  }



  // Future<void> _getUserLocation() async {
  //   mapDebug('location: start');
  //   try {
  //     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       mapDebug('location: services disabled → stop');
  //       setState(() => _isLocating = false);
  //       showCustomSnackBar('Please enable location service', isError: true);
  //       return;
  //     }
  //
  //     var permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //     }
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       mapDebug('location: permission denied ($permission)');
  //       setState(() => _isLocating = false);
  //       showCustomSnackBar('Location permission denied', isError: true);
  //       return;
  //     }
  //
  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     final latLng = LatLng(position.latitude, position.longitude);
  //     mapDebug(
  //       'location: GPS ok lat=${position.latitude.toStringAsFixed(6)} '
  //           'lng=${position.longitude.toStringAsFixed(6)} '
  //           'accuracy=${position.accuracy.toStringAsFixed(1)}m',
  //     );
  //
  //     setState(() {
  //       _gpsPosition = latLng;
  //       _mapCenter = latLng;
  //       _isLocating = false;
  //     });
  //
  //     await _mapController?.animateCamera(
  //       CameraUpdate.newLatLngZoom(latLng, 15),
  //     );
  //     mapDebug('location: camera animated to GPS');
  //   } catch (e, st) {
  //     mapDebug('location: error $e');
  //     mapDebug('location: stack $st');
  //     setState(() => _isLocating = false);
  //   }
  // }







  Future<void> _getUserLocation() async {
    mapDebug('location: start');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        setState(() => _isLocating = false);

        showCustomSnackBar(
          'Please enable location service',
          isError: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);

        showCustomSnackBar(
          'Location permission denied',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      mapDebug(
        'location: GPS ok '
            'lat=${position.latitude.toStringAsFixed(6)} '
            'lng=${position.longitude.toStringAsFixed(6)}',
      );

      setState(() {
        _gpsPosition = latLng;
        _mapCenter = latLng;
        _isLocating = false;
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            latLng,
            15,
          ),
        );
      }

      mapDebug('location: camera animated');
    } catch (e, st) {
      mapDebug('location: error $e');
      mapDebug('location: stack $st');

      if (!mounted) return;

      setState(() {
        _isLocating = false;
      });
    }
  }


  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedLocation = null;
    mapDebug('parking dialog open');
    _showParkingDialog();
  }

  void _showParkingDialog() {
    _parkingCtrl.reset();

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
              radius: _selectedRadiusMeter,
            );
            _pickedLocation = null;
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
          _pickedLocation = null;
        },
      ),
    );
  }

  // void _startPickingLocation() {
  //   setState(() => _isPickingLocation = true);
  //   showCustomSnackBar('Tap on the map to select a location', isError: false);
  // }


  void _startPickingLocation() {
    if (!mounted) return;

    setState(() {
      _isPickingLocation = true;
    });

    showCustomSnackBar(
      'Tap on the map to select a location',
      isError: false,
    );
  }

  // void _onMapTapped(LatLng position) {
  //   if (!_isPickingLocation) {
  //     _parkingCtrl.clearSelectedReport();
  //     return;
  //   }
  //   setState(() {
  //     _pickedLocation = position;
  //     _isPickingLocation = false;
  //   });
  //   HapticFeedback.selectionClick();
  //   mapDebug(
  //     'picked location lat=${position.latitude.toStringAsFixed(6)} '
  //         'lng=${position.longitude.toStringAsFixed(6)}',
  //   );
  //   _showParkingDialog();
  // }



  void _onMapTapped(LatLng position) {
    if (!_isPickingLocation) {
      _parkingCtrl.clearSelectedReport();
      return;
    }

    if (!mounted) return;

    setState(() {
      _pickedLocation = position;
      _isPickingLocation = false;
    });

    HapticFeedback.selectionClick();

    mapDebug(
      'picked location '
          'lat=${position.latitude.toStringAsFixed(6)} '
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
            /// ── Map ──────────────────────────────────────────────────────
            if (!_isLocating && _gpsPosition == null)
              _buildLocationOffPrompt()
            else if (_isLocating && _gpsPosition == null)
              const MapInitialShimmer()
            else
              Obx(() {
                final markers = {
                  ..._markers,
                  ..._parkingCtrl.markers,
                  if (_pickedLocation != null)
                    Marker(
                      markerId: const MarkerId('picked_location'),
                      position: _pickedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                    ),
                };

                return GoogleMap(
                  mapType: _selectedMapType, // ✅
                  key: const ValueKey<Object>('platechat_google_map'),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: MapScreen.kInitialMapTarget,
                    zoom: 14,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  onTap: _onMapTapped,
                );
              }),

            /// ── GPS locating banner ───────────────────────────────────────
            if (_isLocating) const LocatingBanner(),

            /// ── Pick location mode banner ─────────────────────────────────
            if (_isPickingLocation)
              Positioned(
                top: MediaQuery.of(context).padding.top +
                    ResponsiveHelper.padding(16),
                left: ResponsiveHelper.padding(16),
                right: ResponsiveHelper.padding(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16),
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

            /// ── Parking fetching indicator ────────────────────────────────
            Obx(
                  () => _parkingCtrl.isLoadingShowDetails.value
                  ? const FetchingParkingBanner()
                  : const SizedBox.shrink(),
            ),

            /// ── Selected parking info card ────────────────────────────────
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


            /// ── Map Type Dropdown (Modernized) ──────────────────────────────────────
            Positioned(
              right: ResponsiveHelper.padding(30), // প্যাডিং কিছুটা মডার্ন গ্যাপে আনা হয়েছে
              top: ResponsiveHelper.padding(80),
              child: Container(
                height: ResponsiveHelper.padding(45), // একটি ফিক্সড ও ক্লিন হাইট
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // আরও কার্ভড এবং মডার্ন কর্নার
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), // খুব সফট এবং প্রিমিয়াম শ্যাডো
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline( // আন্ডারলাইন রিমুভ করার স্ট্যান্ডার্ড ওয়ে
                  child: DropdownButton<MapType>(
                    value: _selectedMapType,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.layers_outlined, color: Color(0xFF185FA5), size: 20),
                    ),
                    elevation: 3, // ড্রপডাউন ওপেন হলে নিচের মেনুর শ্যাডো ডেপথ
                    borderRadius: BorderRadius.circular(12), // ওপেন হওয়া মেনুর কর্নারও রাউন্ডেড হবে
                    dropdownColor: Colors.white,
                    alignment: Alignment.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500, // একটু বোল্ড ও প্রিমিয়াম লুক
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MapType.normal,
                        child: Text('Normal'),
                      ),
                      DropdownMenuItem(
                        value: MapType.hybrid,
                        child: Text('Hybrid'),
                      ),
                      DropdownMenuItem(
                        value: MapType.satellite,
                        child: Text('Satellite'),
                      ),
                      DropdownMenuItem(
                        value: MapType.terrain,
                        child: Text('Terrain'),
                      ),
                    ],
                    onChanged: (type) {
                      if (type != null) {
                        setState(() => _selectedMapType = type);
                      }
                    },
                  ),
                ),
              ),
            ),

            /// ── Radius filter button ──────────────────────────────────────
            Positioned(
              left: ResponsiveHelper.padding(30), // প্যাডিং কিছুটা মডার্ন গ্যাপে আনা হয়েছে
              top: ResponsiveHelper.padding(80),
              child: FloatingActionButton(
                heroTag: 'filterRadiusBtn',
                backgroundColor: Colors.white,
                elevation: 3,
                onPressed: _showRadiusFilterSheet,
                child: const Icon(Icons.tune, color: Color(0xFF185FA5)),
              ),
            ),

            /// ── Add parking button ────────────────────────────────────────
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

  Widget _buildLocationOffPrompt() {
    return Container(
      color: const Color(0xFF1a1a2e),
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
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F1FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off,
                    color: Color(0xFF185FA5), size: 26),
              ),
              const SizedBox(height: 12),
               Text(
                  AppStrings.locationTurnedOff.tr,
                style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
               Text(
                AppStrings.locationOffDesc.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
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
                    await Geolocator.openLocationSettings();
                  },
                  child:  Text(AppStrings.enableLocation.tr,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showRadiusFilterSheet() {
  //   HapticFeedback.lightImpact();
  //   RadiusFilterSheet.show(
  //     context,
  //     initialRadiusMeter: _selectedRadiusMeter,
  //     onApply: (radiusMeter) {
  //       setState(() => _selectedRadiusMeter = radiusMeter);
  //       _applyRadiusFilter();
  //     },
  //   );
  // }



  void _showRadiusFilterSheet() {
    HapticFeedback.lightImpact();

    RadiusFilterSheet.show(
      context,
      initialRadiusMeter: _selectedRadiusMeter,
      onApply: (radiusMeter) {
        if (!mounted) return;

        setState(() {
          _selectedRadiusMeter = radiusMeter;
        });

        _applyRadiusFilter();
      },
    );
  }


  Future<void> _applyRadiusFilter() async {
    final location = _gpsPosition ?? _mapCenter;

    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );

    if (!mounted) return;
    showCustomSnackBar(
      '${AppStrings.showingParking.tr} $_selectedRadiusMeter m',
      isError: false,
    );
  }
}