import '../models/account.dart';
import '../models/user.dart';
import '../../core/utils/http.dart';

class AccountApi {
  /// Create account.
  @Deprecated('官方不允许App进行注册，注册需要移步官网')
  static Future<UserResponse> createAccountAsync(AccountCreate create) async {
    final res =
        await HttpUtil().post('/account/create', data: create.toJson());
    return UserResponse.fromJson(res);
  }

  /// Activate account.
  @Deprecated('官方不允许App进行注册，注册需要移步官网')
  static Future<AccountActivateResponse> activateAccountAsync(
      String code) async {
    final res = await HttpUtil().post('/account/activate/$code');
    return AccountActivateResponse.fromJson(res);
  }

  /// Resent the activate code.
  @Deprecated('官方不允许App进行注册，注册需要移步官网')
  static Future<AccountActivateResponse> resendActivationCodeAsync(
      SendAccountActivationCode resend) async {
    final res = await HttpUtil()
        .post('/account/activate/resend', data: resend.toJson());
    return AccountActivateResponse.fromJson(res);
  }

  /// Recover account (change password).
  @Deprecated('官方不允许App进行注册，注册需要移步官网')
  static Future<AccountActivateResponse> recoverAccountAsync(
      SendAccountActivationCode resend) async {
    final res = await HttpUtil().post('/account/recover');
    return AccountActivateResponse.fromJson(res);
  }

  /// Complete recover (change password).
  @Deprecated('官方不允许App进行注册，注册需要移步官网')
  static Future<AccountActivateResponse> completeAccountRecoverAsync(
      String code, RecoverComplete complete) async {
    final res = await HttpUtil()
        .post('/account/recover/$code', data: complete.toJson());
    return AccountActivateResponse.fromJson(res);
  }
}
