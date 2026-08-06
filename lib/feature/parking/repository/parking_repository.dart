import 'package:http/http.dart' as http;
import 'package:platchatapp/core/service/api_client.dart';

class ParkingRepository {
  Future<http.Response> getParkingModeMe() async {
    return await ApiClient.getData(uri: '/park-relay/parking-mode/me');
  }

  Future<http.Response> getSavedParkingMe() async {
    return await ApiClient.getData(uri: '/park-relay/saved-parking/me');
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
    final uri = '/park-relay/handoffs/$handoffId';
    print("GET_HANDOFF_BY_ID_URL: $uri (handoffId=$handoffId)");
    return await ApiClient.getData(uri: uri);
  }

  // Same endpoint the home tab's "Save My Parking" flow uses — reused here
  // so the parking-area details sheet's Save Park button (IDLE) has a
  // working save action too, same as the handoff's accept-and-park does
  // for SEARCHING.
  Future<http.Response> saveMyParking({
    required double latitude,
    required double longitude,
    required String parkingType,
    String? spotId,
    int? durationMin,
  }) async {
    final uri = '/park-relay/saved-parking';
    print("SAVE_MY_PARKING_URL: $uri (lat=$latitude, lng=$longitude, parkingType=$parkingType, spotId=$spotId, durationMin=$durationMin)");
    return await ApiClient.postData(
      uri: uri,
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': 10,
        'confidence': 0.91,
        'source': 'AUTO',
        if (spotId != null) 'spotId': spotId,
        'parkingType': parkingType,
        if (parkingType == 'PAID' && durationMin != null) 'durationMin': durationMin,
      },
    );
  }

  Future<http.Response> acceptAndParkHandoff({required String handoffId}) async {
    final uri = '/park-relay/handoffs/$handoffId/accept-and-park';
    print("ACCEPT_AND_PARK_URL: $uri (handoffId=$handoffId)");
    return await ApiClient.postData(
      uri: uri,
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
