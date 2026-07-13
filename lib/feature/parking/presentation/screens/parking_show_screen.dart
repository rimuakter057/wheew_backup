import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';
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
    if (state == AppLifecycleState.resumed &&
        _parkingShowCtrl.gpsPosition.value == null) {
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
            Obx(() {
              final isLocating = _parkingShowCtrl.isLocating.value;
              final gpsPosition = _parkingShowCtrl.gpsPosition.value;
              final showLocationPulse = _parkingShowCtrl.showLocationPulse.value;
              final isLoading = _parkingShowCtrl.isLoading.value;

              if (!isLocating && gpsPosition == null) {
                return _buildLocationOffPrompt();
              } else if (isLocating && gpsPosition == null) {
                return const MapInitialShimmer();
              }

              return Stack(
                children: [
                  Obx(() {
                    final currentMarkers = _parkingShowCtrl.markers.toSet();
                    final currentPolygons = _parkingShowCtrl.polygons.toSet();
                    final currentCircles = _parkingShowCtrl.circles.toSet();
                    final currentPolylines = _parkingShowCtrl.polylines.toSet();

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
                      polylines: currentPolylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    );
                  }),

                  if (isLocating) const LocatingBanner(),

                  if (isLoading) const FetchingParkingBanner(),

                  if (showLocationPulse)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          ResponsiveHelper.padding(16),
                      left: ResponsiveHelper.padding(16),
                      right: ResponsiveHelper.padding(80),
                      child: Container(
                        height: ResponsiveHelper.padding(45),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search parking',
                            hintStyle:
                                TextStyle(fontSize: 14, color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF185FA5),
                              size: 20,
                            ),
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
                            final t = _pulseController.value < 0.5
                                ? _pulseController.value * 2
                                : (1.0 - _pulseController.value) * 2;

                            final glowWidth = 6.0 + (t * 14.0);
                            final glowOpacity = 0.4 + (t * 0.6);

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF185FA5)
                                      .withValues(alpha: glowOpacity),
                                  width: glowWidth,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF185FA5)
                                        .withValues(alpha: glowOpacity * 0.5),
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
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MapType>(
                    value: _selectedMapType,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.layers_outlined,
                        color: Color(0xFF185FA5),
                        size: 20,
                      ),
                    ),
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    alignment: Alignment.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

            /// ── ParkMode Status Pill (Top-Left) ──────────────────────────────────
            Obx(() {
              final isSearching = _parkingShowCtrl.isParkModeActive.value;
              return Positioned(
                top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(72),
                left: ResponsiveHelper.padding(16),
                child: GestureDetector(
                  onTap: () => _parkingShowCtrl.toggleParkMode(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSearching ? const Color(0xFF185FA5) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSearching ? Icons.explore : Icons.explore_off_outlined,
                          color: isSearching ? Colors.white : const Color(0xFF185FA5),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSearching ? 'ParkMode: Searching' : 'ParkMode: Inactive',
                          style: TextStyle(
                            color: isSearching ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            /// ── ParkMode Detailed Sensor Info ────────────────────────────────────
            Obx(() {
              if (!_parkingShowCtrl.isParkModeActive.value) return const SizedBox.shrink();
              return Positioned(
                top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(125),
                left: ResponsiveHelper.padding(16),
                child: Container(
                  width: ResponsiveHelper.padding(210),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF185FA5).withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sensor-Fusion Tracking',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF185FA5)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.gps_fixed, size: 12, color: Colors.green.shade600),
                          const SizedBox(width: 6),
                          const Text('GPS Speed: < 3 km/h', style: TextStyle(fontSize: 10, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.vibration, size: 12, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          const Text('Accel: Frequent Braking/Turns', style: TextStyle(fontSize: 10, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 22,
                        child: ElevatedButton(
                          onPressed: () => _parkingShowCtrl.simulateAutoParkDetection(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF185FA5),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Simulate Stop', style: TextStyle(fontSize: 9, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),

            /// ── SavePark Floating Controls (Bottom) ──────────────────────────────
            Obx(() {
              final isSaved = _parkingShowCtrl.savedParkingLocation.value != null;
              final isTimerActive = _parkingShowCtrl.isTimerActive.value;
              final timeLeft = _parkingShowCtrl.remainingTimeString.value;
              final isPaid = _parkingShowCtrl.isPaidSpot.value;

              return Positioned(
                bottom: ResponsiveHelper.padding(24),
                left: ResponsiveHelper.padding(16),
                right: ResponsiveHelper.padding(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !isSaved
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                key: const ValueKey('save_btn'),
                                onPressed: () => _parkingShowCtrl.saveCurrentParkingLocation(),
                                icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                                label: const Text(
                                  'Save Parking Spot',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF185FA5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          key: const ValueKey('saved_card'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPaid ? Colors.orange.shade50 : Colors.green.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPaid ? Icons.timer_outlined : Icons.check_circle_outline,
                                      color: isPaid ? Colors.orange.shade700 : Colors.green.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Car Parked & Saved',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Confidence Level: ${_parkingShowCtrl.confidenceLevel.value}% (High)',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isPaid && isTimerActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        timeLeft,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _parkingShowCtrl.clearSavedParkingLocation(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Clear Spot',
                                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _parkingShowCtrl.launchSavedParkingRoute(),
                                      icon: const Icon(Icons.directions_walk, color: Colors.white, size: 16),
                                      label: const Text(
                                        'Walk to Car',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF185FA5),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                ),
              );
            }),
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
                child: const Icon(
                  Icons.location_off,
                  color: Color(0xFF185FA5),
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.locationTurnedOff.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.locationOffDesc.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.5,
                ),
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
                  child: Text(
                    AppStrings.enableLocation.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
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
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const Text(
                  'Parking Confirmation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _onParkingNo();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
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
