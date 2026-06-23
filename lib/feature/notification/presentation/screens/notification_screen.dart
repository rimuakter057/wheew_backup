// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'notification_faq_controller.dart';
// import 'notification_model.dart';
//
// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   late final NotificationFaqController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(NotificationFaqController());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchNotifications(refresh: true);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'notifications'.tr,
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//             fontSize: ResponsiveHelper.titleFontSize(18),
//           ),
//         ),
//         actions: [
//           Obx(() {
//             if (controller.unreadCount.value == 0) return const SizedBox.shrink();
//             return TextButton(
//               onPressed: controller.markAllAsRead,
//               child: Text(
//                 'mark_all_read'.tr,
//                 style: TextStyle(
//                   color: AppColors.blue,
//                   fontSize: ResponsiveHelper.fontSize(13),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoadingNotification.value) {
//           return const Center(
//             child: CircularProgressIndicator(color: AppColors.blue),
//           );
//         }
//
//         if (controller.notifications.isEmpty) {
//           return _buildEmpty();
//         }
//
//         return RefreshIndicator(
//           color: AppColors.blue,
//           onRefresh: () => controller.fetchNotifications(refresh: true),
//           child: ListView.separated(
//             padding: EdgeInsets.symmetric(
//               vertical: ResponsiveHelper.spacing(12),
//               horizontal: ResponsiveHelper.spacing(16),
//             ),
//             itemCount: controller.notifications.length,
//             separatorBuilder: (_, __) =>
//                 SizedBox(height: ResponsiveHelper.spacing(8)),
//             itemBuilder: (context, index) {
//               return _NotificationCard(
//                 notification: controller.notifications[index],
//                 onTap: () {
//                   if (!controller.notifications[index].isRead) {
//                     controller.markOneAsRead(
//                         controller.notifications[index].id);
//                   }
//                 },
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_none_rounded,
//             size: ResponsiveHelper.iconSize(64),
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: ResponsiveHelper.spacing(16)),
//           Text(
//             'no_notifications'.tr,
//             style: GoogleFonts.inter(
//               fontSize: ResponsiveHelper.fontSize(16),
//               color: Colors.grey.shade400,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NotificationCard extends StatelessWidget {
//   final NotificationModel notification;
//   final VoidCallback onTap;
//
//   const _NotificationCard({
//     required this.notification,
//     required this.onTap,
//   });
//
//   IconData _getIcon(String? type) {
//     switch (type?.toLowerCase()) {
//       case 'message':
//         return Icons.chat_bubble_outline_rounded;
//       case 'rating':
//         return Icons.star_outline_rounded;
//       case 'group':
//         return Icons.group_outlined;
//       default:
//         return Icons.notifications_none_rounded;
//     }
//   }
//
//   Color _getIconColor(String? type) {
//     switch (type?.toLowerCase()) {
//       case 'message':
//         return AppColors.blue;
//       case 'rating':
//         return Colors.amber;
//       case 'group':
//         return Colors.green;
//       default:
//         return Colors.grey.shade500;
//     }
//   }
//
//   String _formatTime(String createdAt) {
//     try {
//       final dt = DateTime.parse(createdAt).toLocal();
//       final now = DateTime.now();
//       final diff = now.difference(dt);
//
//       if (diff.inMinutes < 1) return 'just_now'.tr;
//       if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//       if (diff.inHours < 24) return '${diff.inHours}h';
//       if (diff.inDays < 7) return '${diff.inDays}d';
//       return '${dt.day}/${dt.month}/${dt.year}';
//     } catch (_) {
//       return '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool unread = !notification.isRead;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.all(ResponsiveHelper.padding(14)),
//         decoration: BoxDecoration(
//           color: unread ? const Color(0xFFEEF4FF) : Colors.white,
//           borderRadius:
//           BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
//           border: Border.all(
//             color: unread
//                 ? AppColors.blue.withOpacity(0.2)
//                 : Colors.grey.shade100,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Icon ──────────────────────────────────────
//             Container(
//               width: ResponsiveHelper.width(44),
//               height: ResponsiveHelper.width(44),
//               decoration: BoxDecoration(
//                 color: _getIconColor(notification.type).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 _getIcon(notification.type),
//                 color: _getIconColor(notification.type),
//                 size: ResponsiveHelper.iconSize(22),
//               ),
//             ),
//             SizedBox(width: ResponsiveHelper.spacing(12)),
//
//             // ── Content ───────────────────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           notification.title,
//                           style: GoogleFonts.inter(
//                             fontSize: ResponsiveHelper.fontSize(14),
//                             fontWeight: unread
//                                 ? FontWeight.w600
//                                 : FontWeight.w500,
//                             color: Colors.black87,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       SizedBox(width: ResponsiveHelper.spacing(8)),
//                       Text(
//                         _formatTime(notification.createdAt),
//                         style: GoogleFonts.inter(
//                           fontSize: ResponsiveHelper.fontSize(11),
//                           color: Colors.grey.shade400,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: ResponsiveHelper.spacing(4)),
//                   Text(
//                     notification.body,
//                     style: GoogleFonts.inter(
//                       fontSize: ResponsiveHelper.fontSize(13),
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w400,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Unread dot ────────────────────────────────
//             if (unread) ...[
//               SizedBox(width: ResponsiveHelper.spacing(8)),
//               Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.only(top: 4),
//                 decoration: const BoxDecoration(
//                   color: AppColors.blue,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }