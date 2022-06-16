import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komikku/core/utils/toast.dart';
import 'package:komikku/data/hive.dart';
import 'package:komikku/dex/apis/auth_api.dart';
import 'package:komikku/dex/apis/user_api.dart';
import 'package:komikku/dex/models.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? emailOrUsername;
  String? password;

  /// 用户名
  var username = '';

  /// 登录状态
  final _loginState = false.obs;

  get loginState => _loginState.value;

  /// [LoginController] 单列
  static LoginController get to => Get.find();

  @override
  void onInit() {
    _loginState.value = HiveDatabase.userLoginState;
    super.onInit();
  }

  /// 登录
  Future<void> login() async {
    formKey.currentState?.save();
    if (!_validate()) return;

    var login = emailOrUsername!.contains('@')
        ? Login(email: emailOrUsername, password: password!)
        : Login(username: emailOrUsername, password: password!);

    final loginResponse = await AuthApi.loginAsync(login);
    HiveDatabase.sessionToken = loginResponse.token.session;
    HiveDatabase.refreshToken = loginResponse.token.refresh;

    final userResponse = await UserApi.getUserDetailsAsync();
    username = userResponse.data.attributes.username;
    _loginState.value = true;
  }

  /// 登出
  Future<void> logout() async {
    HiveDatabase.removeSessionToken();
    HiveDatabase.removeRefreshToken();
    await AuthApi.logoutAsync();

    username = '';
    _loginState.value = false;
  }

  /// 跳转浏览器
  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  /// 验证
  bool _validate() {
    if (emailOrUsername?.isEmpty ?? true) {
      showText(text: '账号不能为空');
      return false;
    }
    if (password?.isEmpty ?? true) {
      showText(text: '密码不能为空');
      return false;
    }
    if (password!.length < 8) {
      showText(text: '密码不能小于8位');
      return false;
    }
    if (password!.length > 1024) {
      showText(text: '密码不能大于1024位');
      return false;
    }

    return true;
  }
}
