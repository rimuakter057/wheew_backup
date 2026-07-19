import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';

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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Obx(() {
          // ✅ শুধু PENDING request গুলো ফিল্টার করে count বের করা হচ্ছে
          final pendingCount = messageController.sentRequests
              .where((r) => (r['status'] ?? 'PENDING').toString().toUpperCase() == 'PENDING')
              .length;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.sentRequests.tr,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(18),
                ),
              ),
              if (pendingCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      )
          : null,
      body: Obx(() {
        if (messageController.isLoadingSentRequests.value && messageController.sentRequests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: primaryBlue),
          );
        }

        // ✅ শুধু PENDING request গুলো ফিল্টার করা হচ্ছে
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_outlined,
                          size: 64,
                          color: primaryBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.noSentRequests.tr,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Requests you send will show up here",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 13,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            // ✅ pendingRequests.length ব্যবহার করা হচ্ছে, পুরো list না
            itemCount: pendingRequests.length + (messageController.hasMoreSent.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == pendingRequests.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                );
              }

              // ✅ filtered list থেকে item নেওয়া হচ্ছে
              final request = pendingRequests[index];
              final receiver = request['receiver'] ?? {};
              final name = receiver['nick_name'] ?? 'Plate User';
              final avatar = receiver['avatar'] ?? '';
              final message = request['firstMessage'] ?? '';
              final status = request['status'] ?? 'PENDING';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryBlue, primaryBlue.withValues(alpha: 0.4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                ImageHandler.imagesHandle(avatar, isProfile: true),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.requestSent.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status.toUpperCase() == 'PENDING';
    final color = isPending
        ? _SentMessageRequestsScreenState.pendingColor
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isPending ? 'Pending' : status,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}