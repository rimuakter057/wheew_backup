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
      // ── Shimmer loading ─────────────────────────────
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

      // ── Empty ───────────────────────────────────────
      if (widget.chatController.presetMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      // ── Chips ───────────────────────────────────────
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
            debugPrint(
                "englisg language===========================${preset.message}"
            );
            debugPrint(
              "it language===========================${preset.messageIt}"
            );
            return GestureDetector(
              onTap: () {
                final isItalian = Get.locale?.languageCode == 'it';
                widget.chatController.messageController.text =
                isItalian ? preset.messageIt : preset.message;

                widget.chatController.messageController.selection =
                    TextSelection.fromPosition(
                      TextPosition(
                        offset: widget
                            .chatController.messageController.text.length,
                      ),
                    );

              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(14),
                  vertical: ResponsiveHelper.padding(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(20),
                  ),
                  border: Border.all(
                    color: AppColors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                    Get.locale?.languageCode == 'it'
                        ? preset.messageIt
                        : preset.message,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(12),
                    color: AppColors.blue,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Shimmer Chip ──────────────────────────────────────────────
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
            color: AppColors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(20),
            ),
          ),
        ),
      ),
    );
  }
}