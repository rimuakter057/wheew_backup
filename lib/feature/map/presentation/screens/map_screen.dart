import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
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
  bool _hasAlert     = false;
  bool _isLocating   = true;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;

  @override
  void initState() {
    super.initState();
    _parkingCtrl = Get.put(ParkingReportController());
    _getUserLocation();
    _parkingCtrl.fetchParkingReport(); // ← GET call
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Location ─────────────────────────────────────────────────────────────
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _isLocating = false); return; }

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

  // ─── Parking Dialog ───────────────────────────────────────────────────────
  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _showParkingDialog();
  }

  void _showParkingDialog() {
    _parkingCtrl.reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ParkingInfoDialog(
        controller: _parkingCtrl,
        onSubmit: () async {
          Navigator.of(context).pop();
          final success = await _parkingCtrl.submitParkingReport(
            latitude : _currentPosition.latitude,
            longitude: _currentPosition.longitude,
          );
          if (success) _dropPinOnMap();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _dropPinOnMap() {
    setState(() {
      _parkingPin = _currentPosition;
      _markers.add(
        Marker(
          markerId : const MarkerId('parking_pin'),
          position : _currentPosition,
          icon     : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'parking_pin'.tr.isNotEmpty ? 'parking_pin'.tr : 'Parking Pin',
          ),
        ),
      );
      _isPinDropped = true;
      _hasAlert     = true;
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

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Google Map — Obx দিয়ে wrap করা হয়েছে GET markers reactive করতে ──
          Obx(() => GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
            markers: {
              ..._markers,                        // submit এর পর drop pin
              ..._parkingCtrl.markers.toSet(),    // GET থেকে আসা parking markers
            },
            myLocationEnabled      : true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled    : false,
            mapToolbarEnabled      : false,
            compassEnabled         : false,
            onCameraMove: (pos) => setState(() => _currentPosition = pos.target),
          )),

          // ── Locating Indicator ────────────────────────────────────────────
          if (_isLocating)
            Positioned(
              top  : MediaQuery.of(context).padding.top + ResponsiveHelper.padding(12),
              left : 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(16),
                    vertical  : ResponsiveHelper.padding(8),
                  ),
                  decoration: BoxDecoration(
                    color       : Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                    boxShadow   : [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width : ResponsiveHelper.width(16),
                        height: ResponsiveHelper.height(16),
                        child : const CircularProgressIndicator(
                          strokeWidth: 2,
                          color      : Color(0xFF3D72E8),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(8)),
                      Text(
                        'locating'.tr.isNotEmpty ? 'locating'.tr : 'Getting location…',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(12),
                          color   : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Fetching Parking Indicator ────────────────────────────────────
          Obx(() => _parkingCtrl.isLoadingShowDetails.value
              ? Positioned(
            top  : MediaQuery.of(context).padding.top + ResponsiveHelper.padding(52),
            left : 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(16),
                  vertical  : ResponsiveHelper.padding(8),
                ),
                decoration: BoxDecoration(
                  color       : Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                  boxShadow   : [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width : ResponsiveHelper.width(16),
                      height: ResponsiveHelper.height(16),
                      child : const CircularProgressIndicator(
                        strokeWidth: 2,
                        color      : Color(0xFF3D72E8),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Text(
                      'Loading parking spots...',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        color   : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
          ),

          // ── Alert FAB ─────────────────────────────────────────────────────
          Positioned(
            right : ResponsiveHelper.padding(16),
            bottom: ResponsiveHelper.padding(168),
            child : _MapFab(
              icon     : Icons.warning_amber_rounded,
              color    : AppColors.red,
              iconColor: AppColors.white,
              onTap    : () => context.pushNamed(RouteName.usefulMemberScreen),
            ),
          ),

          // ── My Location FAB ───────────────────────────────────────────────
          Positioned(
            right : ResponsiveHelper.padding(16),
            bottom: ResponsiveHelper.padding(104),
            child : _MapFab(
              icon     : Icons.my_location_rounded,
              color    : Colors.white,
              iconColor: const Color(0xFF3D72E8),
              onTap    : () => _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_currentPosition, 15),
              ),
            ),
          ),

          // ── Drop Parking Pin Button ───────────────────────────────────────
          Positioned(
            left  : ResponsiveHelper.padding(24),
            right : ResponsiveHelper.padding(24),
            bottom: ResponsiveHelper.padding(32),
            child : _DropPinButton(onTap: _toggleParkingPin),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Parking Info Dialog ──────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ParkingInfoDialog extends StatelessWidget {
  final ParkingReportController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _ParkingInfoDialog({
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape       : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child       : Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child  : Column(
          mainAxisSize      : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title ──────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width : 36, height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('P',
                        style: TextStyle(
                          color     : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize  : 16,
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Parking Details',
                    style: GoogleFonts.poppins(
                      fontSize  : 16,
                      fontWeight: FontWeight.w700,
                      color     : const Color(0xFF1A1A2E),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ── Parking Cost ───────────────────────────────────────────────
            _SectionLabel(icon: Icons.local_parking_rounded, label: 'Parking Cost'),
            const SizedBox(height: 8),
            Row(
              children: ['FREE', 'PAID'].map((val) {
                final selected = controller.parkingCost.value == val;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.parkingCost.value = val,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin  : EdgeInsets.only(right: val == 'FREE' ? 8 : 0),
                      padding : const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color       : selected ? const Color(0xFF3D72E8) : const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(12),
                        border      : Border.all(
                          color: selected ? const Color(0xFF3D72E8) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            val == 'FREE' ? Icons.money_off_rounded : Icons.attach_money_rounded,
                            color: selected ? Colors.white : const Color(0xFF6B7280),
                            size : 18,
                          ),
                          const SizedBox(width: 6),
                          Text(val,
                              style: GoogleFonts.poppins(
                                fontSize  : 13,
                                fontWeight: FontWeight.w600,
                                color     : selected ? Colors.white : const Color(0xFF6B7280),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Electric Charging ──────────────────────────────────────────
            _ToggleRow(
              icon     : Icons.electric_bolt_rounded,
              iconColor: const Color(0xFFF59E0B),
              label    : 'Electric Charging',
              value    : controller.electricCharging.value,
              onTap    : () => controller.electricCharging.toggle(),
            ),
            const SizedBox(height: 12),

            // ── Disabled Facility ──────────────────────────────────────────
            _ToggleRow(
              icon     : Icons.accessible_rounded,
              iconColor: const Color(0xFF10B981),
              label    : 'Disabled Facility',
              value    : controller.disabledFacility.value,
              onTap    : () => controller.disabledFacility.toggle(),
            ),

            // ── Disabled Location Sub-section ──────────────────────────────
            if (controller.disabledFacility.value) ...[
              const SizedBox(height: 16),
              _SectionLabel(icon: Icons.location_on_rounded, label: 'Disabled Parking Location'),
              const SizedBox(height: 10),
              _DisabledLocationPicker(controller: controller),
            ],

            const SizedBox(height: 24),

            // ── Buttons ────────────────────────────────────────────────────
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D72E8)))
                : Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height    : 48,
                      decoration: BoxDecoration(
                        color       : const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text('Cancel',
                            style: GoogleFonts.poppins(
                              fontSize  : 14,
                              fontWeight: FontWeight.w600,
                              color     : const Color(0xFF6B7280),
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Submit
                Expanded(
                  flex : 2,
                  child: GestureDetector(
                    onTap: onSubmit,
                    child: Container(
                      height    : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow   : [
                          BoxShadow(
                            color     : const Color(0xFF3D72E8).withOpacity(0.35),
                            blurRadius: 12,
                            offset    : const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pin_drop_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text('Drop Pin',
                              style: GoogleFonts.poppins(
                                fontSize  : 14,
                                fontWeight: FontWeight.w600,
                                color     : Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Disabled Location Picker ─────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _DisabledLocationPicker extends StatelessWidget {
  final ParkingReportController controller;
  _DisabledLocationPicker({required this.controller});

  final _options = [
    _DLocOption(DisabledLocation.all,   'ALL',   AssetsPath.all),
    _DLocOption(DisabledLocation.top,   'TOP',   AssetsPath.top),
    _DLocOption(DisabledLocation.back,  'BACK',  AssetsPath.back),
    _DLocOption(DisabledLocation.right, 'RIGHT', AssetsPath.left),
    _DLocOption(DisabledLocation.left,  'LEFT',  AssetsPath.right),
    _DLocOption(DisabledLocation.none,  'NONE',  AssetsPath.all),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
      spacing   : 8,
      runSpacing: 8,
      children  : _options.map((opt) {
        final selected = controller.disabledLocation.value == opt.location;
        return GestureDetector(
          onTap: () => controller.disabledLocation.value = opt.location,
          child: AnimatedContainer(
            duration : const Duration(milliseconds: 200),
            padding  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color       : selected ? const Color(0xFF10B981) : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
              border      : Border.all(
                color: selected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children    : [
                SvgPicture.asset(opt.icon, width: 24, height: 24),
                const SizedBox(width: 4),
                Text(opt.label,
                    style: GoogleFonts.poppins(
                      fontSize  : 12,
                      fontWeight: FontWeight.w600,
                      color     : selected ? Colors.white : const Color(0xFF6B7280),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }
}

class _DLocOption {
  final DisabledLocation location;
  final String           label;
  final String           icon;
  const _DLocOption(this.location, this.label, this.icon);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Reusable Widgets ─────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width : 32,
          height: 32,
          decoration: BoxDecoration(
            color       : const Color(0xFF3D72E8).withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(icon, size: 18)),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: GoogleFonts.poppins(
              fontSize  : 13,
              fontWeight: FontWeight.w600,
              color     : const Color(0xFF1A1A2E),
            )),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData     icon;
  final Color        iconColor;
  final String       label;
  final bool         value;
  final VoidCallback onTap;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding   : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color       : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(12),
          border      : Border.all(
            color: value ? iconColor.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width : 32, height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                    fontSize  : 13,
                    fontWeight: FontWeight.w500,
                    color     : const Color(0xFF1A1A2E),
                  )),
            ),
            AnimatedContainer(
              duration    : const Duration(milliseconds: 250),
              width       : 44, height: 24,
              decoration  : BoxDecoration(
                color       : value ? iconColor : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration  : const Duration(milliseconds: 250),
                alignment : value ? Alignment.centerRight : Alignment.centerLeft,
                child     : Container(
                  width : 18, height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Drop Pin Button ──────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _DropPinButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DropPinButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration : const Duration(milliseconds: 250),
        curve    : Curves.easeInOut,
        height   : ResponsiveHelper.buttonHeight(52),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3D72E8), Color(0xFF2557D6)],
            begin : Alignment.topLeft,
            end   : Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          boxShadow   : [
            BoxShadow(
              color     : const Color(0xFF3D72E8).withOpacity(0.40),
              blurRadius: 16,
              offset    : const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children         : [
            Container(
              width : ResponsiveHelper.width(28),
              height: ResponsiveHelper.height(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('P',
                    style: GoogleFonts.poppins(
                      fontSize  : ResponsiveHelper.fontSize(15),
                      fontWeight: FontWeight.w800,
                      color     : Colors.white,
                    )),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Text(
              'drop_parking_pin'.tr.isNotEmpty ? 'drop_parking_pin'.tr : 'Drop Parking Pin',
              maxLines : 1,
              overflow : TextOverflow.ellipsis,
              style    : GoogleFonts.poppins(
                fontSize     : ResponsiveHelper.fontSize(15),
                fontWeight   : FontWeight.w600,
                color        : Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Map FAB ──────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _MapFab extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final Color        iconColor;
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
        width : ResponsiveHelper.width(48),
        height: ResponsiveHelper.height(48),
        decoration: BoxDecoration(
          color    : color,
          shape    : BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color     : Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset    : const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: ResponsiveHelper.iconSize(22)),
        ),
      ),
    );
  }
}