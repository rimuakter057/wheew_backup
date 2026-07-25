import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/navigation/controller/in_app_navigation_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Maps a Google Directions `maneuver` value to a turn icon — falls back to
/// a plain straight arrow for the depart step (which has no maneuver) or
/// any maneuver type not explicitly mapped.
IconData _maneuverIcon(String? maneuver) {
  switch (maneuver) {
    case 'turn-left':
      return Icons.turn_left;
    case 'turn-right':
      return Icons.turn_right;
    case 'turn-sharp-left':
      return Icons.turn_sharp_left;
    case 'turn-sharp-right':
      return Icons.turn_sharp_right;
    case 'turn-slight-left':
      return Icons.turn_slight_left;
    case 'turn-slight-right':
      return Icons.turn_slight_right;
    case 'uturn-left':
      return Icons.u_turn_left;
    case 'uturn-right':
      return Icons.u_turn_right;
    case 'merge':
      return Icons.merge;
    case 'fork-left':
      return Icons.fork_left;
    case 'fork-right':
      return Icons.fork_right;
    case 'ramp-left':
      return Icons.ramp_left;
    case 'ramp-right':
      return Icons.ramp_right;
    case 'roundabout-left':
    case 'roundabout-clockwise':
      return Icons.roundabout_left;
    case 'roundabout-right':
    case 'roundabout-counterclockwise':
      return Icons.roundabout_right;
    default:
      return Icons.straight;
  }
}

String _formatMeters(int meters) {
  if (meters < 1000) return '$meters m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

class InAppNavigationScreen extends StatefulWidget {
  final LatLng destination;
  final String? destinationLabel;

  const InAppNavigationScreen({
    super.key,
    required this.destination,
    this.destinationLabel,
  });

  @override
  State<InAppNavigationScreen> createState() => _InAppNavigationScreenState();
}

class _InAppNavigationScreenState extends State<InAppNavigationScreen> {
  late final InAppNavigationController controller;
  MapType _selectedMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InAppNavigationController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init(destination: widget.destination);
    });
  }

  @override
  void dispose() {
    Get.delete<InAppNavigationController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.destinationLabel ?? AppStrings.inAppNavigation.tr,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: ResponsiveHelper.fontSize(16)),
        ),
      ),
      body: Obx(() {
        if (controller.isLocationPermissionDenied.value) {
          return _buildMessageState(
            icon: Icons.location_off_outlined,
            message: AppStrings.locationPermissionRequiredForNavigation.tr,
            actionLabel: AppStrings.openSettings.tr,
            onAction: () => Geolocator.openAppSettings(),
            secondaryLabel: AppStrings.retry.tr,
            onSecondaryAction: controller.retry,
          );
        }

        if (controller.hasRouteError.value) {
          return _buildMessageState(
            icon: Icons.error_outline,
            message: AppStrings.couldNotLoadRoute.tr,
            actionLabel: AppStrings.retry.tr,
            onAction: controller.retry,
          );
        }

        if (controller.isLoadingRoute.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.blue),
                SizedBox(height: ResponsiveHelper.height(12)),
                Text(
                  AppStrings.loadingRoute.tr,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final userPosition = controller.liveUserPosition.value;
        final origin = controller.origin.value ?? widget.destination;
        final selectedIndex = controller.selectedRouteIndex.value;

        return Stack(
          children: [
            GoogleMap(
              mapType: _selectedMapType,
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              initialCameraPosition: CameraPosition(target: origin, zoom: 16),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('destination'),
                  position: widget.destination,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
                if (userPosition != null)
                  Marker(
                    markerId: const MarkerId('current_position'),
                    position: userPosition,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
                // "Similar ETA" / "+X min" pill for every alternate route.
                for (var i = 0; i < controller.allRoutes.length; i++)
                  if (i != selectedIndex && controller.routeLabels[i] != null)
                    Marker(
                      markerId: MarkerId('route_label_$i'),
                      position: controller.allRoutes[i]
                          .polylinePoints[controller.allRoutes[i].polylinePoints.length ~/ 2],
                      icon: controller.routeLabels[i]!,
                      anchor: const Offset(0.5, 0.5),
                      onTap: () => controller.selectRoute(i),
                    ),
                // Mode-icon + duration badge on the selected route while walking.
                if (controller.selectedMode.value == TravelMode.walking &&
                    controller.primaryRouteBadge.value != null &&
                    controller.routePoints.isNotEmpty)
                  Marker(
                    markerId: const MarkerId('primary_route_badge'),
                    position: controller.routePoints[controller.routePoints.length ~/ 2],
                    icon: controller.primaryRouteBadge.value!,
                    anchor: const Offset(0.5, 0.5),
                    zIndexInt: 2,
                  ),
              },
              polylines: {
                // Alternates drawn first (thin grey, tappable) so the
                // selected route always renders on top of them.
                for (var i = 0; i < controller.allRoutes.length; i++)
                  if (i != selectedIndex)
                    Polyline(
                      polylineId: PolylineId('route_$i'),
                      points: controller.allRoutes[i].polylinePoints,
                      color: Colors.grey.shade500,
                      width: ResponsiveHelper.borderWidth(4).round(),
                      consumeTapEvents: true,
                      onTap: () => controller.selectRoute(i),
                    ),
                Polyline(
                  polylineId: const PolylineId('route_selected'),
                  points: controller.routePoints,
                  color: AppColors.blue,
                  width: ResponsiveHelper.borderWidth(5).round(),
                  // Google Maps renders walking routes as a dotted line and
                  // driving routes as solid — the plugin doesn't support an
                  // animated dash offset, so this is the static equivalent.
                  patterns: controller.selectedMode.value == TravelMode.walking
                      ? [PatternItem.dot, PatternItem.gap(ResponsiveHelper.width(14))]
                      : const [],
                ),
              },
            ),
            Positioned(
              left: ResponsiveHelper.width(16),
              right: ResponsiveHelper.width(16),
              top: ResponsiveHelper.height(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.currentStep != null) _buildTurnBanner(),
                  SizedBox(height: ResponsiveHelper.height(12)),
                  _buildModeSelector(),
                ],
              ),
            ),
            MapTypeDropdown(
              selectedType: _selectedMapType,
              onChanged: (type) => setState(() => _selectedMapType = type),
            ),
            Positioned(
              right: ResponsiveHelper.width(16),
              bottom: ResponsiveHelper.height(110),
              child: _buildSideControls(),
            ),
            Positioned(
              left: ResponsiveHelper.width(16),
              bottom: ResponsiveHelper.height(110),
              child: _buildSpeedBadge(),
            ),
            if (controller.routeInfo.value != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTurnBanner() {
    final step = controller.currentStep;
    if (step == null) return const SizedBox.shrink();
    final next = controller.nextStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.width(16),
            vertical: ResponsiveHelper.height(14),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF00695C),
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_maneuverIcon(step.maneuver), color: Colors.white, size: ResponsiveHelper.iconSize(32)),
              SizedBox(width: ResponsiveHelper.width(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.distanceToTurnMeters.value > 0)
                      Text(
                        _formatMeters(controller.distanceToTurnMeters.value),
                        style: TextStyle(color: Colors.white70, fontSize: ResponsiveHelper.fontSize(12)),
                      ),
                    Text(
                      step.instruction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveHelper.fontSize(17),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        /// then instruction==================================================================
        if (next != null)
          Container(
            margin: EdgeInsets.only(
              left: ResponsiveHelper.width(16),
            top:ResponsiveHelper.width(16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.width(12),
              vertical: ResponsiveHelper.height(6),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ResponsiveHelper.borderRadius(12)),
                bottomRight: Radius.circular(ResponsiveHelper.borderRadius(12)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.then.tr,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: ResponsiveHelper.fontSize(12),color: AppColors.black),
                ),
                SizedBox(width: ResponsiveHelper.width(4)),
                Icon(_maneuverIcon(next.maneuver), size: ResponsiveHelper.iconSize(16)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final info = controller.routeInfo.value;
    if (info == null) return const SizedBox.shrink();

    final eta = info.durationSeconds != null
        ? DateFormat('h:mm a').format(DateTime.now().add(Duration(seconds: info.durationSeconds!)))
        : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.width(20),
        vertical: ResponsiveHelper.height(14),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveHelper.borderRadius(20)),
          topRight: Radius.circular(ResponsiveHelper.borderRadius(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                radius: ResponsiveHelper.borderRadius(22),
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.close, color: Colors.black87),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    info.durationText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveHelper.fontSize(20)),
                  ),
                  SizedBox(height: ResponsiveHelper.height(2)),
                  Text(
                    eta != null ? '${info.distanceText} • $eta' : info.distanceText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: ResponsiveHelper.fontSize(13)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.fitRouteBounds,
              child: CircleAvatar(
                radius: ResponsiveHelper.borderRadius(22),
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.alt_route, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideControls() {
    return Column(
      children: [
        _buildCompassButton(),
        SizedBox(height: ResponsiveHelper.height(10)),
        Obx(
          () => _PulsingVoiceButton(
            isOn: controller.isVoiceOn.value,
            onTap: controller.toggleVoice,
          ),
        ),
      ],
    );
  }

  /// North-up → small "N" compass face; rotated map → red arrow rotated to
  /// keep pointing at true north. Tapping either resets to north-up.
  Widget _buildCompassButton() {
    return Obx(() {
      final bearing = controller.cameraBearing.value;
      final isNorthUp = bearing.abs() < 1;

      return GestureDetector(
        onTap: controller.recenterNorth,
        child: Container(
          width: ResponsiveHelper.width(44),
          height: ResponsiveHelper.width(44),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isNorthUp
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'N',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(9),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(Icons.arrow_drop_up, color: Colors.redAccent, size: ResponsiveHelper.iconSize(16)),
                  ],
                )
              : Transform.rotate(
                  angle: -bearing * (math.pi / 180),
                  child: Icon(Icons.navigation, color: Colors.redAccent, size: ResponsiveHelper.iconSize(22)),
                ),
        ),
      );
    });
  }

  ///speed=============================
  Widget _buildSpeedBadge() {
    return Obx(() {
      final speed = controller.speedKmh.value.round();
      return Container(
        width: ResponsiveHelper.width(56),
        height: ResponsiveHelper.width(56),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$speed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveHelper.fontSize(16),color: AppColors.black),
            ),
            Text(
              'km/h',
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(9), color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TravelMode.values.map((mode) {
          final isSelected = controller.selectedMode.value == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeMode(mode),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.width(4)),
                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(8)),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      size: ResponsiveHelper.iconSize(20),
                    ),
                    SizedBox(height: ResponsiveHelper.height(2)),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(11),
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String? secondaryLabel,
    VoidCallback? onSecondaryAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: ResponsiveHelper.iconSize(56), color: Colors.grey.shade400),
            SizedBox(height: ResponsiveHelper.height(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: ResponsiveHelper.fontSize(15)),
            ),
            SizedBox(height: ResponsiveHelper.height(20)),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12))),
                padding: ResponsiveHelper.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
            ),
            if (secondaryLabel != null && onSecondaryAction != null) ...[
              SizedBox(height: ResponsiveHelper.height(8)),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryLabel, style: const TextStyle(color: AppColors.blue)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Voice-guidance toggle button — pulses gently while on, same as the
/// speaker button's "listening" state in Google Maps navigation.
class _PulsingVoiceButton extends StatefulWidget {
  final bool isOn;
  final VoidCallback onTap;

  const _PulsingVoiceButton({required this.isOn, required this.onTap});

  @override
  State<_PulsingVoiceButton> createState() => _PulsingVoiceButtonState();
}

class _PulsingVoiceButtonState extends State<_PulsingVoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _scale =
      Tween(begin: 1.0, end: 1.18).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

  @override
  void initState() {
    super.initState();
    if (widget.isOn) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOn) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: widget.isOn ? _scale.value : 1.0,
          child: child,
        ),
        child: Container(
          width: ResponsiveHelper.width(44),
          height: ResponsiveHelper.width(44),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isOn ? Icons.record_voice_over : Icons.voice_over_off,
            color: widget.isOn ? AppColors.blue : Colors.black87,
            size: ResponsiveHelper.iconSize(20),
          ),
        ),
      ),
    );
  }
}
