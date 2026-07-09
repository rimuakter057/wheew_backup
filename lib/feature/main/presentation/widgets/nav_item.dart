import 'package:flutter/material.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int index;

  const NavItem({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.spacing(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(30),
          ),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,

            height: ResponsiveHelper.height(52),

            padding: EdgeInsets.symmetric(
              horizontal: selected
                  ? ResponsiveHelper.padding(18)
                  : ResponsiveHelper.padding(15),
              vertical: ResponsiveHelper.padding(10),
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(30),
              ),

              gradient: selected
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff2488FF),
                  Color(0xff0E5BCF),
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.white.withOpacity(.22),
                  Colors.white.withOpacity(.08),
                ],
              ),

              border: Border.all(
                color: selected
                    ? Colors.white.withOpacity(.20)
                    : Colors.white.withOpacity(.30),
                width: ResponsiveHelper.borderWidth(1),
              ),

              boxShadow: selected
                  ? [
                BoxShadow(
                  color: const Color(0xff2488FF).withOpacity(.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.white.withOpacity(.20),
                  blurRadius: 5,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),

            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: ResponsiveHelper.iconSize(21),
                  ),

                  if (selected) ...[
                    SizedBox(
                      width: ResponsiveHelper.spacing(8),
                    ),

                    Text(
                      _label(index),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.fontSize(13),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _label(int index) {
    switch (index) {
      case 0:
        return "Home";

      case 1:
        return "Location";

      case 2:
        return "Chat";

      case 3:
        return "Profile";

      default:
        return "";
    }
  }
}