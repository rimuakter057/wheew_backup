import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType { png, svg }

class CustomImage extends StatefulWidget {
  final String imageSrc;
  final Color? imageColor;
  final BlendMode? colorBlendMode;
  final double? height;
  final double? scale;
  final double? width;
  final double? sizeWidth;
  final ImageType imageType;
  final BoxFit? fit;
  final double horizontal;
  final double vertical;
  final BoxFit? boxFit;

  const CustomImage({
    required this.imageSrc,
    this.imageColor,
    this.colorBlendMode,
    this.sizeWidth,
    this.imageType = ImageType.svg,
    super.key,
    this.fit,
    this.scale,
    this.horizontal = 0.0,
    this.vertical = 0.0,
    this.boxFit,
    this.height,
    this.width,
  });

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  late Widget imageWidget;

  @override
  Widget build(BuildContext context) {
    if (widget.imageSrc.endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        widget.imageSrc,
        color: widget.imageColor,
        height: widget.height,
        width: widget.width,
        fit: widget.boxFit ?? widget.fit ?? BoxFit.contain,
      );
    } else if (widget.imageSrc.endsWith('.png')) {
      imageWidget = Image.asset(
        widget.imageSrc,
        fit: widget.fit,
        color: widget.imageColor,
        colorBlendMode: widget.colorBlendMode,
        height: widget.height,
        width: widget.width,
        scale: widget.scale ?? 1,
      );
    } else {
      imageWidget = const SizedBox(); // fallback safety
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.horizontal,
        vertical: widget.vertical,
      ),
      width: widget.sizeWidth,
      child: imageWidget,
    );
  }
}
