import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platchatapp/feature/map/controller/map_controller.dart';
import 'package:platchatapp/feature/map/model/saved_parking_model.dart';
import 'package:platchatapp/feature/map/presentation/widgets/drop_pin_button.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_initial_shimmer.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_loading_banners.dart';
import 'package:platchatapp/feature/map/presentation/widgets/map_type_dropdown.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_info_dialog.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_report_dropdown.dart';
import 'package:platchatapp/feature/map/presentation/widgets/raduis_filter_sheet.dart';
import 'package:platchatapp/feature/map/presentation/widgets/radius_filter_button.dart';
import 'package:platchatapp/feature/map/utils/map_debug.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/utils/toast_message/toast_message.dart';

import '../widgets/location_of_promt.dart';
import '../widgets/parking_location_card.dart';
import '../widgets/picking-location_banner.dart';

/// Which flow triggered "pick on map" mode, so we know which UI to
/// reopen once the user actually taps a point on the map.
enum _PickingPurpose { report, save }

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

  /// Tracks which flow (report-a-spot vs save-my-parking) started the
  /// "pick on map" mode, so _onMapTapped knows which UI to reopen.
  _PickingPurpose? _pickingPurpose;

  final Set<Marker> _markers = {};

  late final ParkingReportController _parkingCtrl;

  // ── "Save my parking" form state ──────────────────────────────────────
  final TextEditingController _durationController = TextEditingController();
  String _selectedParkingType = 'FREE';
  bool _durationHasError = false;
  String _durationErrorText = 'Time is required';

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
    _durationController.dispose();
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

    // Fetch the user's own saved parking spot (GET /park-relay/saved-parking/me)
    await _parkingCtrl.fetchMySavedParking();

    if (!mounted) return;

    final location = _gpsPosition;

    if (location == null) {
      mapDebug('No GPS — skipping parking fetch');
      return;
    }

    // Fetch nearby reported parking spots
    await _parkingCtrl.fetchParkingReport(
      latitude: location.latitude,
      longitude: location.longitude,
      radius: _selectedRadiusMeter,
    );
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

  void _toggleParkingPin() {
    HapticFeedback.mediumImpact();
    _pickedLocation = null;
    _stopPickingLocation();
    mapDebug('parking report dialog open');
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
          _startPickingLocation(purpose: _PickingPurpose.report);
        },
        onSubmit: () async {
          Navigator.of(context).pop();
          _stopPickingLocation();

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
          _stopPickingLocation();
        },
      ),
    );
  }


  void _showSavedParkingDetailsSheet(SavedParkingModel parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D72E8).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_parking_rounded,
                          color: Color(0xFF3D72E8),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'My Saved Parking',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              _buildDetailRow(Icons.gps_fixed, 'Accuracy',
                  '${parking.accuracy?.toStringAsFixed(1) ?? "10"} m'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.speed, 'Confidence',
                  '${((parking.confidence ?? 0.91) * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.source, 'Source', parking.source ?? 'AUTO'),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Saved Time',
                parking.createdAt != null
                    ? _formatDateTime(parking.createdAt!)
                    : 'N/A',
              ),

              if (parking.parkingSession != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.attach_money_rounded,
                  'Parking Type',
                  parking.parkingSession!.costType ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.timer_rounded,
                  'Duration',
                  parking.parkingSession!.durationMin != null
                      ? '${parking.parkingSession!.durationMin} mins'
                      : 'N/A',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.info_outline_rounded,
                  'Session Status',
                  parking.parkingSession!.status ?? 'N/A',
                ),
                if (parking.parkingSession!.expiresAt != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.event_busy_rounded,
                    'Expires At',
                    _formatDateTime(parking.parkingSession!.expiresAt!),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final link = parking.googleMapsWalkingLink;
                    if (link != null && link.isNotEmpty) {
                      final uri = Uri.parse(link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        showCustomSnackBar('Could not launch walking directions',
                            isError: true);
                      }
                    } else {
                      showCustomSnackBar('Navigation link not available',
                          isError: true);
                    }
                  },
                  icon: const Icon(Icons.directions_walk_rounded,
                      color: Colors.white),
                  label: Text(
                    'Start Walking Navigation',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D72E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2, "0")} '
          '(${dateTime.day}/${dateTime.month}/${dateTime.year})';
    } catch (_) {
      return isoString;
    }
  }

  void _showSaveParkingSheet() {
    _durationHasError = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Park My Car',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickedLocation = null;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF475569),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pickedLocation != null
                            ? 'Using picked location'
                            : 'Using current location',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location row with "Pick on map" action
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _pickedLocation != null
                                  ? Icons.location_on_rounded
                                  : Icons.gps_fixed_rounded,
                              color: const Color(0xFF3D72E8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _pickedLocation != null
                                    ? 'Picked location set'
                                    : 'Using current location',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _startPickingLocation(
                                    purpose: _PickingPurpose.save);
                              },
                              child: Text(
                                'Pick on map',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3D72E8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Parking Type',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTypeButton('FREE', setDialogState),
                            const SizedBox(width: 4),
                            _buildTypeButton('PAID', setDialogState),
                          ],
                        ),
                      ),

                      if (_selectedParkingType == 'PAID') ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) {
                            if (_durationHasError) {
                              setDialogState(() => _durationHasError = false);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Duration (minutes)',
                            filled: true,
                            fillColor: const Color(0xFFF4F6FB),
                            errorText:
                            _durationHasError ? _durationErrorText : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: _durationHasError
                                  ? const BorderSide(
                                  color: Color(0xFFEF4444), width: 1)
                                  : BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _durationHasError
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF3D72E8),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _pickedLocation = null;
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                side: BorderSide(
                                    color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              final isSaving =
                                  _parkingCtrl.isLoadingSaveParking.value;
                              return ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                  if (_selectedParkingType == 'PAID') {
                                    final input = _durationController.text
                                        .trim();
                                    final parsed = int.tryParse(input);
                                    if (input.isEmpty) {
                                      setDialogState(() {
                                        _durationHasError = true;
                                        _durationErrorText =
                                        'Time is required';
                                      });
                                      showCustomSnackBar(
                                        'Time is required',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (parsed == null || parsed <= 0) {
                                      setDialogState(() {
                                        _durationHasError = true;
                                        _durationErrorText =
                                        'Enter a valid number';
                                      });
                                      showCustomSnackBar(
                                        'Enter a valid number',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (parsed < 15) {
                                      setDialogState(() {
                                        _durationHasError = true;
                                        _durationErrorText =
                                        'Minimum 15 minutes required';
                                      });
                                      showCustomSnackBar(
                                        'Minimum 15 minutes required',
                                        isError: true,
                                      );
                                      return;
                                    }
                                  }
                                  _submitParking(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D72E8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  _pickedLocation != null
                                      ? 'Save Picked Location'
                                      : 'Save My Location',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeButton(String type, StateSetter setSheetState) {
    bool isSelected = _selectedParkingType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setSheetState(() => _selectedParkingType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D72E8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              type,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF8F9BB3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitParking(BuildContext sheetContext) async {
    final location = _pickedLocation ?? _gpsPosition;
    if (location == null) {
      showCustomSnackBar(
        'Location not available. Please wait for GPS or pick on map.',
        isError: true,
      );
      return;
    }

    int? durationMin;
    if (_selectedParkingType == 'PAID') {
      final input = _durationController.text.trim();
      if (input.isEmpty) {
        showCustomSnackBar('Time is required', isError: true);
        return;
      }
      durationMin = int.tryParse(input);
      if (durationMin == null || durationMin <= 0) {
        showCustomSnackBar('Enter a valid number', isError: true);
        return;
      }
      if (durationMin < 15) {
        showCustomSnackBar('Minimum 15 minutes required', isError: true);
        return;
      }
    }

    final success = await _parkingCtrl.saveMyParking(
      latitude: location.latitude,
      longitude: location.longitude,
      parkingType: _selectedParkingType,
      durationMin: durationMin,
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context);
      }
      showCustomSnackBar('Parking location saved successfully!', isError: false);
      _durationController.clear();
      setState(() {
        _pickedLocation = null;
      });

      final mySaved = _parkingCtrl.mySavedParking.value;
      if (mySaved != null &&
          mySaved.latitude != null &&
          mySaved.longitude != null &&
          _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(mySaved.latitude!, mySaved.longitude!),
            16,
          ),
        );
      }
    } else {
      showCustomSnackBar(
        _parkingCtrl.submitMessage.value.isNotEmpty
            ? _parkingCtrl.submitMessage.value
            : 'Failed to save parking location',
        isError: true,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Shared "pick a location on the map" mechanics (used by both flows)
  // ══════════════════════════════════════════════════════════════════════

  void _startPickingLocation({required _PickingPurpose purpose}) {
    if (!mounted) return;

    _pickingPurpose = purpose;

    setState(() {
      _isPickingLocation = true;
    });

    showCustomSnackBar(
      'Tap on the map to select a location',
      isError: false,
    );
  }

  void _stopPickingLocation() {
    if (!mounted) return;
    if (_isPickingLocation) {
      setState(() {
        _isPickingLocation = false;
      });
    }
    _pickingPurpose = null;
  }

  void _onMapTapped(LatLng position) {
    if (!_isPickingLocation) {
      _parkingCtrl.clearSelectedReport();
      return;
    }

    if (!mounted) return;

    final purpose = _pickingPurpose;

    setState(() {
      _pickedLocation = position;
      _isPickingLocation = false;
    });
    _pickingPurpose = null;

    HapticFeedback.selectionClick();

    mapDebug(
      'picked location '
          'lat=${position.latitude.toStringAsFixed(6)} '
          'lng=${position.longitude.toStringAsFixed(6)}',
    );

    // Reopen whichever flow started the picking mode.
    if (purpose == _PickingPurpose.save) {
      _showSaveParkingSheet();
    } else {
      _showParkingDialog();
    }
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
              LocationOffPrompt(
                onEnableLocation: () async {
                  await Geolocator.openLocationSettings();
                },
              )
            else if (_isLocating && _gpsPosition == null)
              const MapInitialShimmer()
            else
              Obx(() {
                final mySaved = _parkingCtrl.mySavedParking.value;
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
                  if (mySaved != null &&
                      mySaved.latitude != null &&
                      mySaved.longitude != null)
                    Marker(
                      markerId: const MarkerId('my_saved_parking'),
                      position: LatLng(mySaved.latitude!, mySaved.longitude!),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                      infoWindow: const InfoWindow(
                        title: 'My Saved Parking',
                        snippet: 'Tap to view details & route',
                      ),
                      onTap: () {
                        _showSavedParkingDetailsSheet(mySaved);
                      },
                    ),
                };

                return GoogleMap(
                  mapType: _parkingCtrl.selectedMapType.value,
                  key: const ValueKey<Object>('wheew_google_map'),
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
            if (_isPickingLocation) const PickingLocationBanner(),

            /// ── Parking fetching indicator ────────────────────────────────
            Obx(
                  () => _parkingCtrl.isLoadingShowDetails.value
                  ? const FetchingParkingBanner()
                  : const SizedBox.shrink(),
            ),

            /// ── Selected reported parking info card ─────────────────────
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

            /// ── Map Type Dropdown ───────────────────────────────────────
            Obx(
                  () => MapTypeDropdown(
                selectedType: _parkingCtrl.selectedMapType.value,
                onChanged: _parkingCtrl.changeMapType,
              ),
            ),

            /// ── Radius filter button ──────────────────────────────────────
            RadiusFilterButton(onPressed: _showRadiusFilterSheet),

            /// ── Action buttons cluster (Report Spot / Save My Parking) ─────
            Positioned(
              right: ResponsiveHelper.padding(20),
              bottom: ResponsiveHelper.padding(140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionPillButton(
                    label: 'Add Parking Spot',
                    icon: Icons.add_location_alt_rounded,
                    gradientColors: const [
                      Color(0xFFFF8A3D),
                      Color(0xFFF5590B),
                    ],
                    onPressed: _toggleParkingPin,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(14)),
                  _ActionPillButton(
                    label: 'Park My Car',
                    icon: Icons.local_parking_rounded,
                    gradientColors: const [
                      Color(0xFF4E8CFF),
                      Color(0xFF2E5FD9),
                    ],
                    onPressed: _showSaveParkingSheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact, professional pill-shaped action button with a soft gradient,
/// circular icon badge and elevated shadow. Used for the floating map
/// actions (Report Spot / Save My Parking) so each action has a distinct,
/// unmistakable visual identity while staying consistent in shape/spacing.
class _ActionPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _ActionPillButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}