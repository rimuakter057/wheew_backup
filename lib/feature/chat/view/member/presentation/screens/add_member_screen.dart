import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/member/presentation/widgets/add_member_search_bar.dart';
import 'package:platchatapp/feature/chat/view/member/presentation/widgets/add_member_tile.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupRoomId;

  const AddMemberScreen({super.key, required this.groupRoomId});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController controller = Get.find<ChatController>();

  final Set<String> _selectedIds = {}; // otherUser id
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchChatList(refresh: true);
    });
  }

  void _onSearch() => setState(
          () => _searchQuery = _searchController.text.toLowerCase().trim());

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMore &&
        !controller.isLoadingMore.value &&
        !controller.isLoadingChat.value) {
      controller.fetchChatList(loadMore: true);
    }
  }

  void _toggleSelect(String userId) => setState(() =>
  _selectedIds.contains(userId)
      ? _selectedIds.remove(userId)
      : _selectedIds.add(userId));

  List<Rooms> get _filteredList {
    final list = controller.userChatList
        .where((r) => r.type == 'ONE_TO_ONE')
        .toList();
    if (_searchQuery.isEmpty) return list;
    return list
        .where((r) => r.displayName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _onAddMember() async {
    await controller.addGroupMember(
      groupRoomId: widget.groupRoomId,
      memberIds: _selectedIds.toList(),
      context: context,
    );

    context.pop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.height(8)),
            _buildHeader(),
            SizedBox(height: ResponsiveHelper.height(16)),
            AddMemberSearchBar(controller: _searchController),
            SizedBox(height: ResponsiveHelper.height(20)),
            Expanded(child: _buildList()),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(8)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppColors.black),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Add Member',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.width(48)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoadingChat.value && controller.userChatList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<Rooms> list = _filteredList;

      if (list.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .3),
            Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'No results for "$_searchQuery"'
                    : 'No contacts found',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(14),
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      }

      return ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(20)),
        itemCount: list.length + 1,
        separatorBuilder: (_, __) =>
            SizedBox(height: ResponsiveHelper.height(12)),
        itemBuilder: (context, index) {
          if (index == list.length) {
            return controller.isLoadingMore.value
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox.shrink();
          }

          final Rooms room = list[index];
          // otherUser id দিয়ে select track করো
          final String userId = room.otherUser?.id ?? '';

          return AddMemberTile(
            name: room.displayName,
            avatarUrl: ImageHandler.imagesHandle(
              room.displayAvatar.isNotEmpty
                  ? room.displayAvatar
                  : AppConst.unknown,
              isProfile: true,
            ),
            rating: room.otherUser?.rating,
            isSelected: _selectedIds.contains(userId),
            onTap: () => _toggleSelect(userId),
            onCheckChanged: (_) => _toggleSelect(userId),
          );
        },
      );
    });
  }

  Widget _buildAddButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.padding(20),
        ResponsiveHelper.padding(12),
        ResponsiveHelper.padding(20),
        ResponsiveHelper.padding(20),
      ),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveHelper.buttonHeight(52),
        child: Obx(() {
          final bool isBusy = controller.isAddingMember.value;
          return ElevatedButton(
            onPressed: (_selectedIds.isEmpty || isBusy) ? null : _onAddMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueClient,
              disabledBackgroundColor: AppColors.blueClient.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(30)),
              ),
            ),
            child: isBusy
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
                : Text(
              _selectedIds.isEmpty
                  ? 'Add Member'
                  : 'Add Member (${_selectedIds.length})',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}