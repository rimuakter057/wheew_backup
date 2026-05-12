import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/profile/repository/useful_number_model.dart';

// ─── Debug Helper ─────────────────────────────────────────────────────────────
void _log(String emoji, String section, String msg) {
  debugPrint('$emoji [UsefulNumber][$section] $msg');
}

void _divider() {
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// ─── Controller ───────────────────────────────────────────────────────────────

class UsefulNumberController extends GetxController {
  // ─── Observable State ─────────────────────────────────────
  final RxList<UsefulNumber> numbers = <UsefulNumber>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString error = RxnString();

  // ─── Pagination ───────────────────────────────────────────
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasNextPage = false;

  bool get hasNextPage => _hasNextPage;

  // ─── Location ─────────────────────────────────────────────
  double? _latitude;
  double? _longitude;

  // ─── onClose ──────────────────────────────────────────────
  @override
  void onClose() {
    _log('🔴', 'onClose', 'Controller disposed');
    super.onClose();
  }

  // ─── Init (screen এর initState থেকে call হবে) ────────────
  Future<void> init() async {
    _divider();
    _log('🚀', 'init', 'CALLED from initState');
    _log('🚀', 'init', 'isLoading = true');
    _divider();

    isLoading.value = true;
    error.value = null;

    try {
      await _fetchLocation();
      await _fetchNumbers(page: 1, isRefresh: true);
    } catch (e, stack) {
      _divider();
      _log('💥', 'init', 'UNCAUGHT ERROR: $e');
      _log('💥', 'init', 'StackTrace:\n$stack');
      _divider();
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      _log('🏁', 'init', 'END — isLoading = false');
      _divider();
    }
  }

  // ─── Pull-to-refresh ──────────────────────────────────────
  Future<void> refresh() async {
    _divider();
    _log('🔄', 'refresh', 'Pull-to-refresh — resetting to page 1');
    _divider();
    _currentPage = 1;
    error.value = null;
    await _fetchLocation();
    await _fetchNumbers(page: 1, isRefresh: true);
  }

  // ─── Load More ────────────────────────────────────────────
  Future<void> loadMore() async {
    if (isLoadingMore.value) {
      _log('⏭️', 'loadMore', 'Skipped — already loading more');
      return;
    }
    if (!_hasNextPage) {
      _log('🛑', 'loadMore', 'Skipped — no next page');
      return;
    }

    _divider();
    _log('📄', 'loadMore', 'Loading page ${_currentPage + 1}');
    _divider();

    isLoadingMore.value = true;
    await _fetchNumbers(page: _currentPage + 1);
    isLoadingMore.value = false;

    _log('✅', 'loadMore', 'Done — isLoadingMore = false');
  }

  // ─── Location Fetch ───────────────────────────────────────
  Future<void> _fetchLocation() async {
    _log('📍', 'location', 'Checking location service...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _log('📍', 'location', 'Service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      _log('❌', 'location', 'FAILED — Location service is OFF');
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    _log('📍', 'location', 'Current permission: $permission');

    if (permission == LocationPermission.denied) {
      _log('📍', 'location', 'Requesting permission...');
      permission = await Geolocator.requestPermission();
      _log('📍', 'location', 'Permission after request: $permission');

      if (permission == LocationPermission.denied) {
        _log('❌', 'location', 'FAILED — Permission denied by user');
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log('❌', 'location', 'FAILED — Permission permanently denied');
      throw Exception('Location permission permanently denied.');
    }

    _log('📍', 'location', 'Getting current position...');
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _latitude = position.latitude;
    _longitude = position.longitude;

    _divider();
    _log('✅', 'location', 'SUCCESS');
    _log('📍', 'location', 'Latitude  : $_latitude');
    _log('📍', 'location', 'Longitude : $_longitude');
    _log('📍', 'location', 'Accuracy  : ${position.accuracy}m');
    _divider();
  }

  // ─── API Call ─────────────────────────────────────────────
  Future<void> _fetchNumbers({
    required int page,
    bool isRefresh = false,
  }) async {
    if (_latitude == null || _longitude == null) {
      _log('⚠️', 'fetchNumbers', 'SKIPPED — lat/lng is null');
      return;
    }

    final uri = ApiUrl.usefulNumber(
      latitude: _latitude!,
      longitude: _longitude!,
      page: page,
      limit: _limit,
    );

    _divider();
    _log('🌐', 'fetchNumbers', 'REQUEST');
    _log('🌐', 'fetchNumbers', 'URL      : $uri');
    _log('🌐', 'fetchNumbers', 'Page     : $page | Limit: $_limit | isRefresh: $isRefresh');
    _divider();

    try {
      final response = await ApiClient.getData(uri: uri);

      _divider();
      _log('📥', 'fetchNumbers', 'RESPONSE');
      _log('📥', 'fetchNumbers', 'Status   : ${response.statusCode}');
      _log('📥', 'fetchNumbers', 'Body     : ${response.body}');
      _divider();

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        if (body['success'] == true) {
          final List<dynamic> raw = body['numbers'] ?? [];
          final fetched = raw.map((e) => UsefulNumber.fromJson(e)).toList();

          final pagination = body['pagination'] ?? {};
          _hasNextPage = pagination['hasNextPage'] ?? false;
          _currentPage = page;

          _log('✅', 'fetchNumbers', 'Fetched     : ${fetched.length} items');
          _log('✅', 'fetchNumbers', 'hasNextPage : $_hasNextPage');
          _log('✅', 'fetchNumbers', 'currentPage : $_currentPage');
          _log('✅', 'fetchNumbers', 'totalInList : ${numbers.length + fetched.length}');

          if (isRefresh) {
            numbers.assignAll(fetched);
            _log('🔁', 'fetchNumbers', 'List replaced (refresh)');
          } else {
            numbers.addAll(fetched);
            _log('➕', 'fetchNumbers', 'Items appended — total: ${numbers.length}');
          }
        } else {
          _log('❌', 'fetchNumbers', 'success=false in body');
          _log('❌', 'fetchNumbers', 'Full body: ${response.body}');
          error.value = 'Server returned unsuccessful response.';
        }
      } else {
        _log('❌', 'fetchNumbers', 'HTTP Error  : ${response.statusCode}');
        _log('❌', 'fetchNumbers', 'Reason      : ${response.reasonPhrase}');
        _log('❌', 'fetchNumbers', 'Body        : ${response.body}');
        error.value = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e, stack) {
      _divider();
      _log('💥', 'fetchNumbers', 'EXCEPTION: $e');
      _log('💥', 'fetchNumbers', 'StackTrace:\n$stack');
      _divider();
      error.value = e.toString();
    }
  }
}