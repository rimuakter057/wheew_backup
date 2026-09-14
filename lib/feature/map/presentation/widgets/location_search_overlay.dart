import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// A result from location autocomplete / search.
class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });
}

/// Returned when the user picks a suggestion.
class PlaceResult {
  final double latitude;
  final double longitude;
  final String name;

  const PlaceResult({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

/// Full-screen location search overlay.
///
/// Push this as a route or show it via [showLocationSearch].
/// Returns a [PlaceResult] if the user picks a place, or null if cancelled.
class LocationSearchOverlay extends StatefulWidget {
  final String apiKey;
  final LatLng? userLocation;

  const LocationSearchOverlay({
    super.key,
    required this.apiKey,
    this.userLocation,
  });

  /// Convenience method — shows the overlay and returns the picked [PlaceResult].
  static Future<PlaceResult?> show(
    BuildContext context, {
    required String apiKey,
    LatLng? userLocation,
  }) {
    return Navigator.of(context).push<PlaceResult>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) =>
            LocationSearchOverlay(
          apiKey: apiKey,
          userLocation: userLocation,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  State<LocationSearchOverlay> createState() => _LocationSearchOverlayState();
}

class _LocationSearchOverlayState extends State<LocationSearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  List<PlaceSuggestion> _suggestions = [];
  bool _loading = false;
  Timer? _debounce;

  // Places API (New) endpoints. The legacy maps.googleapis.com/maps/api/place
  // endpoints are NOT used — Google refuses to activate them on projects
  // created after the legacy cutoff ("You're calling a legacy API, which is
  // not enabled for your project ... switch to the Places API (New)").
  static const String _googleAutocompleteUrl =
      'https://places.googleapis.com/v1/places:autocomplete';
  static const String _googlePlaceUrl = 'https://places.googleapis.com/v1/places';

  /// Groups the keystrokes of one search + the final Place Details lookup
  /// into a single billable Google session. Regenerated after each pick.
  String _sessionToken = _newSessionToken();

  static String _newSessionToken() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  double _calcDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(max(0.0, min(1.0, a)))); // 2 * R (6371 km)
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(value.trim());
    });
  }

  int _currentSearchId = 0;

  // Banglish → English phonetic mapping for common Bangladeshi places
  static const Map<String, String> _phoneticMap = {
    'bonsree': 'banasree', 'bonsri': 'banasree', 'bonasree': 'banasree',
    'bonosri': 'banasree', 'bonosree': 'banasree', 'bonoshree': 'banasree',
    'bonoshri': 'banasree', 'banoshree': 'banasree', 'banoshri': 'banasree',
    'bonani': 'banani', 'bananee': 'banani',
    'dhonmondi': 'dhanmondi', 'dhanmandi': 'dhanmondi',
    'mohammodpur': 'mohammadpur', 'mohammedpur': 'mohammadpur',
    'mughbazar': 'moghbazar', 'moghbajar': 'moghbazar',
    'kawranbazar': 'kawran bazar', 'karwanbazar': 'kawran bazar',
    'rampur': 'rampura',
    'bashundhora': 'bashundhara', 'basundhara': 'bashundhara',
    'boridhara': 'baridhara',
    'gulsahan': 'gulshan',
    'uttar': 'uttara', 'uttora': 'uttara',
    'mirpure': 'mirpur',
    'malibag': 'malibagh',
    'khilgoan': 'khilgaon',
    'hatirjhil': 'hatirjheel',
    'tejgoan': 'tejgaon',
    'baddha': 'badda',
    'khilket': 'khilkhet',
  };

  List<String> _resolveTerms(String input) {
    final lower = input.toLowerCase().trim();
    final terms = <String>{lower};
    if (_phoneticMap.containsKey(lower)) {
      terms.add(_phoneticMap[lower]!);
    } else if (lower.length >= 3) {
      for (final entry in _phoneticMap.entries) {
        if (entry.key.startsWith(lower)) {
          terms.add(entry.value);
          break;
        }
      }
    }
    return terms.toList();
  }

  /// Google Places Autocomplete — the same engine the Google Maps app itself
  /// uses, so partial input, typos and Banglish spellings ("bonsree",
  /// "dhonmondi", "mohammodpur") resolve to the right place without any
  /// hand-maintained spelling table.
  ///
  /// Returns `null` when Google couldn't be used at all (no key, network
  /// error, key restricted, Places API not enabled) so the caller knows to
  /// fall back. Returns an empty list when Google ran fine but genuinely has
  /// no match.
  Future<List<PlaceSuggestion>?> _fetchGoogleSuggestions(
    String input,
    double? uLat,
    double? uLng,
  ) async {
    if (widget.apiKey.trim().isEmpty) return null;

    final payload = <String, dynamic>{
      'input': input,
      'languageCode': 'en',
      'sessionToken': _sessionToken,
    };
    if (uLat != null && uLng != null) {
      // Bias (not restrict) toward the user: nearby places rank first, but
      // far-away matches still show up, exactly like Google Maps.
      payload['locationBias'] = {
        'circle': {
          'center': {'latitude': uLat, 'longitude': uLng},
          'radius': 50000.0,
        },
      };
      // Makes Google return distanceMeters on each prediction.
      payload['origin'] = {'latitude': uLat, 'longitude': uLng};
    }

    final res = await http
        .post(
          Uri.parse(_googleAutocompleteUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': widget.apiKey,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 8));

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (res.statusCode != 200 || body['error'] != null) {
      // Common causes, both fixed in Google Cloud Console:
      //  - PERMISSION_DENIED / "has not been used in project ... or it is
      //    disabled"  -> enable "Places API (New)" for the project.
      //  - API_KEY_SERVICE_BLOCKED -> the key's API restriction list doesn't
      //    include Places API (New); add it.
      final error = body['error'] as Map<String, dynamic>?;
      debugPrint(
        '[PlaceSearch] Places autocomplete HTTP ${res.statusCode} '
        'status=${error?['status']} message=${error?['message']}',
      );
      return null;
    }

    final suggestions = (body['suggestions'] as List?) ?? const [];
    final out = <PlaceSuggestion>[];
    for (final s in suggestions) {
      final prediction =
          (s as Map<String, dynamic>)['placePrediction'] as Map<String, dynamic>?;
      if (prediction == null) continue; // skip queryPrediction entries

      final placeId = prediction['placeId']?.toString() ?? '';
      if (placeId.isEmpty) continue;

      final structured =
          prediction['structuredFormat'] as Map<String, dynamic>?;
      final mainText =
          (structured?['mainText'] as Map<String, dynamic>?)?['text']
                  ?.toString() ??
              (prediction['text'] as Map<String, dynamic>?)?['text']
                  ?.toString() ??
              '';
      if (mainText.isEmpty) continue;

      final secondaryText =
          (structured?['secondaryText'] as Map<String, dynamic>?)?['text']
                  ?.toString() ??
              '';
      final distanceMeters = (prediction['distanceMeters'] as num?)?.toDouble();

      out.add(PlaceSuggestion(
        placeId: placeId,
        mainText: mainText,
        secondaryText: secondaryText,
        // Predictions carry no coordinates — _onTap resolves them through
        // Place Details using this placeId.
        distanceKm: distanceMeters == null ? null : distanceMeters / 1000,
      ));
    }
    return out;
  }

  Future<void> _fetchSuggestions(String input) async {
    if (!mounted) return;
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      setState(() { _suggestions = []; _loading = false; });
      return;
    }

    final int searchId = ++_currentSearchId;
    setState(() => _loading = true);

    final List<PlaceSuggestion> allResults = [];
    final Set<String> seenKeys = {};
    final double? uLat = widget.userLocation?.latitude;
    final double? uLng = widget.userLocation?.longitude;

    // ── Step 0: Google Places Autocomplete (primary) ────────────────────────
    List<PlaceSuggestion>? googleResults;
    try {
      googleResults = await _fetchGoogleSuggestions(cleanInput, uLat, uLng);
    } catch (e) {
      debugPrint('[PlaceSearch] Google autocomplete failed: $e');
      googleResults = null;
    }
    if (searchId != _currentSearchId || !mounted) return;

    if (googleResults != null && googleResults.isNotEmpty) {
      final resolved = googleResults;
      setState(() {
        _suggestions = resolved;
        _loading = false;
      });
      return;
    }

    // Steps 1-2 below are the OSM fallback, only reached when Google is
    // unavailable or returned nothing — so search keeps working instead of
    // showing an empty list.

    // ── Step 1: Photon (fast, prioritises user lat/lon) ─────────────────────
    try {
      final searchTerms = _resolveTerms(cleanInput);
      final photonFutures = searchTerms.map((term) async {
        try {
          final params = <String, String>{'q': term, 'limit': '15', 'lang': 'en'};
          if (uLat != null && uLng != null) {
            params['lat'] = uLat.toString();
            params['lon'] = uLng.toString();
          }
          final uri = Uri.parse('https://photon.komoot.io/api/').replace(queryParameters: params);
          final res = await http.get(uri, headers: {'Accept-Language': 'en'})
              .timeout(const Duration(seconds: 6));
          if (res.statusCode == 200) {
            final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
            return (body['features'] as List?) ?? <dynamic>[];
          }
        } catch (_) {}
        return <dynamic>[];
      });

      final photonResults = await Future.wait(photonFutures);
      if (searchId != _currentSearchId || !mounted) return;

      _parsePhotonResults(photonResults, allResults, seenKeys, uLat, uLng);
    } catch (_) {}

    // ── Step 2: Nominatim top-up when Photon found little or nothing ────────
    // Kept conditional rather than always-on: Nominatim's usage policy caps
    // callers at ~1 request/second, and this runs per (debounced) keystroke.
    if (allResults.length < 3) {
      try {
        final params = <String, String>{
          'q': cleanInput,
          'format': 'json',
          'addressdetails': '1',
          'limit': '15',
          'accept-language': 'en',
        };
        if (uLat != null && uLng != null) {
          // Wide viewbox so we catch nearby places even with partial queries
          params['viewbox'] = '${uLng - 3},${uLat + 3},${uLng + 3},${uLat - 3}';
          params['bounded'] = '0';
        }
        final uri = Uri.parse('https://nominatim.openstreetmap.org/search')
            .replace(queryParameters: params);
        final res = await http.get(uri, headers: {'User-Agent': 'PlatchatApp/1.0'})
            .timeout(const Duration(seconds: 8));

        if (searchId != _currentSearchId || !mounted) return;

        if (res.statusCode == 200) {
          final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
          for (final item in list) {
            final map = item as Map<String, dynamic>;
            final lat = double.tryParse(map['lat']?.toString() ?? '');
            final lon = double.tryParse(map['lon']?.toString() ?? '');
            if (lat == null || lon == null) continue;

            final displayName = map['display_name']?.toString() ?? '';
            String mainText = map['name']?.toString() ?? '';
            if (mainText.isEmpty) mainText = displayName.split(',').first.trim();
            if (mainText.isEmpty) continue;

            String secondary = '';
            if (displayName.length > mainText.length) {
              secondary = displayName.substring(mainText.length).replaceFirst(RegExp(r'^,\s*'), '');
            }

            double? dist;
            if (uLat != null && uLng != null) {
              dist = _calcDistanceKm(uLat, uLng, lat, lon);
              if (dist > 500) continue;
            }

            final key = '$mainText|${lat.toStringAsFixed(3)}|${lon.toStringAsFixed(3)}';
            if (seenKeys.add(key)) {
              allResults.add(PlaceSuggestion(
                placeId: map['place_id']?.toString() ?? key,
                mainText: mainText,
                secondaryText: secondary,
                latitude: lat,
                longitude: lon,
                distanceKm: dist,
              ));
            }
          }
        }
      } catch (_) {}
    }

    if (searchId != _currentSearchId || !mounted) return;

    // Sort nearest first
    if (uLat != null && uLng != null && allResults.isNotEmpty) {
      allResults.sort((a, b) =>
          (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
    }

    setState(() { _suggestions = allResults; _loading = false; });
  }

  void _parsePhotonResults(
    List<List<dynamic>> resultSets,
    List<PlaceSuggestion> out,
    Set<String> seen,
    double? uLat,
    double? uLng,
  ) {
    for (final features in resultSets) {
      for (final f in features) {
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final geom = f['geometry'] as Map<String, dynamic>? ?? {};
        final coords = geom['coordinates'] as List? ?? [];
        if (coords.length < 2) continue;

        final lon = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        final name = props['name']?.toString() ?? '';
        if (name.isEmpty) continue;

        final locality = props['locality']?.toString() ?? '';
        final street   = props['street']?.toString() ?? '';
        final district = props['district']?.toString() ?? '';
        final city     = props['city']?.toString() ?? props['state']?.toString() ?? '';
        final country  = props['country']?.toString() ?? '';

        final subParts = <String>[];
        if (locality.isNotEmpty && locality != name) {
          subParts.add(locality);
        } else if (street.isNotEmpty && street != name) {
          subParts.add(street);
        }
        if (district.isNotEmpty && district != name && district != locality) {
          subParts.add(district);
        }
        if (city.isNotEmpty && city != name) subParts.add(city);
        final secondary = subParts.isNotEmpty ? subParts.take(2).join(', ') : country;

        double? dist;
        if (uLat != null && uLng != null) {
          dist = _calcDistanceKm(uLat, uLng, lat, lon);
          if (dist > 500) continue; // Only skip truly remote results
        }

        final key = '$name|${lat.toStringAsFixed(3)}|${lon.toStringAsFixed(3)}';
        if (seen.add(key)) {
          out.add(PlaceSuggestion(
            placeId: props['osm_id']?.toString() ?? key,
            mainText: name,
            secondaryText: secondary,
            latitude: lat,
            longitude: lon,
            distanceKm: dist,
          ));
        }
      }
    }
  }

  Future<void> _onTap(PlaceSuggestion suggestion) async {
    // If coordinates are already known
    if (suggestion.latitude != null && suggestion.longitude != null) {
      Navigator.of(context).pop(PlaceResult(
        latitude: suggestion.latitude!,
        longitude: suggestion.longitude!,
        name: suggestion.mainText,
      ));
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('$_googlePlaceUrl/${suggestion.placeId}').replace(
        queryParameters: {
          'languageCode': 'en',
          'sessionToken': _sessionToken,
        },
      );
      final res = await http.get(
        uri,
        headers: {
          'X-Goog-Api-Key': widget.apiKey,
          'X-Goog-FieldMask': 'id,displayName,location,formattedAddress',
        },
      ).timeout(const Duration(seconds: 8));
      if (!mounted) return;

      // This lookup closes the autocomplete session — the next search starts
      // a new one.
      _sessionToken = _newSessionToken();

      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final location = body['location'] as Map<String, dynamic>?;

      if (location != null) {
        final lat = (location['latitude'] as num).toDouble();
        final lng = (location['longitude'] as num).toDouble();
        final name =
            (body['displayName'] as Map<String, dynamic>?)?['text']?.toString() ??
                suggestion.mainText;

        if (mounted) {
          Navigator.of(context).pop(PlaceResult(
            latitude: lat,
            longitude: lng,
            name: name,
          ));
        }
        return;
      }

      final error = body['error'] as Map<String, dynamic>?;
      debugPrint('[PlaceSearch] Place Details HTTP ${res.statusCode} '
          'status=${error?['status']} message=${error?['message']}');
      // Couldn't resolve coordinates — drop the spinner instead of leaving
      // it spinning forever on a dead tap.
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('[PlaceSearch] Place Details failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Google Maps Search Bar ────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: top + ResponsiveHelper.padding(8),
              left: ResponsiveHelper.padding(12),
              right: ResponsiveHelper.padding(12),
              bottom: ResponsiveHelper.padding(10),
            ),
            child: Container(
              height: ResponsiveHelper.padding(48),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(28),
                ),
              ),
              child: Row(
                children: [
                  // Back arrow
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF5F6368),
                      size: ResponsiveHelper.iconSize(22),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Search Input
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      onChanged: _onChanged,
                      style: GoogleFonts.roboto(
                        fontSize: ResponsiveHelper.fontSize(16),
                        color: const Color(0xFF202124),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle: GoogleFonts.roboto(
                          fontSize: ResponsiveHelper.fontSize(16),
                          color: const Color(0xFF5F6368),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // Clear button
                  if (_ctrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: const Color(0xFF5F6368),
                        size: ResponsiveHelper.iconSize(20),
                      ),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _suggestions = []);
                      },
                    ),
                ],
              ),
            ),
          ),

          // ── Thin loading bar ──────────────────────────────────────
          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Color(0xFF1A73E8),
              backgroundColor: Color(0xFFE8EAED),
            ),

          // ── Suggestions list (Google Maps Design) ──────────────────────────────────────
          // Expanded, so the results panel is its own full-height screen and
          // the list simply scrolls once the results fill it.
          Expanded(
            child: Container(
              color: Colors.white,
              child: _suggestions.isEmpty && !_loading && _ctrl.text.isNotEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: GoogleFonts.roboto(
                          fontSize: ResponsiveHelper.fontSize(14),
                          color: const Color(0xFF5F6368),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.6,
                        color: Color(0xFFE8EAED),
                        indent: 64,
                      ),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        final hasDist =
                            s.distanceKm != null && s.distanceKm! < 500;
                        final distText = hasDist
                            ? (s.distanceKm! < 1.0
                                ? '${(s.distanceKm! * 1000).toInt()} m'
                                : '${s.distanceKm!.toStringAsFixed(1)} km')
                            : '';

                        return InkWell(
                          onTap: () => _onTap(s),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.padding(16),
                              vertical: ResponsiveHelper.padding(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left: Pin icon in circle + distance below (Exact Google Maps design)
                                SizedBox(
                                  width: ResponsiveHelper.width(44),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: ResponsiveHelper.width(36),
                                        height: ResponsiveHelper.width(36),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F3F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          color: const Color(0xFF5F6368),
                                          size: ResponsiveHelper.iconSize(20),
                                        ),
                                      ),
                                      if (distText.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            distText,
                                            style: GoogleFonts.roboto(
                                              fontSize: ResponsiveHelper.fontSize(
                                                  10),
                                              color: const Color(0xFF70757A),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: ResponsiveHelper.spacing(12)),

                                // Center: Title + Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.mainText,
                                        style: GoogleFonts.roboto(
                                          fontSize: ResponsiveHelper.fontSize(
                                              15),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF202124),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (s.secondaryText.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            s.secondaryText,
                                            style: GoogleFonts.roboto(
                                              fontSize: ResponsiveHelper.fontSize(
                                                  13),
                                              color: const Color(0xFF5F6368),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Right: Google Maps Diagonal Arrow (tap to fill query)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _ctrl.text = s.mainText;
                                    _ctrl.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(offset: _ctrl.text.length),
                                    );
                                    _fetchSuggestions(s.mainText);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        ResponsiveHelper.padding(6)),
                                    child: Icon(
                                      Icons.north_west,
                                      color: const Color(0xFF70757A),
                                      size: ResponsiveHelper.iconSize(18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

