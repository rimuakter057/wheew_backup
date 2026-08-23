import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_request_tile.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

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
                'Received Requests',
                style: GoogleFonts.poppins(
                  color: AppColors.black87,
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
                  count > 0
                      ? '${AppStrings.requests.tr}(${count.toString().padLeft(2, '0')})'
                      : AppStrings.requests.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
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
                          color: AppColors.black87,
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(6)),
                      Text(
                        AppStrings.newRequestsShowUpHere.tr,
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

              return MessageRequestTile(
                requestId: requestId,
                name: name,
                avatar: avatar,
                licenceId: requester['licence_id']?.toString(),
                firstMessage: message,
                roomId: request['chatRoom']?['id'] ?? '',
                receiverId: requester['id']?.toString() ?? '',
              );
          },
        ),
      );
  }
}


