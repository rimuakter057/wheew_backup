// widgets/group_preset_messages.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class GroupPresetMessages extends StatefulWidget {
  final ChatController controller;

  const GroupPresetMessages({super.key, required this.controller});

  @override
  State<GroupPresetMessages> createState() => _GroupPresetMessagesState();
}


class _GroupPresetMessagesState extends State<GroupPresetMessages> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // â”€â”€ Shimmer loading state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      if (widget.controller.isPresetLoading.value) {
        return SizedBox(
          height: ResponsiveHelper.height(40),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(16),
            ),
            itemCount: 5,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveHelper.spacing(8)),
            itemBuilder: (_, __) => _ShimmerChip(onEnd: () => setState(() {})),
          ),
        );
      }

      // â”€â”€ Empty state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      if (widget.controller.presetMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      // â”€â”€ Preset chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      return SizedBox(
        height: ResponsiveHelper.height(40),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
          ),
          itemCount: widget.controller.presetMessages.length,
          separatorBuilder: (_, __) =>
              SizedBox(width: ResponsiveHelper.spacing(8)),
          itemBuilder: (context, index) {
            final preset = widget.controller.presetMessages[index];
            final isAlert = preset.type.toUpperCase() == 'ALERT';
            final isItalian = Get.locale?.languageCode == 'it';
            final text = isItalian ? preset.messageIt : preset.message;

            final Color baseColor = isAlert ? AppColors.red : AppColors.blue;
            final IconData icon = isAlert ? Icons.warning_amber_rounded : Icons.message_outlined;

            return GestureDetector(
              onTap: () {
                widget.controller.messageController.text = text;
                widget.controller.messageController.selection =
                    TextSelection.fromPosition(
                  TextPosition(
                    offset: widget.controller.messageController.text.length,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(14),
                  vertical: ResponsiveHelper.padding(8),
                ),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(20),
                  ),
                  border: Border.all(
                    color: baseColor.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: baseColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        color: baseColor,
                        fontWeight: isAlert ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ShimmerChip extends StatelessWidget {
  final VoidCallback onEnd;

  const _ShimmerChip({required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 900),
      onEnd: onEnd,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: ResponsiveHelper.width(90),
            height: ResponsiveHelper.height(36),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(20),
              ),
            ),
          ),
        );
      },
    );
  }
}


