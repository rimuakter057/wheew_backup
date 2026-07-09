import 'package:flutter/material.dart';
import 'package:platchatapp/feature/main/presentation/widgets/glass_navbar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';


// decoration: const BoxDecoration(
// gradient: LinearGradient(
// begin: Alignment.topLeft,
// end: Alignment.bottomRight,
// colors: [
// Color(0xffEEF4FC),
// Color(0xffD7E5F6),
// Color(0xffCBDCF1),
// ],
// ),
// ),


class GlassNavScreen extends StatefulWidget {
  const GlassNavScreen({super.key});

  @override
  State<GlassNavScreen> createState() => _GlassNavScreenState();
}

class _GlassNavScreenState extends State<GlassNavScreen> {
  int _currentIndex = 0;

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.location_on_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffDCE8F6),
      body: Stack(
        children: [

          /// Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffEEF5FD),
                    Color(0xffD7E5F5),
                  ],
                ),
              ),
            ),
          ),

          /// Top Glow
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: ResponsiveHelper.width(260),
              height: ResponsiveHelper.width(260),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.45),
              ),
            ),
          ),

          /// Bottom Glow
          Positioned(
            bottom: -140,
            right: -80,
            child: Container(
              width: ResponsiveHelper.width(260),
              height: ResponsiveHelper.width(260),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.18),
              ),
            ),
          ),

          /// Demo Content
          SafeArea(
            child: Center(
              child: Text(
                "Glass Navigation",
                style: TextStyle(
                  fontSize: ResponsiveHelper.titleFontSize(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(
          left: ResponsiveHelper.padding(18),
          right: ResponsiveHelper.padding(18),
          bottom: ResponsiveHelper.padding(18),
        ),
        child: GlassNavBar(
          currentIndex: _currentIndex,
          icons: _icons,
          onChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}