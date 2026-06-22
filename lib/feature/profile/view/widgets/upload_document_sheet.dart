import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/profile/model/user_document.dart';
import 'package:platchatapp/feature/profile/repository/upload_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Show Bottom Sheet ────────────────────────────────────────────────────────

Future<void> showUploadDocumentSheet(
    BuildContext context, {
      required String documentType,
      UserDocument? existingDoc, // null → create, non-null → update
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => UploadDocumentSheet(
      documentType: documentType,
      existingDoc: existingDoc,
    ),
  );
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────

class UploadDocumentSheet extends StatefulWidget {
  final String documentType;
  final UserDocument? existingDoc;

  const UploadDocumentSheet({
    super.key,
    required this.documentType,
    this.existingDoc,
  });

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  final controller = Get.find<UploadDocumentController>();

  late final TextEditingController _uniqueNumberCtrl;
  late final TextEditingController _expireDateCtrl;
  PlatformFile? _selectedFile;

  bool get _isEdit => widget.existingDoc != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing
    _uniqueNumberCtrl = TextEditingController(
      text: widget.existingDoc?.uniqueId ?? '',
    );
    _expireDateCtrl = TextEditingController(
      text: widget.existingDoc != null
          ? controller.toDisplayDate(widget.existingDoc!.expiryDate)
          : '',
    );
  }

  @override
  void dispose() {
    _uniqueNumberCtrl.dispose();
    _expireDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _selectDate() async {
    final firstDate = _isEdit ? DateTime(2000) : DateTime.now();
    DateTime initialDate = DateTime.now();
    final fromField = _parseDdMmYyyy(_expireDateCtrl.text);
    if (fromField != null) {
      initialDate = fromField;
    } else if (widget.existingDoc != null) {
      final fromApi = _parseApiYyyyMmDd(widget.existingDoc!.expiryDate);
      if (fromApi != null) initialDate = fromApi;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      _expireDateCtrl.text = '$d/$m/${picked.year}';
    }
  }

  // handle submit=================================
  Future<void> _handleSubmit() async {
    final uniqueId = _uniqueNumberCtrl.text.trim();
    final expiryDate = _expireDateCtrl.text.trim();

    if (uniqueId.isEmpty) {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.pleaseEnterUniqueNumber.tr,
      );
      return;
    }
    if (expiryDate.isEmpty) {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.pleaseEnterExpireDate.tr,
      );
      return;
    }
    if (_selectedFile == null || _selectedFile!.path == null) {
      CustomSnackbar.error(
        context: context,
        message: _isEdit ? AppStrings.pleaseSelectNewFile.tr : AppStrings.pleaseSelectFile.tr,
      );
      return;
    }

    if (_isEdit) {
      await controller.updateDocument(
        documentId: widget.existingDoc!.id,
        documentType: widget.documentType,
        uniqueId: uniqueId,
        expiryDate: expiryDate,
        filePath: _selectedFile!.path!,
        fileName: _selectedFile!.name,
        context: context,
      );
    } else {
      await controller.uploadDocument(
        documentType: widget.documentType,
        uniqueId: uniqueId,
        expiryDate: expiryDate,
        filePath: _selectedFile!.path!,
        fileName: _selectedFile!.name,
        context: context,
      );
    }
  }

  DateTime? _parseDdMmYyyy(String s) {
    try {
      final p = s.trim().split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseApiYyyyMmDd(String s) {
    try {
      final p = s.trim().split('-');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } catch (_) {
      return null;
    }
  }

  Future<void> _openExistingFile() async {
    final url = widget.existingDoc?.resolvedDocumentUrl ?? '';
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.couldNotOpenDocument.tr,
      );
    }
  }

  //RxBool get _loading =>  //controller.loadingObs(widget.documentType);

  bool get _loading => controller.isLoading(widget.documentType);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      margin: ResponsiveHelper.isTablet
          ? EdgeInsets.symmetric(
        horizontal:
        (ResponsiveHelper.screenWidth -
            ResponsiveHelper.maxContentWidth) /
            2,
      )
          : EdgeInsets.zero,
      padding: EdgeInsets.only(
        left: ResponsiveHelper.padding(24),
        right: ResponsiveHelper.padding(24),
        top: ResponsiveHelper.padding(16),
        bottom: ResponsiveHelper.padding(32) + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(20)),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEdit ? AppStrings.updateDocument.tr : AppStrings.uploadDocument.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.titleFontSize(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: ResponsiveHelper.iconSize(30),
                    height: ResponsiveHelper.iconSize(30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: ResponsiveHelper.iconSize(16),
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),

            // Type badge
            SizedBox(height: ResponsiveHelper.spacing(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(10),
                vertical: ResponsiveHelper.padding(4),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(20),
                ),
              ),
              child: Text(
                widget.documentType,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(11),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),

            if (_isEdit &&
                widget.existingDoc!.resolvedDocumentUrl.isNotEmpty) ...[
              SizedBox(height: ResponsiveHelper.spacing(10)),
              GestureDetector(
                onTap: _openExistingFile,
                child: Text(
                  AppStrings.viewDocument.tr,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],

            SizedBox(height: ResponsiveHelper.spacing(20)),

            // Unique Number
            _label(AppStrings.uniqueNumber.tr),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            _textField(
              controller: _uniqueNumberCtrl,
              hint: '123456789',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            // Expire Date
            _label(AppStrings.expireDate.tr),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _textField(
                  controller: _expireDateCtrl,
                  hint: AppStrings.ddMmYyyy.tr,
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: ResponsiveHelper.iconSize(18),
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            // Upload / Replace File
            _label(_isEdit ? AppStrings.replaceFile.tr : AppStrings.uploadFile.tr),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            GestureDetector(
              onTap: _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: ResponsiveHelper.height(110),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(12),
                  ),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: _selectedFile != null
                    ? _selectedFileView()
                    : _uploadPlaceholder(),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(28)),

            // Submit button
            // Obx(
            //       () => SizedBox(
            //     width: double.infinity,
            //     height: ResponsiveHelper.buttonHeight(52),
            //     child: ElevatedButton(
            //       onPressed: _loading.value ? null : _handleSubmit,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF2563EB),
            //         disabledBackgroundColor: const Color(0xFF93C5FD),
            //         elevation: 0,
            //         shape: const StadiumBorder(),
            //       ),
            //       child: _loading.value
            //           ? SizedBox(
            //         width: ResponsiveHelper.iconSize(22),
            //         height: ResponsiveHelper.iconSize(22),
            //         child: const CircularProgressIndicator(
            //           color: Colors.white,
            //           strokeWidth: 2.5,
            //         ),
            //       )
            //           : Text(
            //         _isEdit ? 'update'.tr : 'upload'.tr,
            //         style: GoogleFonts.poppins(
            //           fontSize: ResponsiveHelper.fontSize(16),
            //           fontWeight: FontWeight.w600,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),






            Obx(() => SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(52),
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                // child: _loading
                //     ? const CircularProgressIndicator(
                //   color: Colors.white,
                //   strokeWidth: 2.5,
                // )
                //     : Text(
                //   _isEdit ? AppStrings.update.tr : AppStrings.upload.tr,
                // ),


                child: _loading
                    ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
                    : Text(
                  _isEdit ? AppStrings.update.tr : AppStrings.upload.tr,
                ),

              ),
            )),


            SizedBox(height: ResponsiveHelper.spacing(28)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: ResponsiveHelper.fontSize(14),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF374151),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(15),
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: ResponsiveHelper.fontSize(15),
          ),
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.padding(14),
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      );

  Widget _uploadPlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.upload_outlined,
        size: ResponsiveHelper.iconSize(32),
        color: const Color(0xFF9CA3AF),
      ),
      SizedBox(height: ResponsiveHelper.spacing(6)),
      Text(
        AppStrings.tapToSelectFile.tr,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(13),
          color: const Color(0xFF9CA3AF),
        ),
      ),
      SizedBox(height: ResponsiveHelper.spacing(2)),
      Text(
        AppStrings.pdfJpgPngDocSupported.tr,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(11),
          color: const Color(0xFFD1D5DB),
        ),
      ),
    ],
  );

  Widget _selectedFileView() => Padding(
    padding:
    EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(12)),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(8),
            ),
          ),
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: const Color(0xFF2563EB),
            size: ResponsiveHelper.iconSize(24),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedFile!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(13),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(4)),
              Text(
                '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedFile = null),
          child: Icon(
            Icons.close,
            size: ResponsiveHelper.iconSize(18),
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  );
}