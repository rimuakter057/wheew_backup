
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/view/widgets/media_viewer_screen.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';




class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? type;
  final String? fileUrl;
  final String? fileName;      // ← API: file_name
  final String? fileMimeType;  // ← API: file_mime_type
  final int? fileSize;         // ← API: file_size
  final bool? isRead;
  final bool? isDelivered;
  final num? durationSeconds;  // ← API: durationSeconds (voice)

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.type,
    this.fileUrl,
    this.fileName,
    this.fileMimeType,
    this.fileSize,
    this.isRead,
    this.isDelivered,
    this.durationSeconds,
  });


  // ── type detection ──────────────────────────────────────────────────────────

  bool get _isFileMessage => type == 'FILE' || (fileUrl != null && fileUrl!.isNotEmpty);

  bool get _isImage {
    if (fileMimeType != null && fileMimeType!.startsWith('image/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.png') || url.endsWith('.jpg') ||
        url.endsWith('.jpeg') || url.endsWith('.webp') || url.endsWith('.gif');
  }

  bool get _isVideo {
    if (fileMimeType != null && fileMimeType!.startsWith('video/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  bool get _isAudio {
    if (fileMimeType != null && fileMimeType!.startsWith('audio/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp3') || url.endsWith('.aac') ||
        url.endsWith('.ogg') || url.endsWith('.m4a');
  }

  String get _fullUrl => ApiUrl.baseUrl + (fileUrl ?? '');

  String get _displayName =>
      fileName ?? fileUrl?.split('/').last.split('?').first ?? message;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openViewer({required BuildContext context}) {
    // Get.to(
    //       () => MediaViewerScreen(
    //     fileUrl: _fullUrl,
    //     messageType: fileMimeType ?? type,
    //     fileName: _displayName,
    //   ),
    //   transition: Transition.fadeIn,
    //   duration: const Duration(milliseconds: 220),
    // );





    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewerScreen(
          fileUrl: _fullUrl,
          messageType: fileMimeType ?? type,
          fileName: _displayName,
        ),
      ),
    );


        }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isFileMessage
                ? () {
              _openViewer(context: context);
            }
                : null,
            child: Container(
              constraints:
              BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
              margin: EdgeInsets.only(
                top: ResponsiveHelper.height(5),
                bottom: isMine
                    ? ResponsiveHelper.height(2)
                    : ResponsiveHelper.height(5),
              ),
              padding: _isImage
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(
                vertical: ResponsiveHelper.height(10),
                horizontal: ResponsiveHelper.width(14),
              ),
              decoration: BoxDecoration(
                color: _isImage
                    ? Colors.transparent
                    : isMine
                    ? AppColors.blue
                    : AppColors.white,
                border: Border.all(
                  color: _isImage
                      ? Colors.transparent
                      : isMine
                      ? AppColors.blue
                      : AppColors.greyBorder,
                ),
                borderRadius: BorderRadius.only(
                  topLeft:
                  Radius.circular(ResponsiveHelper.borderRadius(15)),
                  topRight:
                  Radius.circular(ResponsiveHelper.borderRadius(15)),
                  bottomLeft: isMine
                      ? Radius.circular(ResponsiveHelper.borderRadius(15))
                      : Radius.zero,
                  bottomRight: isMine
                      ? Radius.zero
                      : Radius.circular(
                      ResponsiveHelper.borderRadius(15)),
                ),
              ),
              child: _isFileMessage
                  ? _buildFileContent()
                  : Text(
                message,
                style: GoogleFonts.inter(
                  color: isMine ? AppColors.white : AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          if (isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 2),
              child: _buildReadReceipt(),
            ),
        ],
      ),
    );
  }

  // ── file content router ─────────────────────────────────────────────────────

  Widget _buildFileContent() {
    if (_isImage) return _buildImageBubble();
    if (_isVideo) return _buildVideoBubble();
    if (_isAudio) return _buildAudioBubble();
    return _buildFileBubble();
  }

  // ── image ───────────────────────────────────────────────────────────────────

  Widget _buildImageBubble() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          child: Image.network(
            _fullUrl,
            width: ResponsiveHelper.width(220),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: ResponsiveHelper.width(220),
                height: ResponsiveHelper.height(160),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildFileBubble(),
          ),
        ),
        // tap indicator overlay
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text('View',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── video ───────────────────────────────────────────────────────────────────

  Widget _buildVideoBubble() {
    return Container(
      width: ResponsiveHelper.width(220),
      height: ResponsiveHelper.height(130),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius:
        BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 36),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _formatSize(fileSize),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── audio ───────────────────────────────────────────────────────────────────

  Widget _buildAudioBubble() {
    return _VoiceBubble(
      audioUrl: _fullUrl,
      isMine: isMine,
      totalDurationSeconds: durationSeconds,
    );
  }


  // ── generic file ────────────────────────────────────────────────────────────


  Widget _buildFileBubble() {
    IconData icon = Icons.insert_drive_file_rounded;
    if (fileMimeType != null) {
      if (fileMimeType!.contains('pdf')) icon = Icons.picture_as_pdf_rounded;
      else if (fileMimeType!.contains('word') || fileMimeType!.contains('document'))
        icon = Icons.description_rounded;
      else if (fileMimeType!.contains('sheet') || fileMimeType!.contains('excel'))
        icon = Icons.table_chart_rounded;
      else if (fileMimeType!.contains('zip') || fileMimeType!.contains('rar'))
        icon = Icons.folder_zip_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: isMine ? AppColors.white : AppColors.blue,
            size: ResponsiveHelper.iconSize(26)),
        SizedBox(width: ResponsiveHelper.width(8)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isMine ? AppColors.white : AppColors.black,
                  fontSize: ResponsiveHelper.fontSize(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (fileSize != null)
                Text(
                  _formatSize(fileSize),
                  style: TextStyle(
                    color: isMine ? Colors.white60 : Colors.black38,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.width(6)),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: isMine ? Colors.white54 : Colors.black26,
          size: 13,
        ),
      ],
    );
  }

  // ── read receipt ────────────────────────────────────────────────────────────

  Widget _buildReadReceipt() {
    if (isRead == true) {
      return Icon(Icons.done_all, size: 15, color: AppColors.blue);
    } else if (isDelivered == true) {
      return Icon(Icons.done_all, size: 15, color: Colors.grey.shade400);
    } else {
      return Icon(Icons.done, size: 15, color: Colors.grey.shade400);
    }
  }
}

// ── Voice Bubble ─────────────────────────────────────────────────────────────

class _VoiceBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMine;
  final num? totalDurationSeconds;

  const _VoiceBubble({
    required this.audioUrl,
    required this.isMine,
    this.totalDurationSeconds,
  });

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Timer-based position ticker (backup when onPositionChanged stream is unreliable)
  Timer? _ticker;

  static const List<double> _waveHeights = [
    6, 16, 10, 22, 14, 8, 20, 13, 24, 9,
    18, 21, 8, 16, 23, 12, 19, 9, 22, 14,
  ];

  @override
  void initState() {
    super.initState();

    // Seed duration from API field while audio hasn't loaded yet
    if (widget.totalDurationSeconds != null && widget.totalDurationSeconds! > 0) {
      _duration = Duration(milliseconds: (widget.totalDurationSeconds! * 1000).toInt());
    }

    // Configure audio context — speaker output + media focus (Android)
    _player.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {},
      ),
    ));

    // Stop at end, don't loop
    _player.setReleaseMode(ReleaseMode.stop);

    // Duration — fired once when source is loaded/buffered
    _player.onDurationChanged.listen((d) {
      if (mounted && d.inMilliseconds > 0) {
        setState(() => _duration = d);
      }
    });

    // Position — fires ~every 200ms while playing
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    // Completion — reset everything
    _player.onPlayerComplete.listen((_) {
      _stopTicker();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    // State changes
    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      if (s == PlayerState.playing) {
        _startTicker();
        if (mounted) setState(() { _isPlaying = true; _isLoading = false; });
      } else {
        _stopTicker();
        if (mounted) setState(() => _isPlaying = false);
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (!mounted) return;
      try {
        final pos = await _player.getCurrentPosition();
        final dur = await _player.getDuration();
        if (mounted) {
          setState(() {
            if (pos != null) _position = pos;
            if (dur != null && dur.inMilliseconds > 0) _duration = dur;
          });
        }
      } catch (_) {}
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_hasError) return;

    if (_isPlaying) {
      await _player.pause();
      _stopTicker();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    if (mounted) setState(() { _isLoading = true; _hasError = false; });

    try {
      if (_position > Duration.zero) {
        // Resume from paused position
        await _player.resume();
      } else {
        // Fresh play from URL
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      debugPrint('🎵 VoiceBubble play error: $e');
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.isMine ? Colors.white : AppColors.blue;
    final Color muted = widget.isMine
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.35);
    final Color btnBg = widget.isMine
        ? Colors.white.withValues(alpha: 0.20)
        : AppColors.blue.withValues(alpha: 0.12);

    final double progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: ResponsiveHelper.width(230),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Play / Pause / Loading button ──────────────────────
          GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: btnBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    )
                  : _hasError
                      ? Icon(Icons.error_outline, color: Colors.red.shade300, size: 22)
                      : Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: accent,
                          size: _isPlaying ? 22 : 26,
                        ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Waveform + time ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // Waveform bars with colour-split progress
                SizedBox(
                  height: 28,
                  child: LayoutBuilder(builder: (_, constraints) {
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) async {
                        if (_duration == Duration.zero) return;
                        final frac = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                        final target = Duration(
                          milliseconds: (frac * _duration.inMilliseconds).toInt(),
                        );
                        await _player.seek(target);
                        if (mounted) setState(() => _position = target);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [

                          // Unplayed bars (muted)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: _waveHeights.map((h) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                                height: h,
                                decoration: BoxDecoration(
                                  color: muted.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            )).toList(),
                          ),

                          // Played bars overlay (accent)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: _waveHeights.map((h) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 1.2),
                                      height: h,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 5),

                // Time row
                Row(
                  children: [
                    Icon(
                      _isPlaying ? Icons.graphic_eq_rounded : Icons.mic,
                      size: 11,
                      color: muted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _fmt(_position),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      ' / ${_fmt(_duration)}',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

