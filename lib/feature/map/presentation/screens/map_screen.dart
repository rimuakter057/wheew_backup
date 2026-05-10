import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static final LatLng _defaultPosition = LatLng(34.052235, -118.243683);
  LatLng _currentPosition = _defaultPosition;
  LatLng? _parkingPin;

  bool _isPinDropped = false;
  bool _hasAlert = false;
  bool _isLocating = true;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// ─── Get User Location ──────────────────────────────────────────────────────

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  // ─── Drop / Remove Parking Pin ──────────────────────────────────────────────

  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_isPinDropped) {
        _markers.removeWhere((m) => m.markerId.value == 'parking_pin');
        _parkingPin = null;
        _isPinDropped = false;
        _hasAlert = false;
      } else {
        _parkingPin = _currentPosition;
        _markers.add(
          Marker(
            markerId: const MarkerId('parking_pin'),
            position: _currentPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: 'parking_pin'.tr.isNotEmpty
                  ? 'parking_pin'.tr
                  : 'Parking Pin',
            ),
          ),
        );
        _isPinDropped = true;
        _hasAlert = true;
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_isLocating) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Google Map ───────────────────────────────────────────────────────
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onCameraMove: (pos) {
              setState(() => _currentPosition = pos.target);
            },
          ),

          // ── Locating Indicator ───────────────────────────────────────────────
          if (_isLocating)
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  ResponsiveHelper.padding(12),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(16),
                    vertical: ResponsiveHelper.padding(8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: ResponsiveHelper.width(16),
                        height: ResponsiveHelper.height(16),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3D72E8),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(8)),
                      Text(
                        'locating'.tr.isNotEmpty
                            ? 'locating'.tr
                            : 'Getting location…',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(12),
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ///useful number ── Alert FAB ────────────────────────────────────────────────────────

            Positioned(
              right: ResponsiveHelper.padding(16),
              bottom: ResponsiveHelper.padding(168),
              child: _MapFab(
                icon: Icons.warning_amber_rounded,
                color: AppColors.red,
                iconColor: AppColors.white,
                onTap: () =>  context.pushNamed(RouteName.usefulMemberScreen)



              ),
            ),

           /// ── My Location FAB ──────────────────────────────────────────────────
          Positioned(
            right: ResponsiveHelper.padding(16),
            bottom: ResponsiveHelper.padding(104),
            child: _MapFab(
              icon: Icons.my_location_rounded,
              color: Colors.white,
              iconColor: const Color(0xFF3D72E8),
              onTap: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition, 15),
                );
              },
            ),
          ),

          // ── Drop Parking Pin Button ──────────────────────────────────────────
          Positioned(
            left: ResponsiveHelper.padding(24),
            right: ResponsiveHelper.padding(24),
            bottom: ResponsiveHelper.padding(32),
            child: _DropPinButton(
              isPinDropped: _isPinDropped,
              onTap: _toggleParkingPin,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Drop Parking Pin Button ──────────────────────────────────────────────────

class _DropPinButton extends StatelessWidget {
  final bool isPinDropped;
  final VoidCallback onTap;

  const _DropPinButton({required this.isPinDropped, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: ResponsiveHelper.buttonHeight(52),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D72E8).withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.width(28),
              height: ResponsiveHelper.height(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'P',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(15),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Text(
              isPinDropped
                  ? ('remove_pin'.tr.isNotEmpty
                  ? 'remove_pin'.tr
                  : 'Remove Parking Pin')
                  : ('drop_parking_pin'.tr.isNotEmpty
                  ? 'drop_parking_pin'.tr
                  : 'Drop Parking Pin'),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(15),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Map FAB ──────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapFab({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.width(48),
        height: ResponsiveHelper.height(48),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: ResponsiveHelper.iconSize(22),
          ),
        ),
      ),
    );
  }
}




