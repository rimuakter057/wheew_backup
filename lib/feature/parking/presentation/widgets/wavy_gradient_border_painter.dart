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

  static const _gradient = SweepGradient(
    colors: [
      Color(0xFF1E88E5), // blue
      AppColors.white,
      Color(0xFF1E88E5), // back to blue
      AppColors.white,
      Color(0xFF1E88E5), // back to blue
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  static const int _segments = 160;

  // ── Per-size caches ───────────────────────────────────────────────────────
  // paint() runs on every animation frame, but everything below depends only
  // on the canvas size — rebuilding it 60x/second was pure waste. The values
  // produced are identical to before; they're just computed once per size
  // instead of once per frame.
  static Size? _cachedSize;
  static late Shader _cachedShader;
  static late List<Path> _cachedSegmentPaths;
  static late List<double> _cachedWaveOffsets;

  static void _rebuildCache(Size size) {
    final rect = Offset.zero & size;
    _cachedShader = _gradient.createShader(rect);

    final metrics = (Path()..addRect(rect)).computeMetrics().first;
    final length = metrics.length;

    _cachedSegmentPaths = List<Path>.generate(
      _segments,
      (i) => metrics.extractPath(
        length * i / _segments,
        length * (i + 1) / _segments,
      ),
      growable: false,
    );

    // The sine's position term is fixed per segment; only wavePhase moves.
    const waveCount = 3; // how many "bulges" travel around the perimeter
    _cachedWaveOffsets = List<double>.generate(
      _segments,
      (i) => (i / _segments) * 2 * pi * waveCount,
      growable: false,
    );

    _cachedSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedSize != size) _rebuildCache(size);

    // Modulated by a traveling sine wave so it's thicker/thinner at
    // different points around the frame instead of uniform.
    final baseWidth = 14.0 + (t * 10.0);
    const waveAmplitude = 5.0;

    // Two reused Paints instead of 320 fresh allocations per frame.
    final haloPaint = Paint()
      ..shader = _cachedShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final corePaint = Paint()
      ..shader = _cachedShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < _segments; i++) {
      final segmentPath = _cachedSegmentPaths[i];

      final wave = sin(_cachedWaveOffsets[i] + wavePhase);
      final strokeWidth = (baseWidth + wave * waveAmplitude).clamp(6.0, 30.0);

      // Soft outer halo (blurred, wider) + a tighter, less-blurred core on
      // top — this combo is what actually reads as "glow" instead of a
      // crisp painted line, kept narrow so it hugs the edge.
      haloPaint
        ..strokeWidth = strokeWidth * 1.4
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5);
      canvas.drawPath(segmentPath, haloPaint);

      corePaint
        ..strokeWidth = strokeWidth * 0.6
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.15);
      canvas.drawPath(segmentPath, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WavyGradientBorderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.wavePhase != wavePhase;
}
