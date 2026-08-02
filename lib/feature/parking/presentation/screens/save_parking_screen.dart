import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class SaveParkingScreen extends StatelessWidget {
  const SaveParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: ResponsiveHelper.symmetric(horizontal: 20, vertical: 12),
            children: [
              Center(
                child: Text(
                  'Saved Parkings',
                  style: context.titleMedium.copyWith(color: AppColors.black)
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(20)),
              const ParkingLocationCard(
                title: 'Westfield Center',
                subtitle: 'Basement 2',
                badgeLabel: 'Standard',
                badgeIcon: Icons.local_parking_rounded,
                badgeColor: AppColors.paidBlue,
                distanceLabel: '350 m away',
                ratingLabel: '4.5',
                leftStatLabel: '2 spots',
                rightStatLabel: 'Free',
                rightStatIcon: Icons.money_off_rounded,
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              const ParkingLocationCard(
                title: 'Green Park Mall',
                subtitle: 'Side Parking',
                badgeLabel: 'Electric',
                badgeIcon: Icons.electric_bolt_rounded,
                badgeColor: AppColors.chargingGreen,
                distanceLabel: '250 m away',
                ratingLabel: '4.5',
                leftStatLabel: '2 spots',
                rightStatLabel: '\$20/hr',
                remainingTimeLabel: '00:30 min',
                remainingTimeSubLabel: 'remaining',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
