// widgets/message_preset_chips.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MessagePresetChips extends StatefulWidget {
  final ChatController chatController;

  const MessagePresetChips({super.key, required this.chatController});

  @override
  State<MessagePresetChips> createState() => _MessagePresetChipsState();
}

class _MessagePresetChipsState extends State<MessagePresetChips> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (widget.chatController.isPresetLoading.value) {
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
            itemBuilder: (_, __) =>
                _ShimmerChip(onEnd: () => setState(() {})),
          ),
        );
      }

     if (widget.chatController.presetMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      // â”€â”€ Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      return SizedBox(
        height: ResponsiveHelper.height(40),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
          ),
          itemCount: widget.chatController.presetMessages.length,
          separatorBuilder: (_, __) =>
              SizedBox(width: ResponsiveHelper.spacing(8)),
          itemBuilder: (context, index) {
            final preset = widget.chatController.presetMessages[index];
            final isAlert = preset.type.toUpperCase() == 'ALERT';
            final isItalian = Get.locale?.languageCode == 'it';
            final text = isItalian ? preset.messageIt : preset.message;

            final Color baseColor = isAlert ? AppColors.red : AppColors.blue;
            final IconData icon = isAlert ? Icons.warning_amber_rounded : Icons.message_outlined;

            return GestureDetector(
              onTap: () {
                widget.chatController.messageController.text = text;
                widget.chatController.messageController.selection =
                    TextSelection.fromPosition(
                      TextPosition(
                        offset: widget.chatController.messageController.text.length,
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

// â”€â”€ Shimmer Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ShimmerChip extends StatelessWidget {
  final VoidCallback onEnd;

  const _ShimmerChip({required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 900),
      onEnd: onEnd,
      builder: (context, value, _) => Opacity(
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
      ),
    );
  }
}


