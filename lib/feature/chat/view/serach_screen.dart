import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/chat_controller.dart';
import '../../profile/view/app_menu_drawer.dart';
import 'chat_tile.dart';

class SearchListScreen extends StatefulWidget {
  const SearchListScreen({super.key});

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (!SocketApi.isConnected) {
      SocketApi.init(
        onSocketConnect: () {
          debugPrint('Socket connected from SearchListScreen');
        },
      );
    }

    // Auto focus the search field
    Future.delayed(const Duration(milliseconds: 200), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          'all_chat'.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.menu_outlined,
                  color: AppColors.black,
                  size: ResponsiveHelper.iconSize(24),
                ),
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
        init: Get.find<ChatController>(), //  ensure controller exists
        builder: (controller) {
          // Determine which list to display
          final displayList = controller.isSearching || controller.searchResults.isNotEmpty
              ? controller.searchResults
              : controller.chatList;

          return Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) => controller.searchUsers(value),
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                  decoration: InputDecoration(
                    hintText: 'search_here'.tr,
                    hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    prefixIcon: Icon(
                      Icons.search,
                      size: ResponsiveHelper.iconSize(24),
                    ),
                    suffixIcon: controller.isSearching
                        ? Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
                      child: SizedBox(
                        width: ResponsiveHelper.width(20),
                        height: ResponsiveHelper.height(20),
                        child: CircularProgressIndicator(
                          strokeWidth: ResponsiveHelper.borderWidth(2),
                        ),
                      ),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(30),
                      ),
                    ),
                  ),
                ),
              ),

              // Chat list
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayList.isEmpty
                    ? Center(
                  child: Text(
                    'no_chats'.tr,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(16),
                    ),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () => controller.getChatSearchList(),
                  child: ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final chat = displayList[index];
                      return ChatTile(
                        name: chat.name,
                        message: chat.message,
                        time: chat.time,
                        imagePath: chat.imagePath ?? "assets/images/person1.png",
                        onTap: () => context.pushNamed(RouteName.message),
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