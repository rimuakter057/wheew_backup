import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:platchatapp/core/config/app_config.dart';

class NavigationStep {
  final String instruction;
  final String? maneuver;
  final String distanceText;
  final String durationText;
  final int distanceMeters;
  final LatLng endLocation;

  const NavigationStep({
    required this.instruction,
    required this.maneuver,
    required this.distanceText,
    required this.durationText,
    required this.distanceMeters,
    required this.endLocation,
  });
}

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final String durationText;
  final int? durationSeconds;
  final List<NavigationStep> steps;

  const DirectionsResult({
    required this.polylinePoints,
    required this.distanceText,
    required this.durationText,
    required this.durationSeconds,
    required this.steps,
  });
}

class DirectionsRepository {
  // Injected at build time via --dart-define-from-file=dart_define.json (see
  // AppConfig) — never hardcoded here. The Directions API must be enabled
  // (and billing active) for this key in Google Cloud Console to work.
  static const String _googleMapsApiKey = AppConfig.mapsApiKey;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 3, lineLength: 100),
  );

  /// Returns every route Google offers for this origin/destination — index
  /// 0 is Google's recommended route, any remaining entries are alternates
  /// (only present when Google actually has a meaningfully different way).
  static Future<List<DirectionsResult>?> getRoutes({
    required LatLng origin,
    required LatLng destination,
    required String travelMode,
  }) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': travelMode,
      'alternatives': 'true',
      'key': _googleMapsApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        _logger.w('Directions API HTTP ${response.statusCode}: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status']?.toString();
      if (status != 'OK') {
        _logger.w('Directions API status=$status: ${body['error_message']}');
        return null;
      }

      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final results = <DirectionsResult>[];
      for (final r in routes) {
        final route = r as Map<String, dynamic>;
        final legs = route['legs'] as List?;
        if (legs == null || legs.isEmpty) continue;
        final leg = legs.first as Map<String, dynamic>;

        final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>?;
        final encodedPoints = overviewPolyline?['points']?.toString();
        if (encodedPoints == null || encodedPoints.isEmpty) continue;

        final distanceMap = leg['distance'] as Map<String, dynamic>?;
        final durationMap = leg['duration'] as Map<String, dynamic>?;

        final distanceMeters = (distanceMap?['value'] as num?)?.toInt();
        final durationSeconds = (durationMap?['value'] as num?)?.toInt();

        final stepsRaw = leg['steps'] as List? ?? [];
        final steps = stepsRaw.map((s) {
          final step = s as Map<String, dynamic>;
          final stepDistance = step['distance'] as Map<String, dynamic>?;
          final stepDuration = step['duration'] as Map<String, dynamic>?;
          final endLoc = step['end_location'] as Map<String, dynamic>?;
          return NavigationStep(
            instruction: _stripHtml(step['html_instructions']?.toString() ?? ''),
            maneuver: step['maneuver']?.toString(),
            distanceText: stepDistance?['text']?.toString().trim() ?? '',
            durationText: stepDuration?['text']?.toString().trim() ?? '',
            distanceMeters: (stepDistance?['value'] as num?)?.toInt() ?? 0,
            endLocation: LatLng(
              (endLoc?['lat'] as num?)?.toDouble() ?? destination.latitude,
              (endLoc?['lng'] as num?)?.toDouble() ?? destination.longitude,
            ),
          );
        }).toList();

        results.add(DirectionsResult(
          polylinePoints: _decodePolyline(encodedPoints),
          distanceText: distanceMap?['text']?.toString().trim().isNotEmpty == true
              ? distanceMap!['text'].toString().trim()
              : _formatDistance(distanceMeters),
          durationText: durationMap?['text']?.toString().trim().isNotEmpty == true
              ? durationMap!['text'].toString().trim()
              : _formatDuration(durationSeconds),
          durationSeconds: durationSeconds,
          steps: steps,
        ));
      }

      _logger.i('Directions: fetched ${results.length} route(s)');
      return results.isEmpty ? null : results;
    } catch (e, st) {
      _logger.e('DirectionsRepository.getRoutes error', error: e, stackTrace: st);
      return null;
    }
  }

  /// Google's `html_instructions` embed formatting tags (e.g. `<b>Square
  /// Rd</b>`) — strip them down to plain text for display.
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Fallback when Google's own `duration.text` is missing — derived from
  /// the numeric `duration.value` (seconds), which is always present
  /// alongside a successful (status "OK") response.
  static String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0 ? '$hours hr' : '$hours hr $remainingMinutes min';
  }

  /// Fallback when Google's own `distance.text` is missing — derived from
  /// the numeric `distance.value` (meters).
  static String _formatDistance(int? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Standard Google encoded-polyline algorithm decoder.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
