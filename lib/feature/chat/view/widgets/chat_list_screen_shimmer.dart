import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// ChatList Shimmer Screen
/// Use this widget when [isLoadingChat == true && userChatList.isEmpty]
class ChatListShimmer extends StatefulWidget {
  const ChatListShimmer({super.key});

  @override
  State<ChatListShimmer> createState() => _ChatListShimmerState();
}

class _ChatListShimmerState extends State<ChatListShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
      builder: (context, child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.padding(5)),
          itemCount: 7,
          // separatorBuilder: (_, _) => Divider(
          //   height: 1,
          //   indent: ResponsiveHelper.padding(72),
          //   endIndent: ResponsiveHelper.padding(16),
          //   color: AppColors.greyShade200,
          // ),
          itemBuilder: (context, index) {
            return _ChatTileShimmer(shimmerValue: _animation.value);
          },
        );
      },
    );
  }
}

class _ChatTileShimmer extends StatelessWidget {
  final double shimmerValue;

  const _ChatTileShimmer({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.greyShade200;
    final highlightColor = AppColors.greyShade50;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(16),
        vertical: ResponsiveHelper.padding(10),
      ),
      child: Row(
        children: [
          /// Avatar shimmer
          _ShimmerBox(
            width: ResponsiveHelper.padding(60),
            height: ResponsiveHelper.padding(60),
            borderRadius: ResponsiveHelper.padding(40),
            shimmerValue: shimmerValue,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(width: ResponsiveHelper.padding(12)),

          /// Text shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name line
                _ShimmerBox(
                  width: double.infinity,
                  height: ResponsiveHelper.padding(14),
                  widthFactor: 0.55,
                  borderRadius: ResponsiveHelper.padding(6),
                  shimmerValue: shimmerValue,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                SizedBox(height: ResponsiveHelper.padding(8)),

                /// Message line
                _ShimmerBox(
                  width: double.infinity,
                  height: ResponsiveHelper.padding(12),
                  widthFactor: 0.80,
                  borderRadius: ResponsiveHelper.padding(6),
                  shimmerValue: shimmerValue,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),

          SizedBox(width: ResponsiveHelper.padding(12)),

          /// Time shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(
                width: ResponsiveHelper.padding(38),
                height: ResponsiveHelper.padding(10),
                borderRadius: ResponsiveHelper.padding(5),
                shimmerValue: shimmerValue,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double? widthFactor;
  final double borderRadius;
  final double shimmerValue;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.widthFactor,
    required this.borderRadius,
    required this.shimmerValue,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = widthFactor != null
            ? constraints.maxWidth * widthFactor!
            : width;

        return Container(
          width: effectiveWidth,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                baseColor,
                Color.lerp(
                  baseColor,
                  highlightColor,
                  _clamp((shimmerValue + 1) / 2),
                )!,
                baseColor,
              ],
              transform: GradientRotation(shimmerValue * 0.3),
            ),
          ),
        );
      },
    );
  }

  double _clamp(double val) => val.clamp(0.0, 1.0);
}



