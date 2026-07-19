import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/navigation/controller/in_app_navigation_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

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
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600,fontSize: 16),
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

        return Stack(
          children: [
            GoogleMap(
              mapType: _selectedMapType,
              onMapCreated: controller.onMapCreated,
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
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: controller.routePoints,
                  color: AppColors.blue,
                  width: 5,
                ),
              },
            ),
            Positioned(
              left: ResponsiveHelper.width(16),
              right: ResponsiveHelper.width(16),
              top: ResponsiveHelper.height(16),
              child: _buildModeSelector(),
            ),
            MapTypeDropdown(
              selectedType: _selectedMapType,
              onChanged: (type) => setState(() => _selectedMapType = type),
            ),
            if (controller.routeInfo.value != null)
              Positioned(
                left: ResponsiveHelper.width(16),
                right: ResponsiveHelper.width(16),
                bottom: ResponsiveHelper.height(16),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(controller.selectedMode.value.icon, color: AppColors.blue),
                      SizedBox(width: ResponsiveHelper.width(12)),
                      Expanded(
                        child: Builder(builder: (context) {
                          final duration = controller.routeInfo.value!.durationText;
                          final distance = controller.routeInfo.value!.distanceText;
                          final parts = [
                            if (duration.isNotEmpty) duration,
                            if (distance.isNotEmpty) distance,
                          ];

                          return Row(
                            children: [
                              for (var i = 0; i < parts.length; i++) ...[
                                if (i > 0) ...[
                                  SizedBox(width: ResponsiveHelper.width(8)),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveHelper.width(8)),
                                ],
                                Flexible(
                                  child: Text(
                                    parts[i],
                                    overflow: TextOverflow.ellipsis,
                                    style: i == 0
                                        ? const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.blue,
                                    )
                                        : TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }


  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(12),
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
            Icon(icon, size: 56, color: Colors.grey.shade400),
            SizedBox(height: ResponsiveHelper.height(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
            SizedBox(height: ResponsiveHelper.height(20)),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
