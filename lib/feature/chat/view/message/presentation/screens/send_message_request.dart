import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class SentMessageRequestsScreen extends StatefulWidget {
  const SentMessageRequestsScreen({super.key});

  @override
  State<SentMessageRequestsScreen> createState() => _SentMessageRequestsScreenState();
}

class _SentMessageRequestsScreenState extends State<SentMessageRequestsScreen> {
  final ChatController chatController = Get.find<ChatController>();

  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color bgColor = Color(0xFFF6F8FB);
  static const Color pendingColor = Color(0xFFB88A00);

  // TEMP: static dummy data just to preview the "sent requests" UI.
  final List<Map<String, dynamic>> _dummySentRequests = [
    {
      'id': '1',
      'receiver': {'nickName': 'Farhan Kabir', 'avatar': ''},
      'message': 'Hi Farhan, would love to connect and chat sometime!',
      'status': 'pending',
    },
    {
      'id': '2',
      'receiver': {'nickName': 'Sadia Rahman', 'avatar': ''},
      'message': 'Hey, I found your profile through mutual friends.',
      'status': 'pending',
    },
    {
      'id': '3',
      'receiver': {'nickName': 'Imran Hossain', 'avatar': ''},
      'message': 'Hello! Interested in discussing a project idea with you.',
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    // chatController.fetchSentMessageRequests(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Sent Requests',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Builder(builder: (context) {
        if (_dummySentRequests.isEmpty) {
          return Center(
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
                  'No sent requests',
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
          );
        }

        return RefreshIndicator(
          color: primaryBlue,
          onRefresh: () async {},
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: _dummySentRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = _dummySentRequests[index];
              final receiver = request['receiver'] ?? {};
              final name = receiver['nickName'] ?? 'Plate User';
              final avatar = receiver['avatar'] ?? '';
              final message = request['message'] ?? '';
              final requestId = request['id']?.toString() ?? '';
              final status = request['status'] ?? 'pending';

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
                                'request sent',
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _dummySentRequests.removeWhere((r) => r['id'] == requestId);
                          });
                        },
                        icon: Icon(Icons.close, size: 16, color: Colors.grey.shade600),
                        label: Text(
                          'Cancel Request',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
    final isPending = status == 'pending';
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