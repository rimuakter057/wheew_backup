import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class UsefulMemberScreen extends StatelessWidget {
  const UsefulMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ResponsiveHelper ইনিশিয়ালাইজ করা হচ্ছে
    ResponsiveHelper.init(context);

    // ইমারজেন্সি ডাটা লিস্ট
    final List<Map<String, dynamic>> emergencyNumbers = [
      {'title': 'Police', 'subtitle': '911', 'icon': Icons.shield_outlined},
      {'title': 'Ambulance', 'subtitle': '911', 'icon': Icons.favorite_border},
      {'title': 'Fire Service', 'subtitle': '911', 'icon': Icons.local_fire_department_outlined},
      {'title': 'Roadside Assistance', 'subtitle': '1-800-AAA-HELP', 'icon': Icons.build_outlined},
      {'title': 'Highway Patrol', 'subtitle': '*CHP (#247)', 'icon': Icons.directions_car_filled_outlined},
      {'title': 'Poison Control', 'subtitle': '1-800-222-1222', 'icon': Icons.warning_amber_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // হালকা গ্রে ব্যাকগ্রাউন্ড
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: ResponsiveHelper.iconSize(20), color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Useful Number',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.titleFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        shrinkWrap: true,
        itemCount: emergencyNumbers.length,
        padding: ResponsiveHelper.all(10),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final item = emergencyNumbers[index];
          return EmergencyTile(
            title: item['title'],
            subtitle: item['subtitle'],
            icon: item['icon'],
          );
        },
      ),
    );
  }
}

class EmergencyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmergencyTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.spacing(12),
        horizontal: ResponsiveHelper.spacing(8),
      ),
      child: Row(
        children: [
          // আইকন কন্টেইনার
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.spacing(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF), // হালকা নীল ব্যাকগ্রাউন্ড
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
            ),
            child: Icon(
              icon,
              color: AppColors.blueClient,
              size: ResponsiveHelper.iconSize(24),
            ),
          ),
          SizedBox(width: ResponsiveHelper.spacing(15)),
          // টেক্সট কন্টেন্ট
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(color: AppColors.black,fontWeight: FontWeight.w400)
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(13),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // কল বাটন
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
            decoration: BoxDecoration(
              color: AppColors.greyBorder,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_in_talk,
              size: ResponsiveHelper.iconSize(18),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}