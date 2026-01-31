import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes_name.dart';
import '../../../utils/extension/string_extension.dart';
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

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_here'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // Chat list
          Expanded(
            child: ListView(
              children: [
                ChatTile(
                  name: "Georgina",
                  message: "whatssup",
                  time: "3:10 pm",
                  imagePath: "assets/images/person1.png",
                  onTap: () => context.pushNamed(RouteName.inbox),
                ),
                ChatTile(
                  name: "Cyra",
                  message: "its urgent",
                  time: "3:10 pm",
                  imagePath: "assets/images/person2.png",
                  onTap: () => context.pushNamed(RouteName.inbox),
                ),
                ChatTile(
                  name: "Kiara",
                  message: "you are welcome",
                  time: "3:10 pm",
                  imagePath: "assets/images/person3.png",
                  onTap: () => context.pushNamed(RouteName.inbox),

                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
