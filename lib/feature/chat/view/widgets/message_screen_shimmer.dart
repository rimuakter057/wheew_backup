import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// MessageScreen Shimmer
/// Use when: [chatController.isLoadingMessage.value && messages.isEmpty]
///
/// Replace:
///   Center(child: LoadingWidget(color: AppColors.blue))
/// With:
///   const MessageScreenShimmer()
class MessageScreenShimmer extends StatefulWidget {
  const MessageScreenShimmer({super.key});

  @override
  State<MessageScreenShimmer> createState() => _MessageScreenShimmerState();
}

class _MessageScreenShimmerState extends State<MessageScreenShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // bottom → top order (first item appears at bottom of screen)
  static const List<_BubbleConfig> bubbles = [
    _BubbleConfig(isMine: true, widthFactor: 0.55),
    _BubbleConfig(isMine: false, widthFactor: 0.48),
    _BubbleConfig(isMine: true, widthFactor: 0.70),
    _BubbleConfig(isMine: false, widthFactor: 0.55),
    _BubbleConfig(isMine: true, widthFactor: 0.40),
    _BubbleConfig(isMine: true, widthFactor: 0.65),
    _BubbleConfig(isMine: false, widthFactor: 0.50),
    _BubbleConfig(isMine: false, widthFactor: 0.72),
    _BubbleConfig(isMine: true, widthFactor: 0.45),
    _BubbleConfig(isMine: false, widthFactor: 0.60),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.width(16),
            vertical: ResponsiveHelper.height(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bubbles.reversed.map((config) {
              return _BubbleShimmer(
                isMine: config.isMine,
                widthFactor: config.widthFactor,
                progress: _animation.value,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _BubbleConfig {
  final bool isMine;
  final double widthFactor;

  const _BubbleConfig({required this.isMine, required this.widthFactor});
}

class _BubbleShimmer extends StatelessWidget {
  final bool isMine;
  final double widthFactor;
  final double progress;

  const _BubbleShimmer({
    required this.isMine,
    required this.widthFactor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width - ResponsiveHelper.width(32);

    final bubbleWidth = screenWidth * widthFactor;
    final double bubbleHeight = widthFactor > 0.60
        ? ResponsiveHelper.height(46)
        : ResponsiveHelper.height(34);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: bubbleWidth,
        height: bubbleHeight,
        margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(4)),
        decoration: BoxDecoration(
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
          gradient: _shimmerGradient(),
        ),
      ),
    );
  }

  LinearGradient _shimmerGradient() {
    final base = Colors.grey.shade200;
    final highlight = Colors.grey.shade100;

    return LinearGradient(
      begin: Alignment(-1.0 + progress * 3 - 1, 0),
      end: Alignment(-1.0 + progress * 3, 0),
      colors: [base, highlight, base],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
