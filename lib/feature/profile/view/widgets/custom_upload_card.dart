import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/profile/model/user_document.dart';
import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/upload_document_sheet.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:url_launcher/url_launcher.dart';


/// Three visual states for each card
enum _CardState { empty, uploaded, expired }

class CustomUploadCard extends StatelessWidget {
  final String title;
  final String documentType; // 'LICENSE' | 'INSURANCE' | 'TAX'
  final String iconText;
  final String? iconPath;
  final bool isOwner;

  const  CustomUploadCard({
    super.key,
    required this.title,
    required this.documentType,
    this.iconText = '',
    this.iconPath,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UploadDocumentController>();

    return Obx(() {
      final doc     = controller.getDoc(documentType); // controller.docObs(documentType).value;
      final loading = controller.isLoading(documentType);       //controller.loadingObs(documentType).value;

      final state = doc == null
          ? _CardState.empty
          : doc.isExpired
          ? _CardState.expired
          : _CardState.uploaded;

      return _CardShell(
        state:        state,
        title:        title,
        doc:          doc,
        loading:      loading,
        documentType: documentType,
        ctrl:         controller,
        iconText: iconText,
        iconPath: iconPath,
        isOwner:      isOwner,
      );
    });
  }
}

// ─── Internal shell ───────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final _CardState   state;
  final String       title;
  final UserDocument? doc;
  final bool         loading;
  final String       documentType;
  final UploadDocumentController ctrl;
  final String iconText;
  final String? iconPath;
  final bool isOwner;

  const _CardShell({
    required this.state,
    required this.title,
    required this.doc,
    required this.loading,
    required this.documentType,
    required this.ctrl,
    this.iconText = '',
    this.iconPath,
    this.isOwner = false,
  });

  // colours per state
  Color get _borderColor {
    switch (state) {
      case _CardState.empty:    return const Color(0xFFE5E7EB);
      case _CardState.uploaded: return const Color(0xFFE0E0E0);
      case _CardState.expired:  return const Color(0xFFEF4444);
    }
  }

  Color get _bgColor {
    switch (state) {
      case _CardState.empty:    return Colors.white;
      case _CardState.uploaded: return const Color(0xFFEFF6FF);
      case _CardState.expired:  return const Color(0xFFFFF5F5);
    }
  }



  void _openSheet(BuildContext context) {
    showUploadDocumentSheet(
      context,
      documentType: documentType,
      existingDoc: doc,   // null → POST, non-null → PATCH
      isOwner: isOwner,
    );
  }

  Future<void> _openFileUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {


      CustomSnackbar.error(context: context, message:  'Could not open document',);

    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : () => _openSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical:   ResponsiveHelper.padding(14),
        ),
        decoration: BoxDecoration(
          color:        _bgColor,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
          border:       Border.all(color: _borderColor, width: 2),
        ),
        child: Row(
          children: [

            iconPath != null
                ? CustomImage(
                    imageSrc: iconPath!,
                    width: ResponsiveHelper.iconSize(24),
                    height: ResponsiveHelper.iconSize(24),
                  )
                : Text(iconText,style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(18),

            ),),

            SizedBox(width: ResponsiveHelper.spacing(14)),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize:   ResponsiveHelper.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color:      const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(2)),
                  _buildSubtitle(context),
                ],
              ),
            ),

            SizedBox(width: ResponsiveHelper.spacing(8)),

            // ── Right action ──
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }



  Widget _buildSubtitle(BuildContext context) {
    switch (state) {
      case _CardState.empty:
        return Text(
          AppStrings.tapToUpload.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(12),
            color:    const Color(0xFF9CA3AF),
          ),
        );

      case _CardState.uploaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.id.tr}: ${doc!.uniqueId}',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(11),
                color:    const Color(0xFF6B7280),
              ),
            ),
            // ✅ FIX: isOwner হলে Expires line hide
            if (!isOwner)
              Text(
                '${AppStrings.expires.tr}: ${ctrl.toDisplayDate(doc!.expiryDate)}  •  ${doc!.daysUntilExpiry} ${AppStrings.daysLeft.tr}',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(11),
                  color:    const Color(0xFF2563EB),
                ),
              ),
            if (doc!.resolvedDocumentUrl.isNotEmpty) ...[
              SizedBox(height: ResponsiveHelper.spacing(4)),
              GestureDetector(
                onTap: () => _openFileUrl(context, doc!.resolvedDocumentUrl),
                child: Text(
                  AppStrings.viewDocument.tr,
                  style: GoogleFonts.poppins(
                    fontSize:   ResponsiveHelper.fontSize(11),
                    fontWeight: FontWeight.w600,
                    color:      const Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );

      case _CardState.expired:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.id.tr}: ${doc!.uniqueId}',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(11),
                color:    const Color(0xFF6B7280),
              ),
            ),
            Text(
              AppStrings.expired.tr,
              style: GoogleFonts.poppins(
                fontSize:   ResponsiveHelper.fontSize(11),
                fontWeight: FontWeight.w600,
                color:      const Color(0xFFEF4444),
              ),
            ),
            if (doc!.resolvedDocumentUrl.isNotEmpty) ...[
              SizedBox(height: ResponsiveHelper.spacing(4)),
              GestureDetector(
                onTap: () => _openFileUrl(context, doc!.resolvedDocumentUrl),
                child: Text(
                  AppStrings.viewDocument.tr,
                  style: GoogleFonts.poppins(
                    fontSize:   ResponsiveHelper.fontSize(11),
                    fontWeight: FontWeight.w600,
                    color:      const Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }
///trailing=======================
  Widget _buildTrailing(BuildContext context) {
    switch (state) {
      case _CardState.empty:
        return _gradientPillButton(
          label: AppStrings.upload.tr,
          colors: const [AppColors.blue, AppColors.darBlue],
          onTap: () => _openSheet(context),
        );

      case _CardState.uploaded:
        return _gradientPillButton(
          label: AppStrings.update.tr,
          colors: const [AppColors.blue, AppColors.darBlue],
          onTap: () => _openSheet(context),
        );

      case _CardState.expired:
        return _gradientPillButton(
          label: AppStrings.renew.tr,
          colors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
          onTap: () => _openSheet(context),
        );
    }
  }

  Widget _gradientPillButton({
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
          vertical:   ResponsiveHelper.padding(8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              imageSrc: AssetsPath.upload,
              imageColor: Colors.white,
              width: ResponsiveHelper.iconSize(14),
              height: ResponsiveHelper.iconSize(14),
            ),
            SizedBox(width: ResponsiveHelper.width(8)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize:   ResponsiveHelper.fontSize(12),
                fontWeight: FontWeight.w600,
                color:      Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}