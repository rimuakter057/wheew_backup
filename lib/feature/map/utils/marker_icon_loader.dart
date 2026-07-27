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
}
