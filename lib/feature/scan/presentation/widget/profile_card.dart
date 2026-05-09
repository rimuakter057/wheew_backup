import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.name, required this.rating, required this.address});
  final String name;
  final double rating;
  final String address;

  @override
  Widget build(BuildContext context) {


    return Center(
      child: Container(
        width: ResponsiveHelper.width(300),
        padding: ResponsiveHelper.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top handle line and Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                GestureDetector(
                  onTap: (){
                    context.pop();
                  },
                  child: CircleAvatar(
                    radius: ResponsiveHelper.iconSize(16),
                    backgroundColor: Colors.grey[100],
                    child: Icon(Icons.close,
                        size: ResponsiveHelper.iconSize(16),
                        color: Colors.black
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),

            // Profile Image
            CircleAvatar(
              radius: ResponsiveHelper.width(50),
              backgroundColor: Colors.blue[50],
              backgroundImage:  NetworkImage(AppConst.unknown), // আপনার ইমেজ লিঙ্ক দিন
            ),

            SizedBox(height: ResponsiveHelper.spacing(15)),

            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: ResponsiveHelper.titleFontSize(22),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            // Rating and Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.orange, size: ResponsiveHelper.iconSize(18)),
                SizedBox(width: 4),
                Text(
                rating.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.spacing(10)),
                Icon(Icons.location_on, color: Colors.grey, size: ResponsiveHelper.iconSize(18)),
                SizedBox(width: 4),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(25)),

            // Start Chat Button
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(55),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.chat_bubble_outline, size: ResponsiveHelper.iconSize(20)),
                label: Text(
                  'Start Chat',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueClient,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(15)),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}