import 'package:http/http.dart' as http;
import 'package:platchatapp/core/service/api_client.dart';

class ParkingRepository {
  Future<http.Response> getParkingModeMe() async {
    return await ApiClient.getData(uri: '/park-relay/parking-mode/me');
  }

  Future<http.Response> getNearbyHandoffs({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    return await ApiClient.getData(
      uri: '/park-relay/handoffs/nearby',

      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radiusMeters': radiusMeters.toString(),
      },
    );
  }

  Future<http.Response> getNearbyParkingAreas({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    // Old endpoint — kept for reference, replaced below to match the same
    // /search endpoint the map (home tab) uses.
    // return await ApiClient.getData(
    //   uri: '/park-relay/parking-areas/nearby',
    //   queryParams: {
    //     'latitude': latitude.toString(),
    //     'longitude': longitude.toString(),
    //     'radiusMeters': radiusMeters.toString(),
    //   },
    // );
    return await ApiClient.getData(
      uri: '/park-relay/parking-areas/search',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radiusMeters': radiusMeters.toString(),
      },
    );
  }

  Future<http.Response> createHandoff({
    required double latitude,
    required double longitude,
    String? spotId,
  }) async {
    return await ApiClient.postData(
      uri: '/park-relay/handoffs',
      body: {
        'latitude': latitude,
        'longitude': longitude,
        if (spotId != null) 'spotId': spotId,
      },
    );
  }

  Future<http.Response> submitParkingAreaRating({
    required String parkingAreaId,
    required int rating,
    required String review,
  }) async {
    return await ApiClient.postData(
      uri: '/park-relay/parking-areas/$parkingAreaId/ratings',
      body: {
        'rating': rating,
        'review': review,
      },
    );
  }

  Future<http.Response> getHandoffById({required String handoffId}) async {
    return await ApiClient.getData(uri: '/park-relay/handoffs/$handoffId');
  }

  Future<http.Response> acceptAndParkHandoff({required String handoffId}) async {
    return await ApiClient.postData(
      uri: '/park-relay/handoffs/$handoffId/accept-and-park',
      body: const {},
    );
  }
  Future<http.Response> setParkingModeSearching({
    required double latitude,
    required double longitude,
  }) async {
    return await ApiClient.postData(
      uri: '/park-relay/parking-mode/searching',
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<http.Response> setParkingModeIdle({
    required double latitude,
    required double longitude,
  }) async {
    return await ApiClient.postData(
      uri: '/park-relay/parking-mode/idle',
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}
