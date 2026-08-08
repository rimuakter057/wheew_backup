import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/profile/repository/useful_number_model.dart';
import 'package:platchatapp/feature/useful_number/controller/useful_number_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
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

  // Fixed category order matching the Figma layout — any unlisted category
  // (future backend additions) falls back after these, alphabetically.
  static const List<String> _categoryOrder = [
    'EMERGENCY_CONTACT',
    'VEHICLE_ASSISTANCE',
    'TRAFFIC_AND_PARKING',
  ];

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

  String _categoryLabel(String category) {
    switch (category) {
      case 'EMERGENCY_CONTACT':
        return 'Emergency Contact';
      case 'VEHICLE_ASSISTANCE':
        return 'Vehicle Assistance';
      case 'TRAFFIC_AND_PARKING':
        return 'Traffic & Parking';
      default:
        return category
            .split('_')
            .map((w) => w.isEmpty ? '' : '${w[0]}${w.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  Map<String, List<UsefulNumber>> _groupByCategory(List<UsefulNumber> numbers) {
    final Map<String, List<UsefulNumber>> grouped = {};
    for (final n in numbers.where((n) => n.isActive)) {
      grouped.putIfAbsent(n.category, () => []).add(n);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return grouped;
  }

  List<String> _orderedCategories(Map<String, List<UsefulNumber>> grouped) {
    final rest = grouped.keys.where((c) => !_categoryOrder.contains(c)).toList()..sort();
    return [..._categoryOrder.where(grouped.containsKey), ...rest];
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
            color: AppColors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.usefulNumber.tr,
          style: TextStyle(
            color: AppColors.black,
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
                const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    controller.error.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.red),
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
              style: TextStyle(color: AppColors.grey),
            ),
          );
        }

        // ─── Grouped by category (Figma) ────────────────
        final grouped = _groupByCategory(controller.numbers);

        final categories = _orderedCategories(grouped);

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryBackgroundGradient

          ),
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scrollController,
              padding: ResponsiveHelper.symmetric(horizontal: 14, vertical: 12),
              children: [
                for (final category in categories) ...[
                  Padding(
                    padding: ResponsiveHelper.symmetric(horizontal: 6, vertical: 8),
                    child: Text(
                      _categoryLabel(category),
                      style: context.bodyLarge.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.containerGradient,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(16),
                      ),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < grouped[category]!.length; i++) ...[
                          _UsefulNumberTile(item: grouped[category]![i]),
                          if (i != grouped[category]!.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: const Color(0xFFE5E7EB),
                              indent: ResponsiveHelper.width(14),
                              endIndent: ResponsiveHelper.width(14),
                            ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                ],
                if (controller.hasNextPage)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─── Icon mapping (backend `icon` key → dedicated SVG asset) ────────────────
// One SVG per known key. Anything the backend sends that isn't one of these
// 9 falls back to 1 of 3 category-level icons instead of a generic one.

String _iconAssetForItem(UsefulNumber item) {
  switch (item.icon) {
    case 'police':
      return AssetsPath.usefulNumberPolice;
    case 'ambulance':
      return AssetsPath.usefulNumberAmbulance;
    case 'fire_truck':
      return AssetsPath.usefulNumberFireTruck;
    case 'women_helpline':
      return AssetsPath.usefulNumberWomenHelpline;
    case 'roadside_assistance':
      return AssetsPath.usefulNumberRoadsideAssistance;
    case 'tow_truck':
      return AssetsPath.usefulNumberTowTruck;
    case 'highway':
      return AssetsPath.usefulNumberHighway;
    case 'traffic_police':
      return AssetsPath.usefulNumberTrafficPolice;
    case 'parking':
      return AssetsPath.usefulNumberParking;
    default:
      return _categoryFallbackIcon(item.category);
  }
}

// 3 fallback icons — one per category — for any icon key the backend sends
// that isn't one of the 9 dedicated SVGs above.
String _categoryFallbackIcon(String category) {
  switch (category) {
    case 'EMERGENCY_CONTACT':
      return AssetsPath.usefulNumberPolice;
    case 'VEHICLE_ASSISTANCE':
      return AssetsPath.usefulNumberRoadsideAssistance;
    case 'TRAFFIC_AND_PARKING':
      return AssetsPath.usefulNumberTrafficPolice;
    default:
      return AssetsPath.usefulNumberPolice;
  }
}

// ─── Tile Widget ──────────────────────────────────────────────────────────────

class _UsefulNumberTile extends StatelessWidget {
  final UsefulNumber item;

  const _UsefulNumberTile({required this.item});

  Future<void> _callNumber(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: item.phone);
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
        horizontal: ResponsiveHelper.spacing(14),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            _iconAssetForItem(item),
            width: ResponsiveHelper.iconSize(22),
            height: ResponsiveHelper.iconSize(22),
            colorFilter: ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
          ),
          SizedBox(width: ResponsiveHelper.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.bodyMedium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(12),
                      color: AppColors.greyShade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: ResponsiveHelper.spacing(8)),
          GestureDetector(
            onTap: () => _callNumber(context),
            child: Card(
              elevation: 8,
              shadowColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(20),
                ),
              ),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: ResponsiveHelper.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(20),
                  ),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Call Now',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ResponsiveHelper.fontSize(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


