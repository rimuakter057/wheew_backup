import 'package:http/http.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class ChatRepository {
  Future<Response> getChatList() async {
    return await ApiClient.getData(uri: ApiUrl.chatList);
  }

  Future<Response> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    return await ApiClient.getData(
      uri: '${ApiUrl.searchUsers}?query=$query&page=$page&limit=$limit',
    );
  }
}




