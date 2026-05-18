import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/repository/add_member_repo.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/member/presentation/widgets/add_member_search_bar.dart';
import 'package:platchatapp/feature/chat/view/member/presentation/widgets/add_member_tile.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../group/controller/group_controller.dart';


class AddMemberScreen extends StatefulWidget {
  final String groupRoomId;

  const AddMemberScreen({super.key, required this.groupRoomId});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatController chatController = Get.find<ChatController>();

  // ── নতুন AddMemberController ──
  late final GroupController _controller;

  @override
  void initState() {
    super.initState();

    // Controller register + init
    _controller = Get.put(GroupController());
    _controller.init(widget.groupRoomId);

    // Search bar listener → controller এ pass করো
    _searchController.addListener(
          () => _controller.onSearchChanged(_searchController.text),
    );
  }

  Future<void> _onAddMember() async {
    await chatController.addGroupMember(
      groupRoomId: widget.groupRoomId,
      memberIds: _controller.selectedIds.toList(),
      context: context,
    );
    if (mounted) Navigator.pop(context);
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
                'add_member'.tr,
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
      // Loading indicator
      if (_controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<SearchMemberModel> list = _controller.searchResults;

      // Empty state
      if (list.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .3),
            Center(
              child: Text(
                _controller.searchQuery.value.isNotEmpty
                    ? '${'no_results_for'.tr} "${_controller.searchQuery.value}"'
                    : 'no_contacts_found'.tr,
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(20)),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            SizedBox(height: ResponsiveHelper.height(12)),
        itemBuilder: (context, index) {
          final SearchMemberModel member = list[index];

          return Obx(() => AddMemberTile(       // ✅ এই Obx টা নতুন
            name: member.nickName,
            avatarUrl: ImageHandler.imagesHandle(
              member.avatar?.isNotEmpty == true
                  ? member.avatar!
                  : AppConst.unknown,
              isProfile: true,
            ),
            rating: null,
            isSelected: _controller.isSelected(member.id),  // এখন reactive
            onTap: () => _controller.toggleSelect(member.id),
            onCheckChanged: (_) => _controller.toggleSelect(member.id),
          ));
        },
      );
    });
  }
///button=======================
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
        height: ResponsiveHelper.buttonHeight(56),
        child: Obx(() {
          final bool isBusy = chatController.isAddingMember.value;
          final int selectedCount = _controller.selectedIds.length;

          return ElevatedButton(
            onPressed: (selectedCount == 0 || isBusy) ? null : _onAddMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueClient,
              disabledBackgroundColor: AppColors.blueClient.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(30),
                ),
              ),
            ),
            child: isBusy
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              selectedCount == 0
                  ? 'add_member'.tr
                  : '${'add_member'.tr} ($selectedCount)',
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
