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

  static BitmapDescriptor? _parkingPin;
  static BitmapDescriptor? _myParkedPin;
  static BitmapDescriptor? _blinkingPin;
  static BitmapDescriptor? _electricChargingPin;
  static BitmapDescriptor? _disabledFacilityPin;
  static BitmapDescriptor? _disableAreaPin;
  static BitmapDescriptor? _electricAreaPin;
  static BitmapDescriptor? _paidAreaPin;
  static BitmapDescriptor? _freeAreaPin;
  static BitmapDescriptor? _greyPin;

  /// Renders [assetPath] into a bitmap of the given [size], then trims the
  /// fully-transparent margin off the result.
  ///
  /// The trim matters for tap handling, not looks: Google Maps treats a
  /// marker's WHOLE bitmap rectangle as its hit area, transparent pixels
  /// included. These pin SVGs are drawn on a square canvas with a lot of
  /// empty space around the teardrop (my_parked.svg's artwork only covers
  /// roughly x 13-55, y 14-64 of its 76x76 box), so an untrimmed bitmap gave
  /// every pin an invisible tap zone far wider than the pin itself — taps
  /// "near" a pin opened its details sheet. Cropping to the artwork's real
  /// bounds keeps the drawn pin pixel-for-pixel the same size on screen
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

  /// Crops [src] to the bounding box of its non-transparent pixels.
  /// Returns [src] unchanged if it's fully transparent or already tight.
  static Future<ui.Image> _trimTransparentEdges(ui.Image src) async {
    final raw = await src.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (raw == null) return src;

    final bytes = raw.buffer.asUint8List();
    final width = src.width;
    final height = src.height;

    int minX = width, minY = height, maxX = -1, maxY = -1;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Ignore near-invisible antialiasing fringe so the crop stays tight.
        if (bytes[(y * width + x) * 4 + 3] > 8) {
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

  static Future<BitmapDescriptor> _loadSvgPin(String assetPath, {double size = 76}) async {
    try {
      return await _renderSvgPin(assetPath, size: size);
    } catch (_) {
      // Fallback to standard parking pin if SVG fails to load
      return parkingPin(size: size);
    }
  }

  static Future<BitmapDescriptor> parkingPin({double size = 76}) async {
    final cached = _parkingPin;
    if (cached != null) return cached;

    final icon = await _renderSvgPin(AssetsPath.mapMarkerPin, size: size);
    _parkingPin = icon;
    return icon;
  }

  /// Pin for the user's own active parked spot (from /saved-parking/me).
  static Future<BitmapDescriptor> myParkedPin({double size = 76}) async {
    final cached = _myParkedPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.myParked, size: size);
    _myParkedPin = icon;
    return icon;
  }

  /// Red pin used for AVAILABLE handoffs — blinked on/off via Marker.alpha
  /// by ParkingShowController, not by swapping bitmaps.
  static Future<BitmapDescriptor> blinkingPin({double size = 76}) async {
    final cached = _blinkingPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.blinkingPin, size: size);
    _blinkingPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> electricChargingPin({double size = 76}) async {
    final cached = _electricChargingPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.electricCarjingMarker, size: size);
    _electricChargingPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> disabledFacilityPin({double size = 76}) async {
    final cached = _disabledFacilityPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.disable, size: size);
    _disabledFacilityPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> iconForData(Map<String, dynamic>? data, {double size = 76}) async {
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

  static Future<BitmapDescriptor> disableAreaPin({double size = 76}) async {
    final cached = _disableAreaPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.disablePin, size: size);
    _disableAreaPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> electricAreaPin({double size = 76}) async {
    final cached = _electricAreaPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.electricPin, size: size);
    _electricAreaPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> paidAreaPin({double size = 76}) async {
    final cached = _paidAreaPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.paidPin, size: size);
    _paidAreaPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> freeAreaPin({double size = 76}) async {
    final cached = _freeAreaPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.freePin, size: size);
    _freeAreaPin = icon;
    return icon;
  }

  static Future<BitmapDescriptor> greyPin({double size = 76}) async {
    final cached = _greyPin;
    if (cached != null) return cached;
    final icon = await _loadSvgPin(AssetsPath.greyPin, size: size);
    _greyPin = icon;
    return icon;
  }

  /// Parking-area pin, chosen by priority Disabled > Electric > Paid > Free.
  /// parkingAreaTypes decides it when non-empty; parkingCost is only
  /// consulted as the Paid/Free fallback when parkingAreaTypes has neither
  /// DISABLED_FACILITY nor ELECTRIC_CHARGING (including when it's empty).
  static Future<BitmapDescriptor> areaPinForData(
    Map<String, dynamic>? area, {
    double size = 76,
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
