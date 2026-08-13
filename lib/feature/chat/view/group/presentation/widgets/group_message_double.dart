import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/model/group_message_response_model.dart';
import 'package:platchatapp/feature/chat/view/widgets/media_viewer_screen.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

// -- Group Message Bubble ------------------------------------------------------

class GroupMessageBubble extends StatelessWidget {
  final GroupMessageResponseModel msg;
  final bool isMine;
  final String senderName;
  final String senderAvatar;
  final String text;
  final String time;

  const GroupMessageBubble({
    super.key,
    required this.msg,
    required this.isMine,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: ResponsiveHelper.iconSize(16),
                  backgroundImage: senderAvatar.isNotEmpty
                      ? NetworkImage(
                          ImageHandler.imagesHandle(
                            senderAvatar,
                            isProfile: true,
                          ),
                        )
                      : null,
                  backgroundColor: AppColors.blue.withValues(alpha: 0.2),
                  child: senderAvatar.isEmpty
                      ? Icon(
                          Icons.person,
                          size: ResponsiveHelper.iconSize(16),
                          color: AppColors.blue,
                        )
                      : null,
                ),
                SizedBox(width: ResponsiveHelper.width(6)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: ResponsiveHelper.width(4),
                        bottom: ResponsiveHelper.height(2),
                      ),
                      child: Text(
                        senderName,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(11),
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _Bubble(msg: msg, isMine: isMine, time: time, text: text),
                  ],
                ),
              ],
            ),

          if (isMine) _Bubble(msg: msg, isMine: isMine, time: time, text: text),
        ],
      ),
    );
  }
}


class _Bubble extends StatelessWidget {
  final GroupMessageResponseModel msg;
  final bool isMine;
  final String time;
  final String text;

  const _Bubble({
    required this.msg,
    required this.isMine,
    required this.time,
    required this.text,
  });

  bool get _isVoiceType => msg.type == 'VOICE' || msg.type == 'AUDIO';

  bool get _isFileMessage =>
      msg.type == 'FILE' ||
      msg.type == 'VOICE' ||
      msg.type == 'AUDIO' ||
      (msg.fileUrl != null && msg.fileUrl!.isNotEmpty);

  bool get _isAudio {
    if (_isVoiceType) return true;
    if (msg.fileMimeType != null && msg.fileMimeType!.startsWith('audio/')) return true;
    final url = (msg.fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp3') || url.endsWith('.aac') ||
        url.endsWith('.ogg') || url.endsWith('.m4a') || url.endsWith('.wav');
  }

  bool get _isImage {
    if (_isVoiceType) return false;
    if (msg.fileMimeType != null && msg.fileMimeType!.startsWith('image/')) return true;
    final url = (msg.fileUrl ?? '').toLowerCase();
    return url.endsWith('.png') || url.endsWith('.jpg') ||
        url.endsWith('.jpeg') || url.endsWith('.webp') || url.endsWith('.gif');
  }

  bool get _isVideo {
    if (_isVoiceType) return false;
    if (msg.fileMimeType != null && msg.fileMimeType!.startsWith('video/')) return true;
    final url = (msg.fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  bool get _canOpenViewer =>
      _isFileMessage && !_isVoiceType && !_isAudio && !msg.isSending;

  String get _fullUrl => ApiUrl.baseUrl + (msg.fileUrl ?? '');

  String get _displayName =>
      msg.fileName ?? msg.fileUrl?.split('/').last.split('?').first ?? text;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _canOpenViewer
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MediaViewerScreen(
                    fileUrl: _fullUrl,
                    messageType: msg.fileMimeType ?? msg.type,
                    fileName: _displayName,
                  ),
                ),
              )
          : null,
      child: Container(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
        margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(2)),
        padding: _isImage
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(
                vertical: ResponsiveHelper.height(10),
                horizontal: ResponsiveHelper.width(14),
              ),
        decoration: BoxDecoration(
          color: _isImage
              ? AppColors.transparent
              : isMine
                  ? AppColors.blue
                  : AppColors.white,
          border: Border.all(
            color: _isImage
                ? AppColors.transparent
                : isMine
                    ? AppColors.blue
                    : AppColors.greyBorder,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
            topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
            bottomLeft: isMine
                ? Radius.circular(ResponsiveHelper.borderRadius(15))
                : Radius.zero,
            bottomRight: isMine
                ? Radius.zero
                : Radius.circular(ResponsiveHelper.borderRadius(15)),
          ),
        ),
        child: IntrinsicWidth(
          child: _isFileMessage ? _buildFileMessageContent() : _buildTextContent(),
        ),
      ),
    );
  }

  Widget _buildFileMessageContent() {
    Widget fileContent = _buildFileContent();
    if (msg.isSending) {
      fileContent = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.55, child: fileContent),
          SizedBox(
            width: ResponsiveHelper.iconSize(26),
            height: ResponsiveHelper.iconSize(26),
            child: CircularProgressIndicator(
              strokeWidth: ResponsiveHelper.borderWidth(2.4),
              color: isMine ? AppColors.white : AppColors.blue,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        fileContent,
        if (text.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
              _isImage || _isVideo ? ResponsiveHelper.width(10) : 0,
              ResponsiveHelper.height(6),
              _isImage || _isVideo ? ResponsiveHelper.width(10) : 0,
              0,
            ),
            child: Text(
              text,
              // Image/video bubbles sit on a transparent background (not the
              // isMine-colored bubble), so the caption always needs a dark,
              // page-appropriate color instead of the white/black pairing
              // used for the colored text bubble below.
              style: GoogleFonts.inter(
                color: (_isImage || _isVideo)
                    ? const Color(0xFF1E293B)
                    : (isMine ? AppColors.white : AppColors.black),
                fontSize: ResponsiveHelper.fontSize(15),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        SizedBox(height: ResponsiveHelper.height(4)),
        Text(
          time,
          style: GoogleFonts.inter(
            color: isMine ? AppColors.white : AppColors.black,
            fontSize: ResponsiveHelper.fontSize(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            color: isMine ? AppColors.white : AppColors.black,
            fontSize: ResponsiveHelper.fontSize(15),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: ResponsiveHelper.height(4)),
        Text(
          time,
          style: GoogleFonts.inter(
            color: isMine ? AppColors.white : AppColors.black,
            fontSize: ResponsiveHelper.fontSize(10),
            fontWeight: FontWeight.w400,
          ),
        ),
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
    final bool useLocalPreview = msg.isSending && msg.localFilePath != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      child: useLocalPreview
          ? Image.file(
              File(msg.localFilePath!),
              width: ResponsiveHelper.width(220),
              height: ResponsiveHelper.height(220),
              fit: BoxFit.cover,
            )
          : Image.network(
              _fullUrl,
              width: ResponsiveHelper.width(220),
              // Bounded height — without this, a tall/portrait photo has no
              // height cap and renders at its full aspect-ratio height,
              // making the bubble look like a giant blank rectangle instead
              // of a normal-sized photo.
              height: ResponsiveHelper.height(220),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: ResponsiveHelper.width(220),
                  height: ResponsiveHelper.height(220),
                  color: AppColors.greyShade200,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.blue)),
                );
              },
              errorBuilder: (_, __, ___) => _buildFileBubble(),
            ),
    );
  }


  Widget _buildVideoBubble() {
    return Container(
      width: ResponsiveHelper.width(220),
      height: ResponsiveHelper.height(130),
      decoration: BoxDecoration(
        color: AppColors.black87,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.black54,
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
            ),
          ),
          Container(
            padding: ResponsiveHelper.all(12),
            decoration: const BoxDecoration(
              color: AppColors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded, color: AppColors.white, size: ResponsiveHelper.iconSize(36)),
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
                  Icon(Icons.videocam_rounded, color: AppColors.white70, size: ResponsiveHelper.iconSize(12)),
                  SizedBox(width: ResponsiveHelper.spacing(4)),
                  Text(
                    _formatSize(msg.fileSize),
                    style: TextStyle(color: AppColors.white70, fontSize: ResponsiveHelper.fontSize(10)),
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
    return _GroupVoiceBubble(
      audioUrl: _fullUrl,
      isMine: isMine,
      totalDurationSeconds: msg.durationSeconds,
    );
  }


  Widget _buildFileBubble() {
    IconData icon = Icons.insert_drive_file_rounded;
    if (msg.fileMimeType != null) {
      if (msg.fileMimeType!.contains('pdf')) icon = Icons.picture_as_pdf_rounded;
      else if (msg.fileMimeType!.contains('word') || msg.fileMimeType!.contains('document'))
        icon = Icons.description_rounded;
      else if (msg.fileMimeType!.contains('sheet') || msg.fileMimeType!.contains('excel'))
        icon = Icons.table_chart_rounded;
      else if (msg.fileMimeType!.contains('zip') || msg.fileMimeType!.contains('rar'))
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
              if (msg.fileSize != null)
                Text(
                  _formatSize(msg.fileSize),
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
}


class _GroupVoiceBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMine;
  final num? totalDurationSeconds;

  const _GroupVoiceBubble({
    required this.audioUrl,
    required this.isMine,
    this.totalDurationSeconds,
  });

  @override
  State<_GroupVoiceBubble> createState() => _GroupVoiceBubbleState();
}

class _GroupVoiceBubbleState extends State<_GroupVoiceBubble> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Timer? _ticker;

  static const List<double> _waveHeights = [
    6, 16, 10, 22, 14, 8, 20, 13, 24, 9,
    18, 21, 8, 16, 23, 12, 19, 9, 22, 14,
  ];

  @override
  void initState() {
    super.initState();

    // Seed duration from API field if available
    if (widget.totalDurationSeconds != null && widget.totalDurationSeconds! > 0) {
      _duration = Duration(milliseconds: (widget.totalDurationSeconds! * 1000).toInt());
    }

    // Configure audio context
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

    _player.setReleaseMode(ReleaseMode.stop);

    _player.onDurationChanged.listen((d) {
      if (mounted && d.inMilliseconds > 0) {
        setState(() => _duration = d);
      }
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _player.onPlayerComplete.listen((_) {
      _stopTicker();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

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

    // Pre-fetch metadata/duration if not provided by API
    if ((widget.totalDurationSeconds == null || widget.totalDurationSeconds! <= 0) &&
        widget.audioUrl.isNotEmpty) {
      _player.setSource(UrlSource(widget.audioUrl)).then((_) async {
        final dur = await _player.getDuration();
        if (mounted && dur != null && dur.inMilliseconds > 0) {
          setState(() => _duration = dur);
        }
      }).catchError((e) {
        debugPrint('ðŸŽµ GroupVoiceBubble setSource error: $e');
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
        await _player.resume();
      } else {
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      debugPrint('ðŸŽµ GroupVoiceBubble play error: $e');
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

          // -- Play / Pause / Loading button ----------------------
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
                      child: CircularProgressIndicator(strokeWidth: ResponsiveHelper.borderWidth(2), color: accent),
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

          // -- Waveform + time ------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // Waveform with colour-split progress
                SizedBox(
                  height: ResponsiveHelper.height(28),
                  child: LayoutBuilder(builder: (_, constraints) {
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) async {
                        if (_duration == Duration.zero) return;
                        final frac =
                            (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
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
                            children: _waveHeights
                                .map((h) => Expanded(
                                      child: Container(
                                        margin: ResponsiveHelper.symmetric(horizontal: 1.2),
                                        height: ResponsiveHelper.height(h),
                                        decoration: BoxDecoration(
                                          color: muted.withValues(alpha: 0.45),
                                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(3)),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),

                          // Played bars (accent)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: _waveHeights
                                      .map((h) => Expanded(
                                            child: Container(
                                              margin: ResponsiveHelper.symmetric(horizontal: 1.2),
                                              height: ResponsiveHelper.height(h),
                                              decoration: BoxDecoration(
                                                color: accent.withValues(alpha: 0.9),
                                                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(3)),
                                              ),
                                            ),
                                          ))
                                      .toList(),
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



