import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';

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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Obx(() {
          final count = messageController.totalRequestsCount.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.messageRequests.tr,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(18),
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: ResponsiveHelper.spacing(8)),
                Container(
                  padding: ResponsiveHelper.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveHelper.fontSize(12),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(ResponsiveHelper.height(1)),
          child: Container(height: ResponsiveHelper.height(1), color: Colors.grey.shade200),
        ),
      )
          : null,
      body: Obx(() {
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
            separatorBuilder: (_, __) => SizedBox(height: ResponsiveHelper.spacing(12)),
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

              return Container(
                padding: ResponsiveHelper.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: ResponsiveHelper.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryBlue, primaryBlue.withValues(alpha: 0.4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: ResponsiveHelper.width(22),
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: ResponsiveHelper.width(20),
                              backgroundImage: NetworkImage(
                                ImageHandler.imagesHandle(avatar, isProfile: true),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ResponsiveHelper.fontSize(14),
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.spacing(2)),
                              Text(
                                AppStrings.wantsToSendYouAMessage.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveHelper.fontSize(11.5),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(14)),
                    Container(
                      width: double.infinity,
                      padding: ResponsiveHelper.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                      ),
                      child: Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(13),
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(14)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              messageController.declineMessageRequest(
                                requestId: requestId,
                                context: context,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: ResponsiveHelper.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.red.shade200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                              ),
                            ),
                            child: Text(
                              AppStrings.decline.tr,
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveHelper.fontSize(13),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: ResponsiveHelper.spacing(10)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              messageController.acceptMessageRequest(
                                requestId: requestId,
                                context: context,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 0,
                              padding: ResponsiveHelper.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                              ),
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
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}