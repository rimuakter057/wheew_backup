import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/map/model/saved_parking_model.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class SavedParkingDetailsBottomSheet extends StatelessWidget {
  final SavedParkingModel parking;
  final Function(String, {bool isError}) showCustomSnackBar;

  const SavedParkingDetailsBottomSheet({
    super.key,
    required this.parking,
    required this.showCustomSnackBar,
  });

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2, "0")} '
          '(${dateTime.day}/${dateTime.month}/${dateTime.year})';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveHelper.iconSize(20),
          color: Colors.grey.shade600,
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(24)),
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
                    padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D72E8).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_parking_rounded,
                      color: const Color(0xFF3D72E8),
                      size: ResponsiveHelper.iconSize(24),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Text(
                    'My Saved Parking',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: ResponsiveHelper.iconSize(24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),

          _buildDetailRow(
            Icons.attach_money_rounded,
            'Parking Type',
            parking.costType ?? parking.parkingSession?.costType ?? 'FREE',
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),
          _buildDetailRow(
            Icons.timer_rounded,
            'Duration',
            (parking.durationMin ?? parking.parkingSession?.durationMin) != null
                ? '${parking.durationMin ?? parking.parkingSession!.durationMin} mins'
                : 'N/A',
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),
          _buildDetailRow(
            Icons.info_outline_rounded,
            'Session Status',
            parking.parkingSession?.status ?? ((parking.costType ?? parking.parkingSession?.costType) == 'PAID' ? 'ACTIVE' : 'N/A'),
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),
          _buildDetailRow(
            Icons.event_busy_rounded,
            'Expires At',
            (parking.expiresAt ?? parking.parkingSession?.expiresAt) != null
                ? _formatDateTime(parking.expiresAt ?? parking.parkingSession!.expiresAt!)

                : 'N/A',
          ),

          SizedBox(height: ResponsiveHelper.spacing(24)),

          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.height(50),
            child: ElevatedButton.icon(
              onPressed: () {
                final lat = parking.latitude ?? parking.parkingSession?.latitude;
                final lng = parking.longitude ?? parking.parkingSession?.longitude;
                if (lat != null && lng != null) {
                  Navigator.pop(context);
                  context.pushNamed(
                    RouteName.inAppNavigation,
                    extra: {'destination': LatLng(lat, lng)},
                  );
                } else {
                  showCustomSnackBar('Navigation location not available',
                      isError: true);
                }
              },
              icon: Icon(
                Icons.directions_walk_rounded,
                color: Colors.white,
                size: ResponsiveHelper.iconSize(20),
              ),
              label: Text(
                'Start Walking Navigation',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D72E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
