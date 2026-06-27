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

  const  CustomUploadCard({
    super.key,
    required this.title,
    required this.documentType,
    required this.iconText,
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

  const _CardShell({
    required this.state,
    required this.title,
    required this.doc,
    required this.loading,
    required this.documentType,
    required this.ctrl,
    required this.iconText,
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

  // Color get _iconBgColor {
  //   switch (state) {
  //     case _CardState.empty:    return const Color(0xFFF3F4F6);
  //     case _CardState.uploaded: return const Color(0xFFDBEAFE);
  //     case _CardState.expired:  return const Color(0xFFFEE2E2);
  //   }
  // }
  //
  // Color get _iconColor {
  //   switch (state) {
  //     case _CardState.empty:    return const Color(0xFF9CA3AF);
  //     case _CardState.uploaded: return const Color(0xFF2563EB);
  //     case _CardState.expired:  return const Color(0xFFEF4444);
  //   }
  // }
  //
  // IconData get _icon {
  //   switch (state) {
  //     case _CardState.empty:    return Icons.upload_file_outlined;
  //     case _CardState.uploaded: return Icons.insert_drive_file_outlined;
  //     case _CardState.expired:  return Icons.warning_amber_rounded;
  //   }
  // }

  void _openSheet(BuildContext context) {
    showUploadDocumentSheet(
      context,
      documentType: documentType,
      existingDoc: doc,   // null → POST, non-null → PATCH
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
            // ── Icon ──
            // Container(
            //   width:  ResponsiveHelper.iconSize(44),
            //   height: ResponsiveHelper.iconSize(44),
            //   decoration: BoxDecoration(
            //     color:        _iconBgColor,
            //     borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
            //   ),
            //   child: loading
            //       ? Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: CircularProgressIndicator(
            //       strokeWidth: 2,
            //       color: _iconColor,
            //     ),
            //   )
            //       : Icon(_icon, color: _iconColor, size: ResponsiveHelper.iconSize(22)),
            // ),

            Text(iconText,style: TextStyle(
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
///sub title==============================
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
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(12),
            vertical:   ResponsiveHelper.padding(6),
          ),
          decoration: BoxDecoration(
            color:        const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
          ),
          child: Row(
            children: [
CustomImage(imageSrc: AssetsPath.upload),
           SizedBox(width: ResponsiveHelper.width(8),),
              Text(
                AppStrings.upload.tr,
                style: GoogleFonts.poppins(
                  fontSize:   ResponsiveHelper.fontSize(12),
                  fontWeight: FontWeight.w500,
                  color:      Colors.white,
                ),
              ),
            ],
          ),
        );

      case _CardState.uploaded:
        return GestureDetector(
          onTap: () => _openSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(12),
              vertical:   ResponsiveHelper.padding(6),
            ),
            decoration: BoxDecoration(
              color:        const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
            ),
            child: Row(
              children: [
                CustomImage(imageSrc: AssetsPath.upload),
                SizedBox(width: ResponsiveHelper.width(8),),

                Text(
                  AppStrings.update.tr,
                  style: GoogleFonts.poppins(
                    fontSize:   ResponsiveHelper.fontSize(12),
                    fontWeight: FontWeight.w500,
                    color:      const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        );

      case _CardState.expired:
        return GestureDetector(
          onTap: () => _openSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(12),
              vertical:   ResponsiveHelper.padding(6),
            ),
            decoration: BoxDecoration(
              color:        const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
            ),
            child: Row(
              children: [
                CustomImage(imageSrc: AssetsPath.upload,imageColor: AppColors.red,),
                SizedBox(width: ResponsiveHelper.width(8),),
                Text(
                  AppStrings.renew.tr,
                  style: GoogleFonts.poppins(
                    fontSize:   ResponsiveHelper.fontSize(12),
                    fontWeight: FontWeight.w500,
                    color:      const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}