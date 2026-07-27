import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/feature/map/controller/save_parking_controller.dart';
import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// Standalone Google Map tab — fetches nearby parking spots the same way
/// Home does and shows the same tap-to-details card, but through its own
/// SaveParkingController instance so nothing is shared with Home's screen.
class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  late final SaveParkingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SaveParkingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  @override
  void dispose() {
    Get.delete<SaveParkingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              key: const ValueKey<Object>('save_parking_google_map'),
              onMapCreated: _controller.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _controller.gpsPosition.value ?? MapScreen.kInitialMapTarget,
                zoom: 20,
              ),
              markers: {..._controller.markers},
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          Obx(
            () => _controller.isLocating.value
                ? const LocatingBanner()
                : const SizedBox.shrink(),
          ),

          Obx(
            () => _controller.isLoading.value
                ? const FetchingParkingBanner()
                : const SizedBox.shrink(),
          ),

          Obx(() {
            final selected = _controller.selectedReport.value;
            if (selected == null) return const SizedBox.shrink();
            return Positioned(
              left: 8,
              right: 8,
              bottom: ResponsiveHelper.spacing(115),
              child: ParkingReportDropdown(
                report: selected,
                onClose: _controller.clearSelectedReport,
              ),
            );
          }),
        ],
      ),
    );
  }
}
