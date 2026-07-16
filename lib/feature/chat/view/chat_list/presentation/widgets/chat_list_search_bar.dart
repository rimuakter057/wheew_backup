// widgets/chat_list_search_bar.dart
// ── দায়িত্ব: Dummy search bar — tap করলে search screen এ push করে ──
//              AbsorbPointer দিয়ে keyboard open হওয়া বন্ধ রাখে

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class ChatListSearchBar extends StatelessWidget {
  const ChatListSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
      child: GestureDetector(
        // tap করলে search list screen এ যাও
      //  onTap: () => mainNavIndex.value = 1, // ⬅️ এখানেই সরাসরি বদলান
        onTap: (){
          context.push(RoutePath.searchList);
        },
        child: AbsorbPointer(
          // keyboard open হওয়া block করে — শুধু tap detect করে
          child: TextField(
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(16),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.searchHere.tr,
              hintStyle: TextStyle(
                fontSize: ResponsiveHelper.fontSize(16),
              ),
              prefixIcon: Icon(
                Icons.search,
                size: ResponsiveHelper.iconSize(24),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}