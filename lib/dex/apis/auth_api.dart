import 'package:dio/dio.dart';
import 'package:komikku/dex/models/login.dart';
import 'package:komikku/dex/models/logout.dart';
import 'package:komikku/dex/models/refresh_token.dart';
import 'package:komikku/utils/http.dart';

class AuthApi {
  /// 登录
  static Future<LoginResponse> loginAsync(Login login) async {
    final response = await HttpUtil().post('/auth/login', params: login.toJson());
    return LoginResponse.fromJson(response);
  }

  /// 刷新令牌
  static Future<RefreshResponse> refreshAsync(RefreshToken refresh) async {
    final response = await HttpUtil().post(
      '/auth/refresh',
      params: refresh.toJson(),
      // 新建 Options 防止循环调用
      options: Options(),
    );
    return RefreshResponse.fromJson(response);
  }

  /// 刷新令牌
  static Future<LogoutResponse> logoutAsync() async {
    final response = await HttpUtil().post('/auth/logout');
    return LogoutResponse.fromJson(response);
  }
}
