import 'dart:io';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MediaViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String? messageType; // 'image' or 'pdf'
  final String? fileName;

  const MediaViewerScreen({
    super.key,
    required this.fileUrl,
    this.messageType,
    this.fileName,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  // pinch-to-zoom state
  final TransformationController _transformController =
  TransformationController();

  bool get _isImage =>
      widget.messageType == 'image' ||
          widget.fileUrl
              .toLowerCase()
              .contains(RegExp(r'\.(png|jpg|jpeg|webp|gif)'));

  String get _displayName =>
      widget.fileName ??
          widget.fileUrl.split('/').last.split('?').first;

  // â”€â”€ Save image to gallery using `gal` â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _saveImage() async {
    final hasAccess = await Gal.hasAccess(toAlbum: false);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: false);
      if (!granted) {
        _showSnackError(AppStrings.storagePermissionRequired.tr);
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$_displayName';

      await Dio().download(
        widget.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      await Gal.putImage(savePath); // Gallery à¦¤à§‡ save

      if (!mounted) return;
      setState(() => _isDownloading = false);



      CustomSnackbar.success(context: context, message: AppStrings.imageSaveToGallery.tr);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      _showSnackError(AppStrings.downloadFailed.tr);
    }
  }

  // â”€â”€ Download PDF then open with url_launcher â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _downloadAndOpenPdf() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted && !await Permission.manageExternalStorage.isGranted) {
        _showSnackError(AppStrings.storagePermissionRequired.tr);
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          saveDir = await getExternalStorageDirectory();
        }
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      final savePath = '${saveDir!.path}/$_displayName';

      await Dio().download(
        widget.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (!mounted) return;
      setState(() => _isDownloading = false);

      // url_launcher à¦¦à¦¿à¦¯à¦¼à§‡ file open à¦•à¦°à¦¾à¦° à¦šà§‡à¦·à§à¦Ÿà¦¾
      final uri = Uri.file(savePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // fallback: browser à¦ web url à¦¦à¦¿à¦¯à¦¼à§‡ open
        final webUri = Uri.parse(widget.fileUrl);
        if (await canLaunchUrl(webUri)) await launchUrl(webUri);
      }

      Get.snackbar(
        AppStrings.saved.tr,
        '${AppStrings.savedTo.tr} Downloads',
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      _showSnackError(AppStrings.downloadFailed.tr);
    }
  }

  void _showSnackError(String msg) {
    Get.snackbar(
      AppStrings.error.tr,
      msg,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          _displayName,
          style: const TextStyle(fontSize: 14, color: AppColors.white70),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isDownloading)
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isImage
                    ? Icons.save_alt_rounded
                    : Icons.download_rounded,
                color: AppColors.white,
              ),
              tooltip: _isImage ? AppStrings.saveToGallery.tr : AppStrings.download.tr,
              onPressed:
              _isImage ? _saveImage : _downloadAndOpenPdf,
            ),
        ],
      ),
      body: _isImage ? _buildImageViewer() : _buildPdfViewer(),
    );
  }

  // ── Full-screen image — pinch to zoom (InteractiveViewer) ─────────────────

  Widget _buildImageViewer() {
    return GestureDetector(
      onDoubleTap: () {
        // double tap = reset zoom
        _transformController.value = Matrix4.identity();
      },
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: Hero(
            tag: widget.fileUrl,
            child: CachedNetworkImage(
              imageUrl: widget.fileUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
              errorWidget: (_, __, ___) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded,
                      color: AppColors.white54, size: 64),
                  SizedBox(height: 12),
                  Text('Could not load image',
                      style: TextStyle(color: AppColors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ PDF viewer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildPdfViewer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_rounded,
                color: AppColors.red, size: 80),
            const SizedBox(height: 16),
            Text(
              _displayName,
              style:
              const TextStyle(color: AppColors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tapDownloadToOpen.tr,
              style:
              const TextStyle(color: AppColors.white38, fontSize: 12),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(AppStrings.downloadAndOpen.tr),
              onPressed: _isDownloading ? null : _downloadAndOpenPdf,
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: AppColors.white12,
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: AppColors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



