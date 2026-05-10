import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart'; // GoRouter ইম্পোর্ট করুন
import 'package:platchatapp/core/router/routes_name.dart'; // RouteName ইম্পোর্ট করুন
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/privacy_policy/help_suppoor_screen.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class ProfileNavScreen extends StatelessWidget {
   ProfileNavScreen({super.key});
  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'profile'.tr,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.titleFontSize(18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.maxContentWidth),
            padding: ResponsiveHelper.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildProfileCard(context), // context পাস করা হয়েছে
                SizedBox(height: ResponsiveHelper.spacing(20)),
                _buildMenuItems(context), // context পাস করা হয়েছে
                SizedBox(height: ResponsiveHelper.spacing(30)),
                _buildLogoutButton(context),
                SizedBox(height: ResponsiveHelper.spacing(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // প্রোফাইল ইমেজ দেখানোর জন্য নেভিগেশন
                  context.pushNamed(RouteName.showProfile, extra: ImageHandler.imagesHandle(AppConst.unknown));
                },
                child: CircleAvatar(
                  radius: ResponsiveHelper.width(40),
                  backgroundImage: NetworkImage(ImageHandler.imagesHandle(AppConst.unknown)),
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(RouteName.scanScreen),
                child: Container(
                  padding: ResponsiveHelper.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                  ),
                  child: Icon(Icons.qr_code_scanner, color: Colors.white, size: ResponsiveHelper.iconSize(24)),
                ),
              )
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(15)),
          Text(
            'John Doe',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.titleFontSize(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(5)),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orangeAccent, size: ResponsiveHelper.iconSize(18)),
              Text(' 4.9 (127)  ', style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.fontSize(14))),
              Icon(Icons.location_on, color: Colors.white70, size: ResponsiveHelper.iconSize(18)),
              Text(' California, USA', style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.fontSize(14))),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.person_outline,
        'title': 'profile'.tr,
        'onTap': () {
          context.pushNamed(RouteName.profile);
        }
      },
      {
        'icon': Icons.numbers,
        'title': 'useful_number'.tr,
        'onTap': () {
          context.pushNamed(RouteName.usefulMemberScreen);
        }
      },
      {
        'icon': Icons.description_outlined,
        'title': 'terms_and_conditions'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewScreen(url: ApiUrl.terms),
            ),
          );
        }
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'privacy_policy'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyPolicyScreen(url: ApiUrl.privacy),
            ),
          );
        }
      },
      {
        'icon': Icons.help_outline,
        'title': 'help_support'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HelpSupportScreen(),
            ),
          );
        }
      },
      {
        'icon': Icons.remove_circle_outline,
        'title': 'blocked_user5'.tr,
        'onTap': () {
          context.pushNamed(RouteName.block);
        }
      },
      {
        'icon': Icons.delete_outline,
        'title': 'delete'.tr,
        'onTap': () {
          context.pushNamed(RouteName.delete);
        }
      },
    ];

    return Column(
      children: [
        ...items.map((item) => Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item['icon'],
                size: ResponsiveHelper.iconSize(24),
                color: Colors.black54,
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(16),
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: item['onTap'],
            ),
            const Divider(height: 1),
          ],
        )),
        _buildLanguageDropdown(context),
      ],
    );
  }






   Widget _buildLanguageDropdown(BuildContext context) {
     return Column(
       children: [
         ListTile(
           contentPadding: EdgeInsets.zero,
           leading: Icon(
             Icons.translate,
             size: ResponsiveHelper.iconSize(24),
             color: Colors.black54,
           ),
           title: Text(
             'language'.tr,
             style: context.titleSmall.copyWith(
               fontSize: ResponsiveHelper.fontSize(16),
               fontWeight: FontWeight.w600,
             ),
           ),
           subtitle: Obx(
                 () => Text(
               languageController.currentLanguageDisplay,
               style: TextStyle(fontSize: ResponsiveHelper.fontSize(12)),
             ),
           ),
           trailing: Icon(
             Icons.chevron_right,
             size: ResponsiveHelper.iconSize(20),
           ),
           onTap: () => _showLanguageBottomSheet(context),
         ),
         const Divider(height: 1),
       ],
     );
   }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(55),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
          ),
        ),
        onPressed: () {
          // লগআউট করার পর ওয়েলকাম স্ক্রিনে নিয়ে যাওয়া
          context.goNamed(RouteName.welcome);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: ResponsiveHelper.iconSize(20)),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Text(
              'log_out'.tr,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }




  void _showLanguageBottomSheet(BuildContext context) {
    final controller = Get.find<LanguageController>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(20)),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(16)),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Text(
                  'language'.tr,
                  style: context.titleSmall.copyWith(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              SizedBox(height: ResponsiveHelper.spacing(12)),

                ...controller.availableLanguageNames.map((language) {
                  final isSelected = controller.isLanguageSelected(language);

                  return ListTile(
                    title: Text(language),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () async {
                      await controller.saveLanguage(language);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                }),
              ],
            );
          }),
        );
      },
    );
  }
}