// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/utils/language/app_string.dart';
//
// class RadiusFilterSheet extends StatefulWidget {
//   final int initialRadiusMeter;
//   final ValueChanged<int> onApply;
//
//   const RadiusFilterSheet({
//     super.key,
//     required this.initialRadiusMeter,
//     required this.onApply,
//   });
//
//   static Future<void> show(
//       BuildContext context, {
//         required int initialRadiusMeter,
//         required ValueChanged<int> onApply,
//       }) {
//     return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.transparent,
//       builder: (_) => RadiusFilterSheet(
//         initialRadiusMeter: initialRadiusMeter,
//         onApply: onApply,
//       ),
//     );
//   }
//
//   @override
//   State<RadiusFilterSheet> createState() => _RadiusFilterSheetState();
// }
//
// class _RadiusFilterSheetState extends State<RadiusFilterSheet> {
//   late double _radius; // à¦®à¦¿à¦Ÿà¦¾à¦°à§‡, slider double à¦²à¦¾à¦—à¦¬à§‡ à¦¤à¦¾à¦‡ double à¦°à¦¾à¦–à¦¾
//   late TextEditingController _textCtrl;
//
//   static const double _minRadius = 100;   // 100 m
//   static const double _maxRadius = 20000; // 20,000 m = 20 km
//
//   @override
//   void initState() {
//     super.initState();
//     _radius = widget.initialRadiusMeter.toDouble().clamp(_minRadius, _maxRadius);
//     _textCtrl = TextEditingController(text: _radius.round().toString());
//   }
//
//   @override
//   void dispose() {
//     _textCtrl.dispose();
//     super.dispose();
//   }
//
//   void _updateRadius(double value) {
//     setState(() {
//       _radius = value.clamp(_minRadius, _maxRadius);
//       _textCtrl.text = _radius.round().toString();
//     });
//   }
//
//   void _onTextChanged(String value) {
//     final parsed = double.tryParse(value);
//     if (parsed != null) {
//       setState(() {
//         _radius = parsed.clamp(_minRadius, _maxRadius);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // â”€â”€ drag handle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: AppColors.greyShade300,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//
//             // â”€â”€ title row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Search Radius',
//                   style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
//                 ),
//                 Icon(Icons.tune, color: const Color(0xFF185FA5)),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Show parking spots within this distance',
//               style: TextStyle(fontSize: 13, color: AppColors.greyShade600),
//             ),
//             const SizedBox(height: 20),
//
//             // â”€â”€ radius value badge + manual input â”€â”€â”€â”€â”€â”€
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE6F1FB),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 70,
//                         child: TextField(
//                           controller: _textCtrl,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF185FA5),
//                           ),
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           onChanged: _onTextChanged,
//                         ),
//                       ),
//                       const Text(
//                         ' m',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF185FA5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 _quickChip(500),
//                 const SizedBox(width: 8),
//                 _quickChip(1000),
//                 const SizedBox(width: 8),
//                 _quickChip(5000),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // â”€â”€ slider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//             SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 activeTrackColor: const Color(0xFF185FA5),
//                 inactiveTrackColor: const Color(0xFFE6F1FB),
//                 thumbColor: const Color(0xFF185FA5),
//                 overlayColor: const Color(0xFF185FA5).withOpacity(0.15),
//                 trackHeight: 4,
//               ),
//               child: Slider(
//                 value: _radius,
//                 min: _minRadius,
//                 max: _maxRadius,
//                 onChanged: _updateRadius,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('${_minRadius.toInt()} m',
//                       style: TextStyle(fontSize: 11, color: AppColors.greyShade500)),
//                   Text('${(_maxRadius / 1000).toInt()} km',
//                       style: TextStyle(fontSize: 11, color: AppColors.greyShade500)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // â”€â”€ apply button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF185FA5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 elevation: 0,
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 widget.onApply(_radius.round());
//               },
//               child: Text(
//                 'Apply (${_radius.round()} m)',
//                 style: const TextStyle(
//                   color: AppColors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _quickChip(int meterValue) {
//     final bool selected = _radius.round() == meterValue;
//     final String label = meterValue >= 1000
//         ? '${(meterValue / 1000).toStringAsFixed(meterValue % 1000 == 0 ? 0 : 1)} km'
//         : '$meterValue m';
//     return GestureDetector(
//       onTap: () => _updateRadius(meterValue.toDouble()),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? const Color(0xFF185FA5) : AppColors.greyShade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: selected ? AppColors.white : AppColors.greyShade700,
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/tracked_bottom_sheet.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class RadiusFilterSheet extends StatefulWidget {
  final int initialRadiusMeter;
  final ValueChanged<int> onApply;

  const RadiusFilterSheet({
    super.key,
    required this.initialRadiusMeter,
    required this.onApply,
  });

  static Future<void> show(
      BuildContext context, {
        required int initialRadiusMeter,
        required ValueChanged<int> onApply,
      }) {
    return showTrackedBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => RadiusFilterSheet(
        initialRadiusMeter: initialRadiusMeter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<RadiusFilterSheet> createState() => _RadiusFilterSheetState();
}

class _RadiusFilterSheetState extends State<RadiusFilterSheet> {
  late double _radius; // à¦®à¦¿à¦Ÿà¦¾à¦°à§‡

  // â”€â”€ à¦…à¦¬à§à¦¯à¦¬à¦¹à§ƒà¦¤ à¦²à¦œà¦¿à¦• (à¦•à¦®à§‡à¦¨à§à¦Ÿ à¦•à¦°à§‡ à¦°à¦¾à¦–à¦¾ à¦¹à¦²à§‹) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // late TextEditingController _textCtrl;
  // void _onTextChanged(String value) {
  //   final parsed = double.tryParse(value);
  //   if (parsed != null) {
  //     setState(() {
  //       _radius = parsed.clamp(_minRadius, _maxRadius);
  //     });
  //   }
  // }

  static const double _minRadius = 100;   // 100 m
  static const double _maxRadius = 20000; // 20,000 m = 20 km

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadiusMeter.toDouble().clamp(_minRadius, _maxRadius);
    // _textCtrl = TextEditingController(text: _radius.round().toString());
  }

  @override
  void dispose() {
    // _textCtrl.dispose();
    super.dispose();
  }

  void _updateRadius(double value) {
    setState(() {
      _radius = value.clamp(_minRadius, _maxRadius);
      // _textCtrl.text = _radius.round().toString();
    });
  }

  // à¦­à§à¦¯à¦¾à¦²à§ à¦«à¦°à¦®à§à¦¯à¦¾à¦Ÿ à¦•à¦°à¦¾à¦° à¦œà¦¨à§à¦¯ à¦¹à§‡à¦²à§à¦ªà¦¾à¦° à¦«à¦¾à¦‚à¦¶à¦¨ (à¦¯à§‡à¦®à¦¨: 1000m -> 1 km)
  String _formatRadius(double value) {
    int meter = value.round();
    if (meter >= 1000) {
      return '${(meter / 1000).toStringAsFixed(meter % 1000 == 0 ? 0 : 1)} km';
    }
    return '$meter m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          // à¦‡à¦®à§‡à¦œà§‡à¦° à¦®à¦¤à§‹ à¦¹à¦¾à¦²à¦•à¦¾ à¦—à§à¦°à§‡à¦¡à¦¿à§Ÿà§‡à¦¨à§à¦Ÿ à¦¬à§à¦¯à¦¾à¦•à¦—à§à¦°à¦¾à¦‰à¦¨à§à¦¡
          gradient: LinearGradient(
            colors: [AppColors.greyShade100, AppColors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveHelper.borderRadius(32))),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.padding(24),
          ResponsiveHelper.padding(16),
          ResponsiveHelper.padding(24),
          ResponsiveHelper.padding(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ drag handle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Center(
              child: Container(
                width: ResponsiveHelper.width(48),
                height: ResponsiveHelper.height(5),
                margin: EdgeInsets.only(bottom: ResponsiveHelper.padding(24)),
                decoration: BoxDecoration(
                  color: AppColors.greyShade400,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                ),
              ),
            ),

            // â”€â”€ title & subtitle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
             Text(
              AppStrings.searchParkingSpotWithin.tr,
              style: context.bodyMedium.copyWith(color: AppColors.black)
            ),
            SizedBox(height: ResponsiveHelper.spacing(6)),
            Text(
              AppStrings.chooseDistanceRange.tr,

              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(14),
                color: AppColors.greyShade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(48)), // à¦¸à§à¦²à¦¾à¦‡à¦¡à¦¾à¦° à¦Ÿà§à¦²à¦Ÿà¦¿à¦ªà§‡à¦° à¦œà¦¨à§à¦¯ à¦à¦•à¦Ÿà§ à¦¬à§‡à¦¶à¦¿ à¦¸à§à¦ªà§‡à¦¸ à¦°à¦¾à¦–à¦¾ à¦¹à§Ÿà§‡à¦›à§‡

            // â”€â”€ slider with custom thumb & tooltip â”€â”€â”€â”€â”€â”€
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: ResponsiveHelper.height(6),
                activeTrackColor: const Color(0xFF0066C4),
                inactiveTrackColor: AppColors.greyShade200,
                // à¦•à¦¾à¦¸à§à¦Ÿà¦® à¦¥à¦¾à¦®à§à¦¬ à¦¶à§‡à¦ª à¦¯à¦¾ à¦‡à¦®à§‡à¦œà§‡à¦° à¦®à¦¤à§‹ à¦­à§à¦¯à¦¾à¦²à§ à¦¦à§‡à¦–à¦¾à¦¬à§‡
                thumbShape: CustomSliderThumbShape(
                  value: _formatRadius(_radius),
                  thumbRadius: ResponsiveHelper.width(10),
                ),
                overlayColor: const Color(0xFF0066C4).withOpacity(0.1),
              ),
              child: Slider(
                value: _radius,
                min: _minRadius,
                max: _maxRadius,
                onChanged: _updateRadius,
              ),
            ),

            // â”€â”€ min & max labels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('100 m', style: TextStyle(fontSize: ResponsiveHelper.fontSize(13), color: AppColors.greyShade600, fontWeight: FontWeight.w500)),
                  Text('20 km', style: TextStyle(fontSize: ResponsiveHelper.fontSize(13), color: AppColors.greyShade600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(24)),

            // â”€â”€ Quick Select Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
             Text(
              AppStrings.quickSelect.tr,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(16)),

            // à¦‡à¦®à§‡à¦œà§‡à¦° à¦®à¦¤à§‹ à§¨ à¦²à¦¾à¦‡à¦¨à§‡à¦° à¦—à§à¦°à¦¿à¦¡ à¦²à§à¦• à¦¤à§ˆà¦°à¦¿ à¦•à¦°à¦¤à§‡ Wrap à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à¦¾ à¦¹à§Ÿà§‡à¦›à§‡
            Wrap(
              spacing: ResponsiveHelper.spacing(12),
              runSpacing: ResponsiveHelper.spacing(12),
              children: [
                _quickChip(100),
                _quickChip(250),
                _quickChip(500),
                _quickChip(1000),
                _quickChip(5000),
                _quickChip(10000),
              ],
            ),
            SizedBox(height: ResponsiveHelper.spacing(36)),

            // â”€â”€ apply button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: double.infinity,
              height: ResponsiveHelper.height(54),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(28)),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0074E4), Color(0xFF0052A3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052A3).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: CustomGradientButton(
                label: AppStrings.apply.tr,
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onApply(_radius.round());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Quick Select Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _quickChip(int meterValue) {
    final bool selected = _radius.round() == meterValue;
    final String label = _formatRadius(meterValue.toDouble());

    return GestureDetector(
      onTap: () => _updateRadius(meterValue.toDouble()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: ResponsiveHelper.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF005DB3) : AppColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
          border: Border.all(
            color: selected ? AppColors.transparent : AppColors.greyShade300,
            width: ResponsiveHelper.borderWidth(1),
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: const Color(0xFF005DB3).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(14),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.white : AppColors.greyShade700,
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Custom Slider Thumb Paint (à¦‡à¦®à§‡à¦œà§‡à¦° à¦®à¦¤à§‹ à¦¬à§à¦²à§à¦¯à¦¾à¦• à¦¬à¦¾à¦¬à¦² à¦‡à¦«à§‡à¦•à§à¦Ÿ) â”€â”€
class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final String value;

  const CustomSliderThumbShape({
    required this.thumbRadius,
    required this.value,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // à§§. à¦¸à§à¦²à¦¾à¦‡à¦¡à¦¾à¦°à§‡à¦° à¦­à§‡à¦¤à¦°à§‡à¦° à¦¨à§€à¦² à¦°à¦™à§‡à¦° à¦¥à¦¾à¦®à§à¦¬/à¦¡à¦Ÿ à¦†à¦à¦•à¦¾
    final fillPaint = Paint()
      ..color = const Color(0xFF0066C4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);

    // à§¨. à¦‰à¦ªà¦°à§‡à¦° à¦¬à§à¦²à§à¦¯à¦¾à¦• à¦Ÿà§à¦²à¦Ÿà¦¿à¦ª/à¦¬à¦¾à¦¬à¦² à¦†à¦à¦•à¦¾
    final boxPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    // à¦Ÿà§à¦²à¦Ÿà¦¿à¦ª à¦Ÿà§‡à¦•à§à¦¸à¦Ÿ à¦•à¦¨à¦«à¦¿à¦—à¦¾à¦°à§‡à¦¶à¦¨
    final textPainter = TextPainter(
      text: TextSpan(
        text: this.value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // à¦Ÿà§à¦²à¦Ÿà¦¿à¦ª à¦¬à¦•à§à¦¸à§‡à¦° à¦¸à¦¾à¦‡à¦œ
    double boxWidth = textPainter.width + 24;
    double boxHeight = textPainter.height + 12;

    // à¦¥à¦¾à¦®à§à¦¬à§‡à¦° à¦ à¦¿à¦• à¦‰à¦ªà¦°à§‡ à¦ªà¦œà¦¿à¦¶à¦¨ à¦¸à§‡à¦Ÿ à¦•à¦°à¦¾
    Offset boxCenter = Offset(center.dx, center.dy - 35);
    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: boxCenter, width: boxWidth, height: boxHeight),
      const Radius.circular(16),
    );

    // à¦Ÿà§à¦²à¦Ÿà¦¿à¦ªà§‡à¦° à¦¶à§à¦¯à¦¾à¦¡à§‹ à¦‡à¦«à§‡à¦•à§à¦Ÿ
    final Path shadowPath = Path()..addRRect(rRect);
    canvas.drawShadow(shadowPath, AppColors.black, 6.0, true);

    // à¦Ÿà§à¦²à¦Ÿà¦¿à¦ª à¦¬à¦•à§à¦¸ à¦¡à§à¦° à¦•à¦°à¦¾
    canvas.drawRRect(rRect, boxPaint);

    // à¦›à§‹à¦Ÿ à¦¨à¦¿à¦šà§‡à¦° à¦Ÿà§à¦°à¦¾à§Ÿà¦¾à¦™à§à¦—à§‡à¦²/à¦¤à§€à¦° à¦šà¦¿à¦¹à§à¦¨ à¦†à¦à¦•à¦¾
    final arrowPath = Path()
      ..moveTo(center.dx - 6, boxCenter.dy + (boxHeight / 2))
      ..lineTo(center.dx + 6, boxCenter.dy + (boxHeight / 2))
      ..lineTo(center.dx, center.dy - 12)
      ..close();
    canvas.drawPath(arrowPath, boxPaint);

    // à¦¬à¦•à§à¦¸à§‡à¦° à¦­à§‡à¦¤à¦°à§‡ à¦Ÿà§‡à¦•à§à¦¸à¦Ÿ à¦¡à§à¦° à¦•à¦°à¦¾
    Offset textOffset = Offset(
      boxCenter.dx - (textPainter.width / 2),
      boxCenter.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);
  }
}


