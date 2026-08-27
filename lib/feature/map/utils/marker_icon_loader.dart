import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as vg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

/// Shared "P" pin marker icon used for every parking-spot marker across the
/// app (Home map, Save-Parking map, Parking-Show map, and the destination
/// pin in turn-by-turn navigation) — rendered once per app run and cached.
class MapMarkerIcons {
  MapMarkerIcons._();

  /// On-screen size every pin is rendered at unless a caller overrides it.
  /// The rendered bitmap is then cropped to the pin's solid body, so the
  /// marker's tap area tracks this size instead of a fixed square canvas —
  /// lower this to make pins (and their hit areas) smaller everywhere.
  static const double defaultPinSize = 56;

  /// Cached rendered pins, keyed by asset + size.
  ///
  /// Keying on size matters: the previous one-field-per-pin cache ignored
  /// the `size` argument entirely, so whichever size was requested first won
  /// and every later call got that bitmap back regardless of what it asked
  /// for (e.g. parkingPin() at 76 poisoned the later size: 56 requests).
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> _cached(
    String assetPath,
    double size,
    Future<BitmapDescriptor> Function() build,
  ) async {
    final key = '$assetPath@${size.round()}';
    final hit = _cache[key];
    if (hit != null) return hit;
    final icon = await build();
    _cache[key] = icon;
    return icon;
  }

  /// Renders [assetPath] into a bitmap of the given [size], then crops it to
  /// the pin's solid body (see [_opaqueAlphaThreshold]).
  ///
  /// The crop matters for tap handling, not looks: Google Maps treats a
  /// marker's WHOLE bitmap rectangle as its hit area, transparent pixels
  /// included. These pin SVGs are drawn on a square canvas with a lot of
  /// empty space plus a full-canvas drop shadow around the teardrop
  /// (my_parked.svg's solid artwork only covers roughly x 13-55, y 14-64 of
  /// its 76x76 box), so an uncropped bitmap gave every pin an invisible tap
  /// zone far wider than the pin itself — taps "near" a pin opened its
  /// details sheet. Cropping keeps the drawn pin the same size on screen
  /// while shrinking the hit area down to just the visible pin.
  static Future<BitmapDescriptor> _renderSvgPin(
    String assetPath, {
    required double size,
  }) async {
    final rawSvg = await rootBundle.loadString(assetPath);
    final pictureInfo = await vg.vg.loadPicture(vg.SvgStringLoader(rawSvg), null);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final scaleX = size / pictureInfo.size.width;
    final scaleY = size / pictureInfo.size.height;
    canvas.scale(scaleX, scaleY);
    canvas.drawPicture(pictureInfo.picture);
    pictureInfo.picture.dispose();

    final picture = recorder.endRecording();
    final full = await picture.toImage(size.round(), size.round());
    picture.dispose();

    final trimmed = await _trimTransparentEdges(full);
    final byteData = await trimmed.toByteData(format: ui.ImageByteFormat.png);
    trimmed.dispose();

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Alpha a pixel must reach to count as "part of the pin" when cropping.
  ///
  /// Deliberately high, not a near-zero "is it transparent" test. Every pin
  /// SVG carries a full-canvas drop shadow (my_parked.svg: `<filter x="0"
  /// y="0" width="76" height="76">` with `feGaussianBlur stdDeviation="4"`),
  /// and that blur leaves faint non-zero alpha across almost the entire box.
  /// A low threshold therefore trimmed practically nothing and the oversized
  /// tap area survived. Cutting at ~25% alpha crops to the solid pin body,
  /// discarding only the soft shadow halo.
  static const int _opaqueAlphaThreshold = 64;

  /// Crops [src] to the bounding box of its meaningfully-opaque pixels.
  /// Returns [src] unchanged if nothing clears the threshold or it's already
  /// tight.
  static Future<ui.Image> _trimTransparentEdges(ui.Image src) async {
    final raw = await src.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (raw == null) return src;

    final bytes = raw.buffer.asUint8List();
    final width = src.width;
    final height = src.height;

    int minX = width, minY = height, maxX = -1, maxY = -1;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (bytes[(y * width + x) * 4 + 3] > _opaqueAlphaThreshold) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < minX || maxY < minY) return src;

    final cropWidth = maxX - minX + 1;
    final cropHeight = maxY - minY + 1;
    if (cropWidth == width && cropHeight == height) return src;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      src,
      ui.Rect.fromLTWH(
        minX.toDouble(),
        minY.toDouble(),
        cropWidth.toDouble(),
        cropHeight.toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
      ui.Paint(),
    );

    final picture = recorder.endRecording();
    final out = await picture.toImage(cropWidth, cropHeight);
    picture.dispose();
    src.dispose();
    return out;
  }

  static Future<BitmapDescriptor> _loadSvgPin(String assetPath, {double size = defaultPinSize}) async {
    try {
      return await _renderSvgPin(assetPath, size: size);
    } catch (_) {
      // Fallback to standard parking pin if SVG fails to load
      return parkingPin(size: size);
    }
  }

  static Future<BitmapDescriptor> parkingPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.mapMarkerPin, size,
          () => _renderSvgPin(AssetsPath.mapMarkerPin, size: size));

  /// Pin for the user's own active parked spot (from /saved-parking/me).
  static Future<BitmapDescriptor> myParkedPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.myParked, size,
          () => _loadSvgPin(AssetsPath.myParked, size: size));

  /// Red pin used for AVAILABLE handoffs — blinked on/off via Marker.alpha
  /// by ParkingShowController, not by swapping bitmaps.
  static Future<BitmapDescriptor> blinkingPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.blinkingPin, size,
          () => _loadSvgPin(AssetsPath.blinkingPin, size: size));

  static Future<BitmapDescriptor> electricChargingPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.electricCarjingMarker, size,
          () => _loadSvgPin(AssetsPath.electricCarjingMarker, size: size));

  static Future<BitmapDescriptor> disabledFacilityPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.disable, size,
          () => _loadSvgPin(AssetsPath.disable, size: size));

  static Future<BitmapDescriptor> iconForData(Map<String, dynamic>? data, {double size = defaultPinSize}) async {
    if (data == null) return parkingPin(size: size);

    final types = data['parkingAreaTypes'] ?? data['types'];
    final disabledLoc = data['disabledFacilityLocation'];
    final parkingType = data['parkingType']?.toString().toUpperCase();

    bool hasElectric = false;
    bool hasDisabled = false;

    if (types is List) {
      for (final t in types) {
        final str = t.toString().toUpperCase();
        if (str.contains('ELECTRIC')) hasElectric = true;
        if (str.contains('DISABLE')) hasDisabled = true;
      }
    }
    if (parkingType != null && parkingType.contains('ELECTRIC')) {
      hasElectric = true;
    }
    if (disabledLoc != null && disabledLoc.toString().isNotEmpty) {
      hasDisabled = true;
    }

    if (hasElectric) {
      return electricChargingPin(size: size);
    } else if (hasDisabled) {
      return disabledFacilityPin(size: size);
    }
    return parkingPin(size: size);
  }

  // ── Parking-area pins (parking_show_screen's area markers) ──────────────
  // Separate asset set from the handoff pins above — these are the
  // disable/electric/paid/free pins used for the area-center marker.

  static Future<BitmapDescriptor> disableAreaPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.disablePin, size,
          () => _loadSvgPin(AssetsPath.disablePin, size: size));

  static Future<BitmapDescriptor> electricAreaPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.electricPin, size,
          () => _loadSvgPin(AssetsPath.electricPin, size: size));

  static Future<BitmapDescriptor> paidAreaPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.paidPin, size,
          () => _loadSvgPin(AssetsPath.paidPin, size: size));

  static Future<BitmapDescriptor> freeAreaPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.freePin, size,
          () => _loadSvgPin(AssetsPath.freePin, size: size));

  static Future<BitmapDescriptor> greyPin({double size = defaultPinSize}) =>
      _cached(AssetsPath.greyPin, size,
          () => _loadSvgPin(AssetsPath.greyPin, size: size));

  /// Parking-area pin, chosen by priority Disabled > Electric > Paid > Free.
  /// parkingAreaTypes decides it when non-empty; parkingCost is only
  /// consulted as the Paid/Free fallback when parkingAreaTypes has neither
  /// DISABLED_FACILITY nor ELECTRIC_CHARGING (including when it's empty).
  static Future<BitmapDescriptor> areaPinForData(
    Map<String, dynamic>? area, {
    double size = defaultPinSize,
  }) async {
    if (area == null) return freeAreaPin(size: size);

    final rawTypes = area['parkingAreaTypes'];
    final types = rawTypes is List
        ? rawTypes.map((e) => e.toString().toUpperCase()).toList()
        : const <String>[];

    if (types.contains('DISABLED_FACILITY')) {
      return disableAreaPin(size: size);
    }
    if (types.contains('ELECTRIC_CHARGING')) {
      return electricAreaPin(size: size);
    }

    final parkingCost = area['parkingCost']?.toString().toUpperCase() ?? '';
    if (parkingCost == 'PAID') {
      return paidAreaPin(size: size);
    }
    return freeAreaPin(size: size);
  }
}
