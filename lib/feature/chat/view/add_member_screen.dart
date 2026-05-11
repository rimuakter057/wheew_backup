import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Static dummy members
  final List<Map<String, dynamic>> _members = [
    {"name": "Mike Johnson", "rating": "4.8", "avatar": null, "selected": true},
    {"name": "Mike Johnson", "rating": "4.8", "avatar": null, "selected": false},
    {"name": "Mike Johnson", "rating": "4.8", "avatar": null, "selected": false},
    {"name": "Mike Johnson", "rating": "4.8", "avatar": null, "selected": false},
  ];

  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_members);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _members
          .where((m) => m['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

            // ── Header ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(8),
              ),
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
                  // balance for center alignment
                  SizedBox(width: ResponsiveHelper.width(48)),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.height(16)),

            // ── Search Label ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(20),
              ),
              child: Text(
                'Search Member',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.height(8)),

            // ── Search Field ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(30),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: ResponsiveHelper.iconSize(20),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.padding(14),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.height(20)),

            // ── Member List ────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(20),
                ),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: ResponsiveHelper.height(12)),
                itemBuilder: (context, index) {
                  final member = _filtered[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        member['selected'] = !(member['selected'] as bool);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(16),
                        vertical: ResponsiveHelper.padding(12),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: ResponsiveHelper.borderRadius(24),
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: member['avatar'] != null
                                ? NetworkImage(member['avatar'])
                                : null,
                            child: member['avatar'] == null
                                ? Icon(
                              Icons.person,
                              color: Colors.white,
                              size: ResponsiveHelper.iconSize(24),
                            )
                                : null,
                          ),

                          SizedBox(width: ResponsiveHelper.spacing(12)),

                          // Name & Rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: ResponsiveHelper.fontSize(14),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.height(4)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: ResponsiveHelper.iconSize(16),
                                    ),
                                    SizedBox(width: ResponsiveHelper.spacing(4)),
                                    Text(
                                      member['rating'],
                                      style: GoogleFonts.poppins(
                                        fontSize: ResponsiveHelper.fontSize(12),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Checkbox
                          Checkbox(
                            value: member['selected'] as bool,
                            activeColor: AppColors.blueClient,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            onChanged: (val) {
                              setState(() {
                                member['selected'] = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Add Member Button ──────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.padding(20),
                ResponsiveHelper.padding(12),
                ResponsiveHelper.padding(20),
                ResponsiveHelper.padding(20),
              ),
              child: SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.buttonHeight(52),
                child: ElevatedButton(
                  onPressed: () {
                    final selected = _filtered
                        .where((m) => m['selected'] == true)
                        .toList();
                    // TODO: Add member API call
                    debugPrint('Selected: ${selected.map((e) => e['name'])}');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueClient,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(30),
                      ),
                    ),
                  ),
                  child: Text(
                    'Add Member',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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