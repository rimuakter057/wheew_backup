// import 'package:flutter/material.dart';
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
//       backgroundColor: Colors.transparent,
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
//   late double _radius; // মিটারে, slider double লাগবে তাই double রাখা
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
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── drag handle ─────────────────────────────
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//
//             // ── title row ───────────────────────────────
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
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 20),
//
//             // ── radius value badge + manual input ──────
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
//             // ── slider ──────────────────────────────────
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
//                       style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                   Text('${(_maxRadius / 1000).toInt()} km',
//                       style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // ── apply button ────────────────────────────
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
//                   color: Colors.white,
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
//           color: selected ? const Color(0xFF185FA5) : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: selected ? Colors.white : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  late double _radius; // মিটারে

  // ── অব্যবহৃত লজিক (কমেন্ট করে রাখা হলো) ──────────────────
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

  // ভ্যালু ফরম্যাট করার জন্য হেল্পার ফাংশন (যেমন: 1000m -> 1 km)
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
          // ইমেজের মতো হালকা গ্রেডিয়েন্ট ব্যাকগ্রাউন্ড
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── drag handle ─────────────────────────────
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // ── title & subtitle ────────────────────────
             Text(
              'Search Parking Spot Within',
              style: context.bodyMedium.copyWith(color: AppColors.black)
            ),
            const SizedBox(height: 6),
            Text(
              'Choose the distance range around you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48), // স্লাইডার টুলটিপের জন্য একটু বেশি স্পেস রাখা হয়েছে

            // ── slider with custom thumb & tooltip ──────
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: const Color(0xFF0066C4),
                inactiveTrackColor: Colors.grey.shade200,
                // কাস্টম থাম্ব শেপ যা ইমেজের মতো ভ্যালু দেখাবে
                thumbShape: CustomSliderThumbShape(
                  value: _formatRadius(_radius),
                  thumbRadius: 10,
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

            // ── min & max labels ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('100 m', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  Text('20 km', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Select Section ────────────────────
            const Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // ইমেজের মতো ২ লাইনের গ্রিড লুক তৈরি করতে Wrap ব্যবহার করা হয়েছে
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickChip(100),
                _quickChip(250),
                _quickChip(500),
                _quickChip(1000),
                _quickChip(5000),
                _quickChip(10000),
              ],
            ),
            const SizedBox(height: 36),

            // ── apply button ────────────────────────────
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
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
                label: "Apply",
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

  // ── Quick Select Chips ──────────────────────────────
  Widget _quickChip(int meterValue) {
    final bool selected = _radius.round() == meterValue;
    final String label = _formatRadius(meterValue.toDouble());

    return GestureDetector(
      onTap: () => _updateRadius(meterValue.toDouble()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF005DB3) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
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
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ── Custom Slider Thumb Paint (ইমেজের মতো ব্ল্যাক বাবল ইফেক্ট) ──
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

    // ১. স্লাইডারের ভেতরের নীল রঙের থাম্ব/ডট আঁকা
    final fillPaint = Paint()
      ..color = const Color(0xFF0066C4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);

    // ২. উপরের ব্ল্যাক টুলটিপ/বাবল আঁকা
    final boxPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    // টুলটিপ টেক্সট কনফিগারেশন
    final textPainter = TextPainter(
      text: TextSpan(
        text: this.value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // টুলটিপ বক্সের সাইজ
    double boxWidth = textPainter.width + 24;
    double boxHeight = textPainter.height + 12;

    // থাম্বের ঠিক উপরে পজিশন সেট করা
    Offset boxCenter = Offset(center.dx, center.dy - 35);
    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: boxCenter, width: boxWidth, height: boxHeight),
      const Radius.circular(16),
    );

    // টুলটিপের শ্যাডো ইফেক্ট
    final Path shadowPath = Path()..addRRect(rRect);
    canvas.drawShadow(shadowPath, Colors.black, 6.0, true);

    // টুলটিপ বক্স ড্র করা
    canvas.drawRRect(rRect, boxPaint);

    // ছোট নিচের ট্রায়াঙ্গেল/তীর চিহ্ন আঁকা
    final arrowPath = Path()
      ..moveTo(center.dx - 6, boxCenter.dy + (boxHeight / 2))
      ..lineTo(center.dx + 6, boxCenter.dy + (boxHeight / 2))
      ..lineTo(center.dx, center.dy - 12)
      ..close();
    canvas.drawPath(arrowPath, boxPaint);

    // বক্সের ভেতরে টেক্সট ড্র করা
    Offset textOffset = Offset(
      boxCenter.dx - (textPainter.width / 2),
      boxCenter.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);
  }
}