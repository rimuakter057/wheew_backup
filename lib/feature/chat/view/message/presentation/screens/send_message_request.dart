import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class SentMessageRequestsScreen extends StatefulWidget {
  final bool showAppBar;

  const SentMessageRequestsScreen({super.key, this.showAppBar = true});

  @override
  State<SentMessageRequestsScreen> createState() => _SentMessageRequestsScreenState();
}

class _SentMessageRequestsScreenState extends State<SentMessageRequestsScreen> {
  final MessageController messageController = Get.find<MessageController>();
  final ScrollController _scrollController = ScrollController();

  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color bgColor = Color(0xFFF6F8FB);
  static const Color pendingColor = Color(0xFFB88A00);


  @override
  void initState() {
    super.initState();
    messageController.fetchSentMessageRequests(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      messageController.fetchSentMessageRequests(refresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppColors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: AppColors.transparent,
              leading: Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: ResponsiveHelper.width(42),
                    height: ResponsiveHelper.width(42),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: ResponsiveHelper.iconSize(16),
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              title: Text(
                AppStrings.sentRequests.tr,
                style: GoogleFonts.poppins(
                  color: AppColors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(18),
                ),
              ),
            )
          : null,
      body: Obx(() {
        final pendingRequests = messageController.sentRequests
            .where((r) => (r['status'] ?? 'PENDING').toString().toUpperCase() == 'PENDING')
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showAppBar)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(20),
                  vertical: ResponsiveHelper.padding(4),
                ),
                child: Text(
                  pendingRequests.isNotEmpty
                      ? '${AppStrings.sent.tr}(${pendingRequests.length.toString().padLeft(2, '0')})'
                      : AppStrings.sent.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
              ),
            Expanded(
              child: _buildSentRequestsList(context),
            ),
          ],
        );
      }),
    );

    if (widget.showAppBar) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: content,
      );
    }
    return content;
  }

  Widget _buildSentRequestsList(BuildContext context) {
        if (messageController.isLoadingSentRequests.value && messageController.sentRequests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: primaryBlue),
          );
        }

        // âœ… à¦¶à§à¦§à§ PENDING request à¦—à§à¦²à§‹ à¦«à¦¿à¦²à§à¦Ÿà¦¾à¦° à¦•à¦°à¦¾ à¦¹à¦šà§à¦›à§‡
        final pendingRequests = messageController.sentRequests
            .where((r) => (r['status'] ?? 'PENDING').toString().toUpperCase() == 'PENDING')
            .toList();

        if (pendingRequests.isEmpty) {
          return RefreshIndicator(
            color: primaryBlue,
            onRefresh: () => messageController.fetchSentMessageRequests(refresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: ResponsiveHelper.all(24),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_outlined,
                          size: ResponsiveHelper.iconSize(64),
                          color: primaryBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(20)),
                      Text(
                        AppStrings.noSentRequests.tr,
                        style: GoogleFonts.poppins(
                          color: AppColors.black87,
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(6)),
                      Text(
                        AppStrings.requestsYouSendShowUpHere.tr,
                        style: GoogleFonts.poppins(
                          color: AppColors.greyShade500,
                          fontSize: ResponsiveHelper.fontSize(13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primaryBlue,
          onRefresh: () => messageController.fetchSentMessageRequests(refresh: true),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(16),
            ),
            // âœ… pendingRequests.length à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à¦¾ à¦¹à¦šà§à¦›à§‡, à¦ªà§à¦°à§‹ list à¦¨à¦¾
            itemCount: pendingRequests.length + (messageController.hasMoreSent.value ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: ResponsiveHelper.spacing(6)),
            itemBuilder: (context, index) {
              if (index == pendingRequests.length) {
                return Padding(
                  padding: ResponsiveHelper.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                );
              }

              // âœ… filtered list à¦¥à§‡à¦•à§‡ item à¦¨à§‡à¦“à¦¯à¦¼à¦¾ à¦¹à¦šà§à¦›à§‡
              final request = pendingRequests[index];
              final receiver = request['receiver'] ?? {};
              final name = receiver['nick_name'] ?? AppStrings.unknown.tr;
              final avatar = receiver['avatar'] ?? '';
              final message = request['firstMessage'] ?? '';
              final status = request['status'] ??   AppStrings.pending.tr;

              return GestureDetector(
                onTap: () {
                  context.pushNamed(
                    RouteName.message,
                    extra: {
                      'roomId': request['chatRoom']?['id'] ?? '',
                      'otherUserName': name,
                      'otherUserAvatar': avatar,
                      'receiverId': receiver['id']?.toString() ?? '',
                      'firstMessage': message,
                      'requestId': request['id']?.toString() ?? '',
                      'licenceId': receiver['licence_id']?.toString() ?? '',
                      'isSendRequest': true,
                    },
                  );
                },
                child: Container(
                padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.containerGradient,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      imagePath: avatar.isNotEmpty ? avatar : AppConst.unknown,
                      radius: 24,
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: ResponsiveHelper.fontSize(15),
                              color: const Color(0xFF1D2939),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(2)),
                          if (receiver['licence_id'] != null && receiver['licence_id'].toString().isNotEmpty)
                            Text(
                              receiver['licence_id'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                color: AppColors.greyShade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    if (status.toString().toUpperCase() == 'PENDING')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.padding(16),
                          vertical: ResponsiveHelper.padding(6),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                          border: Border.all(
                            color: const Color(0xFF0062E0),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          'Pending',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0062E0),
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.fontSize(12),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          final roomId = request['chatRoom_id'] ?? request['chatRoom']?['id'] ?? '';
                          if (roomId.toString().isNotEmpty) {
                            Get.find<ChatController>().roomID.value = roomId.toString();
                            context.pushNamed(
                              RouteName.message,
                              extra: {
                                'roomId': roomId.toString(),
                                'otherUserName': name,
                                'otherUserAvatar': avatar,
                                'receiverId': receiver['id'] ?? '',
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(16),
                            vertical: ResponsiveHelper.padding(8),
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0062E0),
                                Color(0xFF014495),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF014495).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            AppStrings.message.tr,
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveHelper.fontSize(13),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }
}


