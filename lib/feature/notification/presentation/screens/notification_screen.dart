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

  String _formatTime(String sentAt) {
    try {
      final dt = DateTime.parse(sentAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return AppStrings.justNow.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hour ago';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  // ── Group notifications by date (Today / Yesterday / d-M-yyyy) ─
  String _sectionLabel(String sentAt) {
    try {
      final dt = DateTime.parse(sentAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(date).inDays;
      if (diff <= 0) return AppStrings.today.tr;
      if (diff == 1) return AppStrings.yesterday.tr;
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return AppStrings.today.tr;
    }
  }

  List<MapEntry<String, List<NotificationEvent>>> _groupByDate(
      List<NotificationEvent> items) {
    final Map<String, List<NotificationEvent>> map = {};
    for (final n in items) {
      map.putIfAbsent(_sectionLabel(n.sentAt), () => []).add(n);
    }
    return map.entries.toList();
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
          AppStrings.deleteNotifications.tr,
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
              AppStrings.deleteNotifications.tr,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.notificationBg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.height(8)),
              _buildHeader(),
              SizedBox(height: ResponsiveHelper.height(12)),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppColors.blue));
                  }

                  if (controller.notifications.isEmpty) {
                    return _buildEmpty();
                  }

                  final grouped = _groupByDate(controller.notifications);

                  return RefreshIndicator(
                    color: AppColors.blue,
                    onRefresh: () => controller.fetchNotifications(refresh: true),
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(16),
                      ),
                      children: [
                        for (final group in grouped) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveHelper.spacing(10),
                              top: ResponsiveHelper.spacing(4),
                            ),
                            child: Text(
                              group.key,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.notificationBoxGradient,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.borderRadius(20),
                              ),
                              border: Border.all(color: AppColors.notificationBoxBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < group.value.length; i++) ...[
                                  _NotificationCard(
                                    notification: group.value[i],
                                    formattedTime: _formatTime(group.value[i].sentAt),
                                    onMarkRead: () =>
                                        controller.markOneAsRead(group.value[i].id),
                                    onDelete: () async {
                                      await controller.deleteOne(group.value[i].id);
                                      CustomSnackbar.success(
                                        context: context,
                                        message: AppStrings.deleteSuccess.tr,
                                      );
                                    },
                                  ),
                                  if (i != group.value.length - 1)
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                      indent: ResponsiveHelper.width(16),
                                      endIndent: ResponsiveHelper.width(16),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(20)),
                        ],
                        Obx(() => controller.isLoadingMore.value
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(16)),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: AppColors.black),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppStrings.notification.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          Obx(() {
            final bool canMarkAllRead = controller.unreadCount.value > 0;
            final bool canDeleteAll = controller.notifications.isNotEmpty;
            if (!canMarkAllRead && !canDeleteAll) {
              return SizedBox(width: ResponsiveHelper.width(40));
            }
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: AppColors.black),
                onSelected: (value) {
                  if (value == 'markAll') {
                    controller.markAllAsRead();
                  } else if (value == 'deleteAll') {
                    _showDeleteAllDialog();
                  }
                },
                itemBuilder: (_) => [
                  if (canMarkAllRead)
                    PopupMenuItem(
                      value: 'markAll',
                      child: Text(
                        AppStrings.markAllRead.tr,
                        style: GoogleFonts.inter(color: AppColors.blue),
                      ),
                    ),
                  if (canDeleteAll)
                    PopupMenuItem(
                      value: 'deleteAll',
                      child: Text(
                        AppStrings.deleteNotifications.tr,
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
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
            color: Colors.grey.shade400,
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Text(
            AppStrings.notificationNotYet.tr,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.fontSize(16),
              color: Colors.grey.shade500,
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
  final String formattedTime;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
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
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: unread ? onMarkRead : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.padding(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  Row(
                    children: [
                      if (unread) ...[
                        Container(
                          width: ResponsiveHelper.width(6),
                          height: ResponsiveHelper.width(6),
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(6)),
                      ],
                      Text(
                        formattedTime,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveHelper.fontSize(11),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
