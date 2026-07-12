import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';
import 'package:platchatapp/feature/parking/controller/parking_show_controller.dart';

class ParkingShowScreen extends StatefulWidget {
  const ParkingShowScreen({super.key});

  static const LatLng kInitialMapTarget = LatLng(34.052235, -118.243683);

  @override
  State<ParkingShowScreen> createState() => _ParkingShowScreenState();
}

class _ParkingShowScreenState extends State<ParkingShowScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapType _selectedMapType = MapType.hybrid;


  late final ParkingShowController _parkingShowCtrl;

  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _parkingShowCtrl = Get.isRegistered<ParkingShowController>()
        ? Get.find<ParkingShowController>()
        : Get.put(ParkingShowController());

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
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _parkingShowCtrl.gpsPosition.value == null) {
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    await _parkingShowCtrl.initializeFlow(
      onShowPopup: () {
        if (mounted) {
          _showParkingConfirmationPopup();
        }
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _parkingShowCtrl.onMapCreated(controller);
    mapDebug('GoogleMap created');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            /// ── Map and overlay banners ───────────────────────────────────
            Obx(() {
              final isLocating = _parkingShowCtrl.isLocating.value;
              final gpsPosition = _parkingShowCtrl.gpsPosition.value;
              final showLocationPulse = _parkingShowCtrl.showLocationPulse.value;
              final isLoading = _parkingShowCtrl.isLoading.value;
              final currentPolylines = _parkingShowCtrl.polylines.toSet();   // 👈 নতুন

              if (!isLocating && gpsPosition == null) {
                return _buildLocationOffPrompt();
              } else if (isLocating && gpsPosition == null) {
                return const MapInitialShimmer();
              }

              return Stack(
                children: [
                  // ── Markers/Polygons need their OWN Obx so GetX actually
                  // tracks changes to `markers`/`polygons` RxSet. Passing the
                  // RxSet as a plain object reference (no `.value` read) does
                  // NOT register a listener, so the map would never refresh
                  // when the controller reassigns markers.value / polygons.value.
                  Obx(() {
                    final currentMarkers = _parkingShowCtrl.markers.toSet();
                    final currentPolygons = _parkingShowCtrl.polygons.toSet();
                    final currentCircles = _parkingShowCtrl.circles.toSet();


                    return GoogleMap(
                      mapType: _selectedMapType,
                      key: const ValueKey<Object>('platechat_google_map'),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: gpsPosition ?? ParkingShowScreen.kInitialMapTarget,
                        zoom: 14,
                      ),
                      markers: currentMarkers,
                      polygons: currentPolygons,
                      circles: currentCircles,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      polylines: currentPolylines,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    );
                  }),

                  if (isLocating) const LocatingBanner(),

                  if (isLoading) const FetchingParkingBanner(),

                  if (showLocationPulse)
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
                          decoration: const InputDecoration(
                            hintText: 'Search parking',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF185FA5), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                  if (showLocationPulse && gpsPosition != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            // 0.0 → 1.0 → 0.0 (breathing effect)
                            final t = _pulseController.value < 0.5
                                ? _pulseController.value * 2
                                : (1.0 - _pulseController.value) * 2;

                            final glowWidth = 6.0 + (t * 14.0); // border পুরুত্ব বাড়বে-কমবে
                            final glowOpacity = 0.4 + (t * 0.6);

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF185FA5).withOpacity(glowOpacity),
                                  width: glowWidth,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF185FA5).withOpacity(glowOpacity * 0.5),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
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
                      color: Colors.black.withOpacity(0.08), // খুব সফট এবং প্রিমিয়াম শ্যাডো
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline( // আন্ডারলাইন রিমুভ করার স্ট্যান্ডার্ড ওয়ে
                  child: DropdownButton<MapType>(
                    value: _selectedMapType,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.layers_outlined, color: Color(0xFF185FA5), size: 20),
                    ),
                    elevation: 3, // ড্রপডাউন ওপেন হলে নিচের মেনুর শ্যাডো ডেপথ
                    borderRadius: BorderRadius.circular(12), // ওপেন হওয়া মেনুর কর্নারও রাউন্ডেড হবে
                    dropdownColor: Colors.white,
                    alignment: Alignment.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500, // একটু বোল্ড ও প্রিমিয়াম লুক
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
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.locationOffDesc.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                      style: const TextStyle(color: Colors.white)),
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
                    // No Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onParkingNo();
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

                    // Yes Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _onParkingYes();
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
    _parkingShowCtrl.onLeavingPopupNo();
  }

  void _onParkingYes() {
    _parkingShowCtrl.onLeavingPopupYes();
  }
}