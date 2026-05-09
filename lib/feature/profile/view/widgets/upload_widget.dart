import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';



// ─── Show Bottom Sheet Function ───────────────────────────────────────────

Future<Map<String, String>?> showUploadDocumentSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,       // expands when keyboard opens
    useRootNavigator: true,         // renders above everything
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const UploadDocumentSheet(),
  );
}

// ─── Bottom Sheet Widget ──────────────────────────────────────────────────

class UploadDocumentSheet extends StatefulWidget {
  const UploadDocumentSheet({super.key});

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  final TextEditingController _uniqueNumberController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _uniqueNumberController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  // ── Pick file ──────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }
  // ── Date picker ────────────────────────────────────────────────────────
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      _expireDateController.text = '$d/$m/${picked.year}';
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────
  Future<void> _handleUpload() async {
    final uniqueNumber = _uniqueNumberController.text.trim();
    final expireDate = _expireDateController.text.trim();

    if (uniqueNumber.isEmpty) {
      _showSnackBar('Please enter a Unique Number');
      return;
    }
    if (expireDate.isEmpty) {
      _showSnackBar('Please enter an Expire Date');
      return;
    }
    if (_selectedFile == null) {
      _showSnackBar('Please select a file to upload');
      return;
    }

    setState(() => _isUploading = true);

    // TODO: replace with your actual API upload call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isUploading = false);

    if (mounted) {
      _showSnackBar('Document uploaded successfully!', isSuccess: true);
      Navigator.of(context).pop({
        'uniqueNumber': uniqueNumber,
        'expireDate': expireDate,
        'fileName': _selectedFile!.name,
      });
    }
  }

  void _showSnackBar(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? const Color(0xFF2563EB) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {


    // Pushes sheet up when keyboard appears
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
      ),
      // Center on tablet
      margin: ResponsiveHelper.isTablet
          ? EdgeInsets.symmetric(
        horizontal: (ResponsiveHelper.screenWidth - ResponsiveHelper.maxContentWidth) / 2,
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
            // ── Drag handle ──
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

            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload Document',
                  style: TextStyle(
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

            SizedBox(height: ResponsiveHelper.spacing(24)),

            // ── Unique Number ──
            _buildLabel('Unique Number'),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            _buildTextField(
              controller: _uniqueNumberController,
              hint: '5458 54 554',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            // ── Expire Date ──
            _buildLabel('Expire Date'),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _expireDateController,
                  hint: '24/08/2024',
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: ResponsiveHelper.iconSize(18),
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            // ── Upload File ──
            _buildLabel('Upload File'),
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
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: _selectedFile != null
                    ? _buildSelectedFileView()
                    : _buildUploadPlaceholder(),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(28)),

            // ── Upload Button ──
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(52),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: _isUploading
                    ? SizedBox(
                  width: ResponsiveHelper.iconSize(22),
                  height: ResponsiveHelper.iconSize(22),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: ResponsiveHelper.fontSize(14),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF374151),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextField(
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
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.upload_outlined,
        size: ResponsiveHelper.iconSize(32),
        color: const Color(0xFF9CA3AF),
      ),
      SizedBox(height: ResponsiveHelper.spacing(6)),
      Text(
        'Tap to select file',
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(13),
          color: const Color(0xFF9CA3AF),
        ),
      ),
      SizedBox(height: ResponsiveHelper.spacing(2)),
      Text(
        'PDF, JPG, PNG, DOC supported',
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(11),
          color: const Color(0xFFD1D5DB),
        ),
      ),
    ],
  );

  Widget _buildSelectedFileView() => Padding(
    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(12)),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
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

// ─── Demo ─────────────────────────────────────────────────────────────────

void main() => runApp(const _DemoApp());

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Document',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      home: const _DemoScreen(),
    );
  }
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B7280),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showUploadDocumentSheet(context),
          child: const Text('Open Upload Sheet'),
        ),
      ),
    );
  }
}