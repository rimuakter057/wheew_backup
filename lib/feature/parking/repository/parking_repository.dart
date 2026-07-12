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
    return await ApiClient.getData(
      uri: '/park-relay/parking-areas/nearby',
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
  }) async {
    return await ApiClient.postData(
      uri: '/park-relay/handoffs',
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}
