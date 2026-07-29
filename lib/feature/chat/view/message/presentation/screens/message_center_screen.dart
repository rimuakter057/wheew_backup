import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/screens/message_requests_screen.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/screens/send_message_request.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class MessageCenterScreen extends StatefulWidget {
  final int? initialIndex;
  const MessageCenterScreen({super.key, this.initialIndex = 0});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}


class _MessageCenterScreenState extends State<MessageCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final idx = (widget.initialIndex ?? 0).clamp(0, 1);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: idx,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            AppStrings.messageRequests.tr,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.blue,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: AppColors.blue,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              Tab(text: AppStrings.receiveRequestTab.tr),
              Tab(text: AppStrings.sendMessageTab.tr),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            MessageRequestsScreen(showAppBar: false),
            SentMessageRequestsScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
