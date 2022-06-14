import 'package:komikku/core/utils/http.dart';

class PingApi {
  /// Ping
  static Future<String> pingAsync() async {
    final response = await HttpUtil().get('/ping');
    return response;
  }
}
