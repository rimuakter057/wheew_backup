
import 'dart:async';
import 'package:get/get.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/view/widgets/media_viewer_screen.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';




class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? type;
  final String? fileUrl;
  final String? fileName;      // â† API: file_name
  final String? fileMimeType;  // â† API: file_mime_type
  final int? fileSize;         // â† API: file_size
  final bool? isRead;
  final bool? isDelivered;
  final num? durationSeconds;  // â† API: durationSeconds (voice)
  final String? time;          // â† Timestamp (e.g. 7:29 PM)
  final String? avatarUrl;     // â† Receiver avatar

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
    this.time,
    this.avatarUrl,
  });



  bool get _isVoiceType => type == 'VOICE' || type == 'AUDIO';

  bool get _isFileMessage =>
      type == 'FILE' || type == 'VOICE' || type == 'AUDIO' ||
      (fileUrl != null && fileUrl!.isNotEmpty);

  bool get _canOpenViewer =>
      _isFileMessage && !_isVoiceType && !_isAudio;

  bool get _isImage {
    if (_isVoiceType) return false;
    if (fileMimeType != null && fileMimeType!.startsWith('image/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.png') || url.endsWith('.jpg') ||
        url.endsWith('.jpeg') || url.endsWith('.webp') || url.endsWith('.gif');
  }

  bool get _isVideo {
    if (_isVoiceType) return false;
    if (fileMimeType != null && fileMimeType!.startsWith('video/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  bool get _isAudio {
    // type field directly à¦¬à¦²à¦›à§‡ VOICE/AUDIO
    if (_isVoiceType) return true;
    if (fileMimeType != null && fileMimeType!.startsWith('audio/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp3') || url.endsWith('.aac') ||
        url.endsWith('.ogg') || url.endsWith('.m4a') || url.endsWith('.wav');
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

  @override
  Widget build(BuildContext context) {
    if (!isMine) {
      // Received Message with Avatar on bottom-left
      return Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: ResponsiveHelper.borderRadius(14),
              backgroundImage: NetworkImage(
                ImageHandler.imagesHandle(
                  avatarUrl,
                  isProfile: true,
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            Flexible(
              child: GestureDetector(
                onTap: _canOpenViewer ? () => _openViewer(context: context) : null,
                child: Container(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(260)),
                  padding: _isImage
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.height(10),
                          horizontal: ResponsiveHelper.width(14),
                        ),
                  decoration: BoxDecoration(
                    color: _isImage ? AppColors.transparent : AppColors.white,
                    border: Border.all(
                      color: _isImage ? AppColors.transparent : AppColors.greyShade200,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ResponsiveHelper.borderRadius(18)),
                      topRight: Radius.circular(ResponsiveHelper.borderRadius(18)),
                      bottomRight: Radius.circular(ResponsiveHelper.borderRadius(18)),
                      bottomLeft: Radius.circular(ResponsiveHelper.borderRadius(4)),
                    ),
                    boxShadow: _isImage
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: IntrinsicWidth(child: _buildBubbleContent()),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sent Message (Right-aligned)
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(4)),
        child: GestureDetector(
          onTap: _canOpenViewer ? () => _openViewer(context: context) : null,
          child: Container(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(260)),
            padding: _isImage
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.height(10),
                    horizontal: ResponsiveHelper.width(14),
                  ),
            decoration: BoxDecoration(
              color: _isImage ? AppColors.transparent : const Color(0xFFD6E4F0),
              border: Border.all(
                color: _isImage ? AppColors.transparent : const Color(0xFFC4D7E8),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveHelper.borderRadius(18)),
                topRight: Radius.circular(ResponsiveHelper.borderRadius(18)),
                bottomLeft: Radius.circular(ResponsiveHelper.borderRadius(18)),
                bottomRight: Radius.circular(ResponsiveHelper.borderRadius(4)),
              ),
            ),
            child: IntrinsicWidth(child: _buildBubbleContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleContent() {
    if (_isFileMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFileContent(),
          if (time != null && time!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  time!,
                  style: GoogleFonts.poppins(
                    color: AppColors.greyShade600,
                    fontSize: ResponsiveHelper.fontSize(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  _buildReadReceipt(),
                ],
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: ResponsiveHelper.fontSize(14),
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
        if (time != null && time!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  time!,
                  style: GoogleFonts.poppins(
                    color: AppColors.greyShade600,
                    fontSize: ResponsiveHelper.fontSize(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  _buildReadReceipt(),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildFileContent() {
    if (_isImage) return _buildImageBubble();
    if (_isVideo) return _buildVideoBubble();
    if (_isAudio) return _buildAudioBubble();
    return _buildFileBubble();
  }


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
                    strokeWidth: ResponsiveHelper.borderWidth(2),
                    color: AppColors.white70,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildFileBubble(),
          ),
        ),
        // tap indicator overlay
        Positioned(
          bottom: ResponsiveHelper.padding(6),
          right: ResponsiveHelper.padding(6),
          child: Container(
            padding: ResponsiveHelper.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.black45,
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
            ),
            child:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_out_map_rounded, color: AppColors.white, size: ResponsiveHelper.iconSize(12)),
                SizedBox(width: ResponsiveHelper.spacing(3)),
                Text(AppStrings.viewDocument.tr,


                    style: TextStyle(color: AppColors.white, fontSize: ResponsiveHelper.fontSize(10))),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildVideoBubble() {
    return Container(
      width: ResponsiveHelper.width(220),
      height: ResponsiveHelper.height(130),
      decoration: BoxDecoration(
        color: AppColors.black87,
        borderRadius:
        BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.black54,
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
            ),
          ),
          Container(
            padding: ResponsiveHelper.all(12),
            decoration: BoxDecoration(
              color: AppColors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded,
                color: AppColors.white, size: ResponsiveHelper.iconSize(36)),
          ),
          Positioned(
            bottom: ResponsiveHelper.padding(8),
            left: ResponsiveHelper.padding(8),
            child: Container(
              padding: ResponsiveHelper.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.black54,
                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded,
                      color: AppColors.white70, size: ResponsiveHelper.iconSize(12)),
                  SizedBox(width: ResponsiveHelper.spacing(4)),
                  Text(
                    _formatSize(fileSize),
                    style: TextStyle(
                        color: AppColors.white70, fontSize: ResponsiveHelper.fontSize(10)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAudioBubble() {
    return _VoiceBubble(
      audioUrl: _fullUrl,
      isMine: isMine,
      totalDurationSeconds: durationSeconds,
    );
  }



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
                    color: isMine ? AppColors.white60 : AppColors.black38,
                    fontSize: ResponsiveHelper.fontSize(11),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.width(6)),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: isMine ? AppColors.white54 : AppColors.black26,
          size: ResponsiveHelper.iconSize(13),
        ),
      ],
    );
  }


  Widget _buildReadReceipt() {
    if (isRead == true) {
      return Icon(Icons.done_all, size: ResponsiveHelper.iconSize(15), color: AppColors.blue);
    } else if (isDelivered == true) {
      return Icon(Icons.done_all, size: ResponsiveHelper.iconSize(15), color: AppColors.greyShade400);
    } else {
      return Icon(Icons.done, size: ResponsiveHelper.iconSize(15), color: AppColors.greyShade400);
    }
  }
}

// â”€â”€ Voice Bubble â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    // Prepare source to load metadata/duration
    if ((widget.totalDurationSeconds == null || widget.totalDurationSeconds! <= 0) &&
        widget.audioUrl.isNotEmpty) {
      _player.setSource(UrlSource(widget.audioUrl)).then((_) async {
        final dur = await _player.getDuration();
        if (mounted && dur != null && dur.inMilliseconds > 0) {
          setState(() => _duration = dur);
        }
      }).catchError((e) {
        debugPrint('ðŸŽµ VoiceBubble setSource error: $e');
      });
    }
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
      debugPrint('ðŸŽµ VoiceBubble play error: $e');
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
    final Color accent = widget.isMine ? AppColors.white : AppColors.blue;
    final Color muted = widget.isMine
        ? AppColors.white.withValues(alpha: 0.5)
        : AppColors.black.withValues(alpha: 0.35);
    final Color btnBg = widget.isMine
        ? AppColors.white.withValues(alpha: 0.20)
        : AppColors.blue.withValues(alpha: 0.12);

    final double progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: ResponsiveHelper.width(230),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: ResponsiveHelper.width(42),
              height: ResponsiveHelper.height(42),
              decoration: BoxDecoration(
                color: btnBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: ResponsiveHelper.borderWidth(1.5),
                ),
              ),
              child: _isLoading
                  ? Padding(
                      padding: ResponsiveHelper.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: ResponsiveHelper.borderWidth(2),
                        color: accent,
                      ),
                    )
                  : _hasError
                      ? Icon(Icons.error_outline, color: AppColors.red, size: ResponsiveHelper.iconSize(22))
                      : Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: accent,
                          size: ResponsiveHelper.iconSize(_isPlaying ? 22 : 26),
                        ),
            ),
          ),

          SizedBox(width: ResponsiveHelper.spacing(10)),

          // â”€â”€ Waveform + time â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // Waveform bars with colour-split progress
                SizedBox(
                  height: ResponsiveHelper.height(28),
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
                                margin: ResponsiveHelper.symmetric(horizontal: 1.2),
                                height: ResponsiveHelper.height(h),
                                decoration: BoxDecoration(
                                  color: muted.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(3)),
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
                                      margin: ResponsiveHelper.symmetric(horizontal: 1.2),
                                      height: ResponsiveHelper.height(h),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(3)),
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

                SizedBox(height: ResponsiveHelper.spacing(5)),

                // Time row
                Row(
                  children: [
                    Icon(
                      _isPlaying ? Icons.graphic_eq_rounded : Icons.mic,
                      size: ResponsiveHelper.iconSize(11),
                      color: muted,
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(3)),
                    Text(
                      _fmt(_position),
                      style: TextStyle(
                        color: accent,
                        fontSize: ResponsiveHelper.fontSize(10),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (_duration == Duration.zero && !_hasError) ...[
                      Text(
                        ' / ',
                        style: TextStyle(color: muted, fontSize: ResponsiveHelper.fontSize(10)),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.width(8),
                        height: ResponsiveHelper.width(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.2,
                          color: muted,
                        ),
                      ),
                    ] else ...[
                      Text(
                        ' / ${_fmt(_duration)}',
                        style: TextStyle(color: muted, fontSize: ResponsiveHelper.fontSize(10)),
                      ),
                    ],
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






