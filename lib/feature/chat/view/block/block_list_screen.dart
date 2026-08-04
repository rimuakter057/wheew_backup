// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../repository/chat_controller.dart';
import '../widgets/chat_tile.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final ChatController controller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();

    /// Socket init (ONLY ONCE)
    if (!AppSocket.isConnected) {
      AppSocket.init(
        onSocketConnect: () {
          debugPrint('Socket connected from ChatListScreen');
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSocketListeners();
      controller.fetchBlockList(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Text(
            AppStrings.blockedUser5.tr,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: ResponsiveHelper.fontSize(20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Obx(() {
          /// First load
          if (controller.isLoadingBlockList.value &&
              controller.userBlockList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Empty state
          if (controller.userBlockList.isEmpty) {
            return Center(
              child: Text(
                AppStrings.emptyBlockList.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
                  itemCount: controller.userBlockList.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade100,
                    height: 24,
                    thickness: 1,
                    indent: 60,
                  ),
                  itemBuilder: (context, index) {
                    final block = controller.userBlockList[index];
                    final user = block.blockedUser;
                    final blockedUserId = block.blockedUserId;

                    return Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                ImageHandler.imagesHandle(
                                  user?.avatar ?? AppConst.unknown,
                                  isProfile: true,
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.nickName ?? "Unknown",
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveHelper.fontSize(16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${AppStrings.blocked.tr} ${formatTime(block.createdAt ?? "")}",
                                style: context.bodySmall.copyWith(color: AppColors.greyText)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unblock button
                        GestureDetector(
                          onTap: () {
                            controller.unBlock(blockedUserId!, context);
                            controller.isBlockedByMe.value = false;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.blue,
                                  AppColors.darBlue,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              AppStrings.unblock.tr,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.fontSize(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
