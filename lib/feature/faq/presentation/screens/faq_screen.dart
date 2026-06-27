// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
//
// class FaqScreen extends StatefulWidget {
//   const FaqScreen({super.key});
//
//   @override
//   State<FaqScreen> createState() => _FaqScreenState();
// }
//
// class _FaqScreenState extends State<FaqScreen> {
//   late final NotificationFaqController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(NotificationFaqController());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchFaqs();
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
//           'faq'.tr,
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//             fontSize: ResponsiveHelper.titleFontSize(18),
//           ),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoadingFaq.value) {
//           return const Center(
//             child: CircularProgressIndicator(color: AppColors.blue),
//           );
//         }
//
//         if (controller.faqs.isEmpty) {
//           return _buildEmpty();
//         }
//
//         return RefreshIndicator(
//           color: AppColors.blue,
//           onRefresh: () => controller.fetchFaqs(),
//           child: ListView(
//             padding: EdgeInsets.symmetric(
//               vertical: ResponsiveHelper.spacing(16),
//               horizontal: ResponsiveHelper.spacing(16),
//             ),
//             children: [
//               // ── Header ────────────────────────────────────
//               Container(
//                 padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(16)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.help_outline_rounded,
//                       color: Colors.white,
//                       size: ResponsiveHelper.iconSize(32),
//                     ),
//                     SizedBox(width: ResponsiveHelper.spacing(12)),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'frequently_asked_questions'.tr,
//                             style: GoogleFonts.inter(
//                               color: Colors.white,
//                               fontSize: ResponsiveHelper.fontSize(16),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: ResponsiveHelper.spacing(4)),
//                           Text(
//                             'find_answers_below'.tr,
//                             style: GoogleFonts.inter(
//                               color: Colors.white70,
//                               fontSize: ResponsiveHelper.fontSize(12),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(16)),
//
//               // ── FAQ List ──────────────────────────────────
//               ...controller.faqs.asMap().entries.map((entry) {
//                 return Padding(
//                   padding: EdgeInsets.only(
//                       bottom: ResponsiveHelper.spacing(10)),
//                   child: _FaqTile(
//                     faq: entry.value,
//                     index: entry.key,
//                   ),
//                 );
//               }),
//             ],
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
//             Icons.help_outline_rounded,
//             size: ResponsiveHelper.iconSize(64),
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: ResponsiveHelper.spacing(16)),
//           Text(
//             'no_faqs'.tr,
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
// class _FaqTile extends StatefulWidget {
//   final FaqModel faq;
//   final int index;
//
//   const _FaqTile({required this.faq, required this.index});
//
//   @override
//   State<_FaqTile> createState() => _FaqTileState();
// }
//
// class _FaqTileState extends State<_FaqTile>
//     with SingleTickerProviderStateMixin {
//   bool _isExpanded = false;
//   late AnimationController _animController;
//   late Animation<double> _expandAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       duration: const Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }
//
//   void _toggle() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _animController.forward();
//       } else {
//         _animController.reverse();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _toggle,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//           BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
//           border: Border.all(
//             color: _isExpanded
//                 ? AppColors.blue.withOpacity(0.3)
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
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Question Row ──────────────────────────────
//             Padding(
//               padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
//               child: Row(
//                 children: [
//                   // Number badge
//                   Container(
//                     width: ResponsiveHelper.width(28),
//                     height: ResponsiveHelper.width(28),
//                     decoration: BoxDecoration(
//                       color: _isExpanded
//                           ? AppColors.blue
//                           : const Color(0xFFEEF4FF),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         '${widget.index + 1}',
//                         style: GoogleFonts.inter(
//                           fontSize: ResponsiveHelper.fontSize(12),
//                           fontWeight: FontWeight.w700,
//                           color: _isExpanded
//                               ? Colors.white
//                               : AppColors.blue,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: ResponsiveHelper.spacing(12)),
//
//                   Expanded(
//                     child: Text(
//                       widget.faq.question,
//                       style: GoogleFonts.inter(
//                         fontSize: ResponsiveHelper.fontSize(14),
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(width: ResponsiveHelper.spacing(8)),
//
//                   AnimatedRotation(
//                     turns: _isExpanded ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 250),
//                     child: Icon(
//                       Icons.keyboard_arrow_down_rounded,
//                       color: _isExpanded
//                           ? AppColors.blue
//                           : Colors.grey.shade400,
//                       size: ResponsiveHelper.iconSize(22),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Answer (animated expand) ──────────────────
//             SizeTransition(
//               sizeFactor: _expandAnimation,
//               child: Column(
//                 children: [
//                   Divider(
//                     height: 1,
//                     color: Colors.grey.shade100,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.circle,
//                           size: 6,
//                           color: AppColors.blue,
//                         ),
//                         SizedBox(width: ResponsiveHelper.spacing(10)),
//                         Expanded(
//                           child: Text(
//                             widget.faq.answer,
//                             style: GoogleFonts.inter(
//                               fontSize: ResponsiveHelper.fontSize(13),
//                               color: Colors.grey.shade600,
//                               height: 1.6,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create an account?',
      'answer': 'Download the app, tap "Sign Up", enter your details and verify your email to get started.',
    },
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to the login screen and tap "Forgot Password". Enter your email and follow the instructions sent to you.',
    },
    {
      'question': 'How can I update my profile?',
      'answer': 'Navigate to your profile page and tap the edit icon to update your name, photo, and other details.',
    },
    // {
    //   'question': 'How do I start a group chat?',
    //   'answer': 'Tap the compose icon, select "New Group", add members, set a group name and photo, then tap Create.',
    // },
    {
      'question': 'How do I verify my vehicle ownership?',
      'answer': 'Go to your profile, tap "Vehicle Ownership", upload the required document and wait for verification.',
    },
    {
      'question': 'How do I block someone?',
      'answer': 'Open the chat with that user, tap the menu icon on the top right and select "Block User".',
    },
    // {
    //   'question': 'How do I delete a chat?',
    //   'answer': 'Long press on any chat in the chat list and select "Delete" from the options that appear.',
    // },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, all your data is encrypted and stored securely. We never share your personal information with third parties.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'faq'.tr,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.titleFontSize(18),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.spacing(16),
          horizontal: ResponsiveHelper.spacing(16),
        ),
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: ResponsiveHelper.iconSize(32),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      AppStrings.frequentlyAskedQuestions.tr,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(4)),
                      Text(
                       AppStrings.findAnswersBelow.tr,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: ResponsiveHelper.fontSize(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(16)),

          // FAQ List
          ..._faqs.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.spacing(10)),
              child: _FaqTile(
                question: entry.value['question']!,
                answer: entry.value['answer']!,
                index: entry.key,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final int index;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.index,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          border: Border.all(
            color: _isExpanded
                ? AppColors.blue.withOpacity(0.3)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
              child: Row(
                children: [
                  Container(
                    width: ResponsiveHelper.width(28),
                    height: ResponsiveHelper.width(28),
                    decoration: BoxDecoration(
                      color: _isExpanded ? AppColors.blue : const Color(0xFFEEF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveHelper.fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: _isExpanded ? Colors.white : AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isExpanded ? AppColors.blue : Colors.grey.shade400,
                      size: ResponsiveHelper.iconSize(22),
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade100),
                  Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 6, color: AppColors.blue),
                        SizedBox(width: ResponsiveHelper.spacing(10)),
                        Expanded(
                          child: Text(
                            widget.answer,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.fontSize(13),
                              color: Colors.grey.shade600,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}