import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../utils/color/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create an account?',
      'answer':
      'Download the app, tap "Sign Up", enter your details and verify your email to get started.',
    },
    {
      'question': 'How do I reset my password?',
      'answer':
      'Go to the login screen and tap "Forgot Password". Enter your email and follow the instructions sent to you.',
    },
    {
      'question': 'How can I update my profile?',
      'answer':
      'Navigate to your profile page and tap the edit icon to update your name, photo, and other details.',
    },
    {
      'question': 'How do I verify my vehicle ownership?',
      'answer':
      'Go to your profile, tap "Vehicle Ownership", upload the required document and wait for verification.',
    },
    {
      'question': 'How do I block someone?',
      'answer':
      'Open the chat with that user, tap the menu icon on the top right and select "Block User".',
    },
    {
      'question': 'Is my data secure?',
      'answer':
      'Yes, all your data is encrypted and stored securely. We never share your personal information with third parties.',
    },
  ];

  // Reference palette (matches the provided design)
  static const Color bgTop = Color(0xFFEDF0F8);
  static const Color bgBottom = Color(0xFFC9D2E6);
  static const Color cardTop = Color(0xFFF3F5FA);
  static const Color cardBottom = Color(0xFFE1E6F2);
  static const Color titleColor = Color(0xFF2B2E3A);
  static const Color subtitleColor = Color(0xFF6E7488);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration:  BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header: back button + centered title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.spacing(16),
                  vertical: ResponsiveHelper.spacing(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                     "FAQ",
                      style: GoogleFonts.inter(
                        color: titleColor,
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveHelper.titleFontSize(14),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: ResponsiveHelper.width(40),
                          height: ResponsiveHelper.width(40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: titleColor,
                            size: ResponsiveHelper.iconSize(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              // FAQ List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.spacing(16),
                    vertical: ResponsiveHelper.spacing(8),
                  ),
                  children: _faqs.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.spacing(14),
                      ),
                      child: _FaqTile(
                        question: entry.value['question']!,
                        answer: entry.value['answer']!,
                        index: entry.key,
                        cardTop: cardTop,
                        cardBottom: cardBottom,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final int index;
  final Color cardTop;
  final Color cardBottom;
  final Color titleColor;
  final Color subtitleColor;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.index,
    required this.cardTop,
    required this.cardBottom,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    // First item open by default, matching the reference design
    if (widget.index == 0) {
      _isExpanded = true;
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _animController.forward() : _animController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.cardTop, widget.cardBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(20),
                vertical: ResponsiveHelper.padding(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: widget.titleColor,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.subtitleColor,
                      size: ResponsiveHelper.iconSize(22),
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveHelper.padding(20),
                  right: ResponsiveHelper.padding(20),
                  bottom: ResponsiveHelper.padding(18),
                ),
                child: Text(
                  widget.answer,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveHelper.fontSize(13),
                    color: widget.subtitleColor,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}