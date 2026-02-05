/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/controller/chat_controller.dart';
import '../../profile/view/app_menu_drawer.dart';
import 'chat_tile.dart';
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('all_chat'.tr, style: const TextStyle(color: Colors.black)),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_outlined, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const AppMenuDrawer(),
      body: GetBuilder<ChatController>(
        init: ChatController(),
        builder: (controller) {
          return Column(
            children: [
             /// Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search_here'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
                    ),
                  ),
                ),
              ),

              // Chat list
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.chatList.isEmpty
                    ? Center(child: Text('no_chats'.tr))
                    : RefreshIndicator(
                  onRefresh: () => controller.getChatList(),
                  child: ListView.builder(
                    itemCount: controller.chatList.length,
                    itemBuilder: (context, index) {
                      final chat = controller.chatList[index];
                      return ChatTile(
                        name: chat.name,
                        message: chat.message,
                        time: chat.time,
                        imagePath: chat.imagePath ?? "assets/images/person1.png",
                        onTap: () => context.pushNamed(RouteName.inbox),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/chat_controller.dart';
import '../../profile/view/app_menu_drawer.dart';
import 'chat_tile.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('all_chat'.tr, style: const TextStyle(color: Colors.black)),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_outlined, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const AppMenuDrawer(),
      body: GetBuilder<ChatController>(
        init: ChatController(),
        builder: (controller) {
          // Determine which list to display
          final displayList = controller.isSearching || controller.searchResults.isNotEmpty
              ? controller.searchResults
              : controller.chatList;

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) => controller.searchUsers(value),
                  decoration: InputDecoration(
                    hintText: 'search_here'.tr,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.isSearching
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
                    ),
                  ),
                ),
              ),

              // Chat list
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayList.isEmpty
                    ? Center(child: Text('no_chats'.tr))
                    : RefreshIndicator(
                  onRefresh: () => controller.getChatList(),
                  child: ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final chat = displayList[index];
                      return ChatTile(
                        name: chat.name,
                        message: chat.message,
                        time: chat.time,
                        imagePath: chat.imagePath ?? "assets/images/person1.png",
                        onTap: () => context.pushNamed(RouteName.inbox),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}