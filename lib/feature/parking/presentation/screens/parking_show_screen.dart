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

class ParkingShowScreen extends StatefulWidget {
  const ParkingShowScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<ParkingShowScreen> createState() => _ParkingShowScreenState();
}

// class _ParkingShowScreenState extends State<ParkingShowScreen> with WidgetsBindingObserver {
//


class _ParkingShowScreenState extends State<ParkingShowScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  int _selectedRadiusMeter = 300;

  LatLng _mapCenter = ParkingShowScreen.kInitialMapTarget;
  LatLng? _gpsPosition;
  bool _isLocating = true;
  LatLng? _pickedLocation;
  bool _isPickingLocation = false;
  MapType _selectedMapType = MapType.hybrid;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;


  bool _showLocationPulse = false;
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parkingCtrl = Get.isRegistered<ParkingReportController>()
        ? Get.find<ParkingReportController>()
        : Get.put(ParkingReportController());
    mapDebug('screen init → resolve GPS and fetch parking');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();


    _initializeMap();
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _pulseController.dispose(); // ✅ নতুন
    _searchController.dispose(); // ✅ নতুন
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _gpsPosition == null) {
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();

    if (!mounted) return;

    final location = _gpsPosition;

    if (location == null) {
      mapDebug('No GPS — skipping parking flow');
      return;
    }

    _showParkingConfirmationPopup();
  }



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
                    target: ParkingShowScreen.kInitialMapTarget,
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
              top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(72),
              right: ResponsiveHelper.padding(16),
              child: Container(
                height: ResponsiveHelper.padding(45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
              bottom: ResponsiveHelper.padding(80),
              child: FloatingActionButton(
                heroTag: 'filterRadiusBtn',
                backgroundColor: Colors.white,
                elevation: 3,
                onPressed: _showRadiusFilterSheet,
                child: const Icon(Icons.tune, color: Color(0xFF185FA5)),
              ),
            ),


            if (_showLocationPulse)
              Positioned(
                top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(16),
                left: ResponsiveHelper.padding(16),
                right: ResponsiveHelper.padding(80),
                child: Container(
                  height: ResponsiveHelper.padding(45),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search parking',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF185FA5), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

            if (_showLocationPulse && _gpsPosition != null)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    // 0.0 → 1.0 → 0.0 (breathing effect)
                    final t = _pulseController.value < 0.5
                        ? _pulseController.value * 2
                        : (1.0 - _pulseController.value) * 2;

                    final glowWidth = 6.0 + (t * 14.0); // border পুরুত্ব বাড়বে-কমবে
                    final glowOpacity = 0.4 + (t * 0.6);

                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF185FA5)
                                .withOpacity(glowOpacity),
                            width: glowWidth,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF185FA5)
                                  .withOpacity(glowOpacity * 0.5),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

  void _showParkingConfirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0), // Extra smooth corners
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Auto-wrap content
              children: [
                // --- Premium Minimal Icon ---
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_parking_rounded,
                    size: 44,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Bold Title ---
                const Text(
                  'Parking Confirmation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A), // Dark elegant black
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // --- Descriptive Subtitle ---
                Text(
                  'Are you leaving a parking spot right now?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // --- Modern Action Buttons ---
                Row(
                  children: [
                    // No Button (Will trigger API fetch)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onParkingNo(); // 🟢 API Call trigger
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Yes Button (Will just zoom map)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onParkingYes(); // 🟢 Map camera zoom trigger
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  void _onParkingNo() {
    final location = _gpsPosition;
    if (location == null) return;
    setState(() {
      _showLocationPulse = true; // ✅ নতুন — blue pulse effect চালু হবে
    });

    // ✅ No selected → ekhon API call suru hobe
    _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );
  }

  void _onParkingYes() {
    // ✅ Yes selected → kono API call na, just current location e thakbe
    final location = _gpsPosition;
    if (location == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 17),
    );
  }




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




