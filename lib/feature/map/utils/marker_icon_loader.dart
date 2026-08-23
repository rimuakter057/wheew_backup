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
  static BitmapDescriptor? _electricChargingPin;
  static BitmapDescriptor? _disabledFacilityPin;
  static BitmapDescriptor? _disableAreaPin;
  static BitmapDescriptor? _electricAreaPin;
  static BitmapDescriptor? _paidAreaPin;
  static BitmapDescriptor? _freeAreaPin;

  static Future<BitmapDescriptor> _loadSvgPin(String assetPath, {double size = 76}) async {
    try {
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
      final image = await picture.toImage(size.round(), size.round());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (_) {
      // Fallback to standard parking pin if SVG fails to load
      return parkingPin(size: size);
    }
  }

  static Future<BitmapDescriptor> parkingPin({double size = 76}) async {
    final cached = _parkingPin;
    if (cached != null) return cached;

    final rawSvg = await rootBundle.loadString(AssetsPath.mapMarkerPin);
    final pictureInfo = await vg.vg.loadPicture(vg.SvgStringLoader(rawSvg), null);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final scaleX = size / pictureInfo.size.width;
    final scaleY = size / pictureInfo.size.height;
    canvas.scale(scaleX, scaleY);
    canvas.drawPicture(pictureInfo.picture);
    pictureInfo.picture.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.round(), size.round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final icon = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
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
