import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/feature/map/presentation/widgets/parking_location_card.dart';
import 'package:platchatapp/feature/parking/presentation/widgets/save_parking_screen_shimmer.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class SaveParkingScreen extends StatefulWidget {
  const SaveParkingScreen({super.key});

  @override
  State<SaveParkingScreen> createState() => _SaveParkingScreenState();
}

class _SaveParkingScreenState extends State<SaveParkingScreen> {
  static const int _limit = 20;

  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _locations = [];

  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserPosition();
    _loadCachedThenRefresh();
  }

  /// Renders the last-seen list from local storage first, then refreshes from
  /// the API in the background.
  ///
  /// The shimmer only appears when there's genuinely nothing to show (first
  /// ever visit) — otherwise the user sees their list immediately and it
  /// quietly updates in place if anything new came back. Previously every
  /// single visit started from an empty list and a full-screen shimmer, even
  /// when the data hadn't changed at all.
  Future<void> _loadCachedThenRefresh() async {
    final cached = await _readCachedHistory();

    if (cached != null && cached.isNotEmpty && mounted) {
      setState(() {
        _locations
          ..clear()
          ..addAll(cached);
        _isLoading = false;
      });
    }

    await _fetchHistory(page: 1, silent: _locations.isNotEmpty);
  }

  Future<List<Map<String, dynamic>>?> _readCachedHistory() async {
    try {
      final raw = await SharePrefsHelper.getString(
        AppConst.savedParkingHistoryCache,
      );
      if (raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      // Corrupt/stale cache is not worth surfacing — just fetch fresh.
      return null;
    }
  }

  Future<void> _cacheHistory(List<Map<String, dynamic>> locations) async {
    try {
      await SharePrefsHelper.setString(
        AppConst.savedParkingHistoryCache,
        jsonEncode(locations),
      );
    } catch (_) {
      // Caching is a nicety; failing to write it must not break the screen.
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() => _userPosition = position);
    } catch (_) {
      // Distance just falls back to '--' if location can't be resolved.
    }
  }

  void _onScroll() {
    if (_isLoadingMore || _page >= _totalPages) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchHistory(page: _page + 1);
    }
  }

  /// [silent] refreshes in the background without flipping the screen back to
  /// the shimmer — used when cached rows are already on screen.
  Future<void> _fetchHistory({required int page, bool silent = false}) async {
    if (!silent) {
      setState(() {
        if (page == 1) {
          _isLoading = true;
        } else {
          _isLoadingMore = true;
        }
      });
    }

    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.getSavedParkingHistory(page: page, limit: _limit),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList =
            decoded is Map<String, dynamic> && decoded['locations'] is List
                ? decoded['locations'] as List<dynamic>
                : const [];

        setState(() {
          if (page == 1) _locations.clear();
          _locations.addAll(rawList.map((e) => Map<String, dynamic>.from(e)));
          _page = decoded is Map<String, dynamic> ? (decoded['page'] ?? page) : page;
          _totalPages =
              decoded is Map<String, dynamic> ? (decoded['totalPages'] ?? 1) : 1;
        });

        // Only page 1 is cached — that's what the next open renders first.
        if (page == 1) {
          unawaited(_cacheHistory(List<Map<String, dynamic>>.from(_locations)));
        }
      } else if (mounted) {
        CustomSnackbar.error(
          context: context,
          message: '${AppStrings.failedToLoadSavedParkings.tr} (${response.statusCode})',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.error(context: context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // -- Field mapping (real backend data, no design change) ------------------

  String _titleLabel(Map<String, dynamic> location, Map<String, dynamic>? area) {
    final String? savedName = location['name']?.toString().trim();
    if (savedName != null && savedName.isNotEmpty) return savedName;

    final String? areaName = area?['name']?.toString().trim();
    if (areaName != null && areaName.isNotEmpty) return areaName;

    return AppStrings.unknown.tr;
  }

  String _distanceLabel(Map<String, dynamic> location) {
    // Prefer the backend's own distanceMeters (server-computed against the
    // user's location at fetch time) — only fall back to a local
    // Geolocator calc when that field isn't present.
    final rawDistance = location['distanceMeters'];
    final double? backendMeters = rawDistance is num
        ? rawDistance.toDouble()
        : double.tryParse('$rawDistance');

    if (backendMeters != null) {
      return _formatMeters(backendMeters);
    }

    if (_userPosition == null) return '--';
    final area = location['parkingArea'] is Map
        ? Map<String, dynamic>.from(location['parkingArea'])
        : null;
    final lat = location['latitude'] ?? area?['latitude'];
    final lng = location['longitude'] ?? area?['longitude'];
    final double? destLat = lat is num ? lat.toDouble() : double.tryParse('$lat');
    final double? destLng = lng is num ? lng.toDouble() : double.tryParse('$lng');
    if (destLat == null || destLng == null) return '--';

    final meters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      destLat,
      destLng,
    );
    return _formatMeters(meters);
  }

  String _formatMeters(double meters) {
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  List<String> _areaTypes(Map<String, dynamic>? area) {
    final raw = area?['parkingAreaTypes'];
    if (raw is List) return raw.map((e) => e.toString().toUpperCase()).toList();
    return const [];
  }

  ({String label, IconData icon, Color color, String? asset}) _badge(
    Map<String, dynamic>? area,
  ) {
    final types = _areaTypes(area);
    if (types.isEmpty) {
      return (
        label: 'Standard',
        icon: Icons.local_parking_rounded,
        color: AppColors.paidBlue,
        asset: AssetsPath.standardIcon,
      );
    }
    if (types.contains('ELECTRIC_CHARGING')) {
      return (
        label: 'Electric',
        icon: Icons.electric_bolt_rounded,
        color: AppColors.chargingGreen,
        asset: AssetsPath.electricCharging,
      );
    }
    if (types.contains('DISABLED_FACILITY')) {
      return (
        label: 'Disable',
        icon: Icons.accessible_rounded,
        color: AppColors.grey,
        asset: AssetsPath.electricCharging,
      );
    }

    final rawType = types.first;
    final formattedLabel = rawType
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0]}${w.substring(1).toLowerCase()}' : '')
        .join(' ');

    return (
      label: formattedLabel,
      icon: Icons.local_parking_rounded,
      color: AppColors.paidBlue,
      asset: AssetsPath.standardIcon,
    );
  }

  String _ratingLabel(Map<String, dynamic>? area) {
    final rating = area?['rating'];
    if (rating == null) return '0.0';
    final numVal = rating is num ? rating : double.tryParse('$rating');
    if (numVal == null || numVal == 0) return '0.0';
    return numVal.toStringAsFixed(1);
  }

  String _spotsLabel(Map<String, dynamic>? area) {
    final totalSpots = area?['totalSpots'];
    final int spots = totalSpots is num
        ? totalSpots.toInt()
        : (int.tryParse('$totalSpots') ?? 0);
    return '$spots spots';
  }

  // Dollar SVG shown for both Free and Paid — same icon either way.
  ({String label, String asset}) _priceStat(Map<String, dynamic>? area) {
    final cost = area?['parkingCost']?.toString().toUpperCase();
    if (cost == null || cost.isEmpty || cost == 'FREE') {
      return (label: 'Free', asset: AssetsPath.dolar);
    }
    final fee = area?['parkingFee'];
    if (fee != null) {
      final feeNum = fee is num ? fee : num.tryParse('$fee');
      if (feeNum != null) {
        final feeText = feeNum % 1 == 0 ? feeNum.toInt().toString() : feeNum.toString();
        return (label: '\$$feeText', asset: AssetsPath.dolar);
      }
    }
    return (label: 'Paid', asset: AssetsPath.dolar);
  }

  ({String label, String sub})? _remainingTime(Map<String, dynamic> location) {
    final parkingType = location['parkingType']?.toString().toUpperCase();
    final expiresAtStr = location['paidExpiresAt']?.toString();
    if (parkingType != 'PAID' || expiresAtStr == null || expiresAtStr.isEmpty) {
      return null;
    }
    try {
      final expiresAt = DateTime.parse(expiresAtStr).toLocal();
      final remaining = expiresAt.difference(DateTime.now());
      if (remaining.isNegative) return null;
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final label = hours > 0
          ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hr'
          : '00:${minutes.toString().padLeft(2, '0')} min';
      return (label: label, sub: 'remaining');
    } catch (_) {
      return null;
    }
  }


  void _openNavigation(Map<String, dynamic> location) {
    final area = location['parkingArea'] is Map
        ? Map<String, dynamic>.from(location['parkingArea'])
        : null;

    final latRaw = location['latitude'] ?? area?['latitude'];
    final lngRaw = location['longitude'] ?? area?['longitude'];

    double? destLat = latRaw is num ? latRaw.toDouble() : double.tryParse('$latRaw');
    double? destLng = lngRaw is num ? lngRaw.toDouble() : double.tryParse('$lngRaw');

    if (destLat == null || destLng == null) {
      final link = location['googleMapsWalkingLink']?.toString();
      if (link != null && link.isNotEmpty) {
        final uri = Uri.tryParse(link);
        if (uri != null) {
          final destParam = uri.queryParameters['destination'];
          if (destParam != null) {
            final parts = destParam.split(',');
            if (parts.length == 2) {
              destLat = double.tryParse(parts[0].trim());
              destLng = double.tryParse(parts[1].trim());
            }
          }
        }
      }
    }

    if (destLat != null && destLng != null) {
      final label = area?['name']?.toString() ?? location['note']?.toString();
      final rawDistance = location['distanceMeters'];
      final double? knownDistanceMeters = rawDistance is num
          ? rawDistance.toDouble()
          : double.tryParse('$rawDistance');

      final parkingType = location['parkingType']?.toString().toUpperCase() ?? '';
      final parkingCost = (area?['parkingCost'] ?? area?['parking_cost'])?.toString().toUpperCase() ?? '';
      final isPaid = parkingType == 'PAID' || parkingCost == 'PAID';

      final rawTypes = area?['parkingAreaTypes'] ?? area?['types'] ?? location['parkingAreaTypes'];
      final List<String> types = rawTypes is List
          ? rawTypes.map((e) => e.toString().toUpperCase()).toList()
          : <String>[];

      if (isPaid) {
        if (!types.contains('PAID')) types.add('PAID');
      } else {
        if (!types.contains('FREE')) types.add('FREE');
      }

      final isHandoff = location['isHandoff'] == true ||
          location['type']?.toString().toUpperCase() == 'HANDOFF';

      context.pushNamed(
        RouteName.inAppNavigation,
        extra: {
          'destination': LatLng(destLat, destLng),
          'destinationLabel': label,
          if (knownDistanceMeters != null) 'knownDistanceMeters': knownDistanceMeters,
          'parkingAreaTypes': types,
          'isHandoff': isHandoff,
        },
      );
    } else {
      CustomSnackbar.error(
        context: context,
        message: AppStrings.navigationLocationNotAvailable.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveHelper.padding(20),
                  ResponsiveHelper.padding(12),
                  ResponsiveHelper.padding(20),
                  0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: ResponsiveHelper.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withOpacity(0.5),
                          border: Border.all(color: AppColors.white),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: ResponsiveHelper.iconSize(20),
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppStrings.saveParking.tr,
                          style: context.titleMedium.copyWith(color: AppColors.black,fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    // Balances the back button's width so the title stays centered.
                    SizedBox(width: ResponsiveHelper.width(40)),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(20)),
              Expanded(
                child: _isLoading
                    ? const SaveParkingScreenShimmer()
                    : ListView(
                  controller: _scrollController,
                  padding: ResponsiveHelper.symmetric(horizontal: 20),
                  children: [
                    if (_locations.isEmpty)
                      Padding(
                        padding: ResponsiveHelper.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                        AppStrings.noSavedParkingsYet.tr,

                            style: GoogleFonts.poppins(
                              color: AppColors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      )
                    else
                      for (final location in _locations) ...[
                        Builder(builder: (_) {
                          final area = location['parkingArea'] is Map
                              ? Map<String, dynamic>.from(location['parkingArea'])
                              : null;
                          final badge = _badge(area);
                          final priceStat = _priceStat(area);
                          final remaining = _remainingTime(location);

                          return ParkingLocationCard(
                            title: _titleLabel(location, area),
                            subtitle: area?['description']?.toString() ??
                                location['note']?.toString() ??
                                '',
                            badgeLabel: badge.label,
                            badgeIcon: badge.icon,
                            badgeIconAsset: badge.asset,
                            badgeColor: badge.color,
                            distanceLabel: _distanceLabel(location),
                            ratingLabel: _ratingLabel(area),
                            leftStatLabel: _spotsLabel(area),
                            rightStatLabel: priceStat.label,
                            rightStatIconAsset: priceStat.asset,
                            remainingTimeLabel: remaining?.label,
                            remainingTimeSubLabel: remaining?.sub,
                            // Navigate stays available even for paid spots
                            // showing a remaining-time countdown.
                            onNavigate: () => _openNavigation(location),
                            isActive: location['isActive'] == true,
                          );
                        }),
                        SizedBox(height: ResponsiveHelper.spacing(8)),
                      ],
                    if (_isLoadingMore)
                      Padding(
                        padding: ResponsiveHelper.symmetric(vertical: 16),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


