import 'dart:math';

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// SEARCHING-mode glow frame: gradient-colored (blue -> white -> purple),
/// stroke width waves irregularly around the perimeter and the wave travels
/// over time — same base pulsing width/timing as the old solid Border.all()
/// version, just not a uniform line anymore.
class WavyGradientBorderPainter extends CustomPainter {
  final double t; // 0..1 "breathing" phase — same as the old glowWidth calc
  final double wavePhase; // rotates the wave around the perimeter over time

  const WavyGradientBorderPainter({
    required this.t,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metrics = (Path()..addRect(rect)).computeMetrics().first;
    final length = metrics.length;

    final gradient = const SweepGradient(
      colors: [
        Color(0xFF1E88E5), // blue
        AppColors.white,
        Color(0xFF1E88E5), // back to blue
        AppColors.white,
        Color(0xFF1E88E5), // back to blue
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    final shader = gradient.createShader(rect);

    // Modulated by a traveling sine wave so it's thicker/thinner at
    // different points around the frame instead of uniform.
    final baseWidth = 14.0 + (t * 10.0);
    const waveAmplitude = 5.0;
    const waveCount = 3; // how many "bulges" travel around the perimeter

    const segments = 160;
    for (int i = 0; i < segments; i++) {
      final d0 = length * i / segments;
      final d1 = length * (i + 1) / segments;
      final segmentPath = metrics.extractPath(d0, d1);

      final wave = sin((d0 / length) * 2 * pi * waveCount + wavePhase);
      final strokeWidth = (baseWidth + wave * waveAmplitude).clamp(6.0, 30.0);

      // Soft outer halo (blurred, wider) + a tighter, less-blurred core on
      // top — this combo is what actually reads as "glow" instead of a
      // crisp painted line, kept narrow so it hugs the edge.
      final haloPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.4
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5);
      canvas.drawPath(segmentPath, haloPaint);

      final corePaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.15);
      canvas.drawPath(segmentPath, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WavyGradientBorderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.wavePhase != wavePhase;
}
