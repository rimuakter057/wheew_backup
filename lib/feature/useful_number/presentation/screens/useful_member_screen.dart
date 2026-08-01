import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/useful_number/controller/useful_number_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class UsefulMemberScreen extends StatefulWidget {
  const UsefulMemberScreen({super.key});

  @override
  State<UsefulMemberScreen> createState() => _UsefulMemberScreenState();
}

class _UsefulMemberScreenState extends State<UsefulMemberScreen> {
  late final UsefulNumberController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ✅ এখানে Get.put() — controller তৈরি হয় এবং register হয়
    controller = Get.put(UsefulNumberController());

    debugPrint('🟢 [UsefulMemberScreen][initState] Screen initialized');
    debugPrint('🟢 [UsefulMemberScreen][initState] Calling controller.init()');

    // screen open হলেই api call
    controller.init();

    // scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🔴 [UsefulMemberScreen][dispose] Screen disposed');
    _scrollController.dispose();
    // controller GetX নিজে dispose করবে (Get.put ব্যবহার করলে)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: ResponsiveHelper.iconSize(20),
            color: Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.usefulNumber.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.titleFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // ─── Initial Loading ───────────────────────────
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ─── Error State ───────────────────────────────
        if (controller.error.value != null && controller.numbers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    controller.error.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child:   Text(AppStrings.retry.tr),
                ),
              ],
            ),
          );
        }

        // ─── Empty State ───────────────────────────────
        if (controller.numbers.isEmpty) {
          return  Center(
            child: Text(
              AppStrings.noUsefulNumbersFound.tr,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // ─── List ──────────────────────────────────────
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryBackgroundGradient
          ),
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: ResponsiveHelper.all(10),
              itemCount:
              controller.numbers.length + (controller.hasNextPage ? 1 : 0),
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                if (index == controller.numbers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = controller.numbers[index];
                return _UsefulNumberTile(
                  title: item.title,
                  phone: item.phone,
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

// ─── Tile Widget ──────────────────────────────────────────────────────────────

class _UsefulNumberTile extends StatelessWidget {
  final String title;
  final String phone;

  const _UsefulNumberTile({
    required this.title,
    required this.phone,
  });

  Future<void> _callNumber(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        CustomSnackbar.error(context: context, message: 'Could not launch dialer.');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.error(context: context, message: 'Could not launch dialer.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.spacing(12),
        horizontal: ResponsiveHelper.spacing(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.spacing(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(12),
              ),
            ),
            child: Icon(
              Icons.phone_outlined,
              color: AppColors.blue,
              size: ResponsiveHelper.iconSize(24),
            ),
          ),
          SizedBox(width: ResponsiveHelper.spacing(15)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(13),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callNumber(context),
            child: Container(
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
          ),
        ],
      ),
    );
  }
}