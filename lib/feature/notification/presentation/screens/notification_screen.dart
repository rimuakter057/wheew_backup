import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/feature/notification/models/notification_model.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMore &&
        !controller.isLoadingMore.value) {
      controller.fetchNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Icon per eventType ────────────────────────────────────────
  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CHAT_MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      case 'RATING':
        return Icons.star_outline_rounded;
      case 'GROUP':
        return Icons.group_outlined;
      case 'SYSTEM':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toUpperCase()) {
      case 'CHAT_MESSAGE':
        return AppColors.blue;
      case 'RATING':
        return Colors.amber;
      case 'GROUP':
        return Colors.green;
      case 'SYSTEM':
        return Colors.orange;
      default:
        return Colors.grey.shade500;
    }
  }

  String _formatTime(String sentAt) {
    try {
      final dt = DateTime.parse(sentAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  // ── Delete all confirmation ───────────────────────────────────
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
        ),
        title: Text(
        //  'delete all notifications'.tr,
          AppStrings.delete.tr,

          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
         AppStrings.deleteAllNotifications.tr,
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.fontSize(14),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel.tr),
          ),
          Obx(() => TextButton(
            onPressed: controller.isDeleting.value
                ? null
                : () async {
              Navigator.pop(ctx);
              await controller.deleteAll(context);
              CustomSnackbar.success( context:context, message: AppStrings.deleteSuccess.tr);
            },
            child: controller.isDeleting.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
            )
                : Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: (){
          context.pop();

        }, icon: Icon(Icons.arrow_back_ios,color: AppColors.black,)),
        title: Obx(() => Row(
          children: [
            Text(
           AppStrings.notification.tr,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.titleFontSize(18),
              ),
            ),
            if (controller.unreadCount.value > 0) ...[
              SizedBox(width: ResponsiveHelper.spacing(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.spacing(8),
                  vertical: ResponsiveHelper.spacing(2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                ),
                child: Text(
                  '${controller.unreadCount.value}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.fontSize(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        )),
        actions: [
          // Mark all read
          Obx(() {
            if (controller.unreadCount.value == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(
              AppStrings.markAllRead.tr,
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: ResponsiveHelper.fontSize(13),
                ),
              ),
            );
          }),
          // Delete all
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: _showDeleteAllDialog,
              icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.blue));
        }

        if (controller.notifications.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.spacing(12),
              horizontal: ResponsiveHelper.spacing(16),
            ),
            itemCount: controller.notifications.length + (controller.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: ResponsiveHelper.spacing(8)),
            itemBuilder: (context, index) {
              // Pagination loader
              if (index == controller.notifications.length) {
                return Obx(() => controller.isLoadingMore.value
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const SizedBox.shrink());
              }

              final notification = controller.notifications[index];
              return _NotificationCard(
                notification: notification,
                icon: _getIcon(notification.eventType),
                iconColor: _getIconColor(notification.eventType),
                formattedTime: _formatTime(notification.sentAt),
                onMarkRead: () => controller.markOneAsRead(notification.id),
                onDelete: () async {
                  await controller.deleteOne(notification.id);
                  CustomSnackbar.success(context: context, message: AppStrings.deleteSuccess.tr);
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: ResponsiveHelper.iconSize(64),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Text(
            'Notification Not Yet'.tr,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.fontSize(16),
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationEvent notification;
  final IconData icon;
  final Color iconColor;
  final String formattedTime;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.formattedTime,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ResponsiveHelper.spacing(20)),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ResponsiveHelper.padding(14)),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFEEF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          border: Border.all(
            color: unread ? AppColors.blue.withOpacity(0.2) : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: ResponsiveHelper.width(44),
                  height: ResponsiveHelper.width(44),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: ResponsiveHelper.iconSize(22)),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveHelper.fontSize(14),
                                fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.spacing(8)),
                          Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.fontSize(11),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(4)),
                      Text(
                        notification.message,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveHelper.fontSize(13),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(10)),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: ResponsiveHelper.spacing(6)),

            // Bottom row: mark-as-read checkbox + label, and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Checkbox + "Mark as read" text
                GestureDetector(
                  onTap: unread ? onMarkRead : null,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: unread ? Colors.transparent : AppColors.blue,
                          border: Border.all(
                            color: unread ? Colors.grey.shade400 : AppColors.blue,
                            width: 1.6,
                          ),
                        ),
                        child: unread
                            ? null
                            : const Icon(Icons.check, size: 13, color: Colors.white),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(8)),
                      Text(
                        unread ? 'mark as read'.tr : 'read'.tr,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveHelper.fontSize(12.5),
                          fontWeight: FontWeight.w500,
                          color: unread ? Colors.grey.shade600 : AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: ResponsiveHelper.iconSize(18),
                        color: Colors.red.shade400,
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(4)),
                      // Text(
                      //   'delete'.tr,
                      //   style: GoogleFonts.inter(
                      //     fontSize: ResponsiveHelper.fontSize(12.5),
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.red.shade400,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}