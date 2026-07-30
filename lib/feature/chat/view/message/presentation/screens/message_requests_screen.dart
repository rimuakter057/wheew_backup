import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/share/widgets/dialog/action_confirm_dialog.dart';

class MessageRequestsScreen extends StatefulWidget {
  final bool showAppBar;

  const MessageRequestsScreen({super.key, this.showAppBar = true});

  @override
  State<MessageRequestsScreen> createState() => _MessageRequestsScreenState();
}

class _MessageRequestsScreenState extends State<MessageRequestsScreen> {
  final MessageController messageController = Get.find<MessageController>();
  final ScrollController _scrollController = ScrollController();

  static const Color primaryBlue = Color(0xFF185FA5);

  static const Color bgColor = Color(0xFFF6F8FB);

  @override
  void initState() {
    super.initState();
    // Initial fetch of message requests
    messageController.fetchMessageRequestInbox(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      messageController.fetchMessageRequestInbox(refresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: ResponsiveHelper.width(42),
                    height: ResponsiveHelper.width(42),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                'Received Requests',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(18),
                ),
              ),
            )
          : null,
      body: Obx(() {
        final count = messageController.totalRequestsCount.value;

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
                  count > 0 ? 'Requests(${count.toString().padLeft(2, '0')})' : 'Requests',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            Expanded(
              child: _buildRequestsList(context),
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

  Widget _buildRequestsList(BuildContext context) {
        if (messageController.isLoadingRequests.value && messageController.messageRequests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: primaryBlue),
          );
        }

        if (messageController.messageRequests.isEmpty) {
          return RefreshIndicator(
            color: primaryBlue,
            onRefresh: () => messageController.fetchMessageRequestInbox(refresh: true),
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
                          Icons.mark_email_unread_outlined,
                          size: ResponsiveHelper.iconSize(64),
                          color: primaryBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(20)),
                      Text(
                        AppStrings.noPendingMessageRequests.tr,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(6)),
                      Text(
                        "New requests will show up here",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
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
          onRefresh: () => messageController.fetchMessageRequestInbox(refresh: true),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(16),
              ResponsiveHelper.padding(24),
            ),
            itemCount: messageController.messageRequests.length + (messageController.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: ResponsiveHelper.spacing(6)),
            itemBuilder: (context, index) {
              if (index == messageController.messageRequests.length) {
                return Padding(
                  padding: ResponsiveHelper.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                );
              }

              final request = messageController.messageRequests[index];
              final requester = request['sender'] ?? {};
              final name = requester['nick_name'] ?? 'Plate User';
              final avatar = requester['avatar'] ?? '';
              final message = request['firstMessage'] ?? '';
              final requestId = request['id']?.toString() ?? '';

              return GestureDetector(
                onTap: () {
                  context.pushNamed(
                    RouteName.message,
                    extra: {
                      'roomId': request['chatRoom']?['id'] ?? '',
                      'otherUserName': name,
                      'otherUserAvatar': avatar,
                      'receiverId': requester['id']?.toString() ?? '',
                      'firstMessage': message,
                      'requestId': requestId,
                      'licenceId': requester['licence_id']?.toString() ?? '',
                      'isReceivedRequest': true,
                    },
                  );
                },
                child: Container(
                padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                 // color: Colors.white.withValues(alpha: 0.85),
                  gradient: AppColors.parkingContainerGradient,                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                          if (requester['licence_id'] != null && requester['licence_id'].toString().isNotEmpty)
                            Text(
                              requester['licence_id'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (message.isNotEmpty) ...[
                            SizedBox(height: ResponsiveHelper.spacing(4)),
                            Text(
                              message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    // Reject (Red X button)
                    GestureDetector(
                      onTap: () {
                        ActionConfirmDialog.show(
                          context,
                          title: 'Reject request?',
                          message: "Reject the message request from $name?",
                          confirmLabel: AppStrings.reject.tr,
                          icon: Icons.cancel_outlined,
                          iconColor: const Color(0xFFB02517),
                          confirmGradient: const LinearGradient(
                            colors: [Color(0xFFB02517), Color(0xFF7A1C15)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          onConfirm: () {
                            messageController.rejectMessageRequest(
                              requestId: requestId,
                              context: context,
                            );
                          },
                        );
                      },
                      child: Container(
                        width: ResponsiveHelper.width(36),
                        height: ResponsiveHelper.width(36),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB02517),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    // Accept (Blue Pill button)
                    GestureDetector(
                      onTap: () {
                        ActionConfirmDialog.show(
                          context,
                          title: 'Accept request?',
                          message:
                              "Accept the message request from $name? You'll be able to message each other.",
                          confirmLabel: AppStrings.accept.tr,
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: AppColors.blue,
                          onConfirm: () {
                            messageController.acceptMessageRequest(
                              requestId: requestId,
                              context: context,
                            );
                          },
                        );
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
                          AppStrings.accept.tr,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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