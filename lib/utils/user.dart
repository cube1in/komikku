import 'dart:convert';
import 'dart:io';

import 'package:komikku/models/refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 刷新令牌过期时间
const _refreshExpire = Duration(days: 29);

/// 会话令牌过期时间
const _sessionExpire = Duration(minutes: 14);

/// 用户状态
Future<bool> userLoginState() async {
  return await getSession() != null || await getRefresh() != null;
}

/// 获取会话令牌
Future<String?> getSession() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('session');
  if (list == null) return null;

  if (DateTime.now().isAfter(DateTime.parse(list[0]))) {
    await prefs.remove('session');
    return null;
  }

  return list[1];
}

/// 获取刷新令牌
Future<String?> getRefresh() async {
  var file = await _localFile;
  // 不存在时返回 null
  if (!await file.exists()) return null;

  var jsonString = await file.readAsString();
  if (jsonString.isEmpty) return null;

  var refreshMap = jsonDecode(jsonString);
  // 过期返回null
  if (DateTime.now().isAfter(DateTime.parse(refreshMap['expire']))) {
    return null;
  }

  return refreshMap['token'];
}

/// 设置会话令牌
Future<bool> setSession(String token) async {
  final prefs = await SharedPreferences.getInstance();
  var result = await prefs.setStringList('session', [
    DateTime.now().add(_sessionExpire).toIso8601String(),
    token,
  ]);

  return result;
}

/// 设置刷新令牌
Future<void> setRefresh(String token) async {
  var file = await _localFile;
  var jsonString = jsonEncode(Refresh(
    token: token,
    expire: DateTime.now().add(_refreshExpire),
  ));

  file.writeAsString(jsonString);
}

/// 移除会话令牌
Future<void> removeSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('session');
}

/// 移除会话令牌
Future<void> removeRefresh() async {
  var file = await _localFile;
  if (await file.exists()) file.delete();
}

/// 本地文件
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/refresh_token');
}

/// 应用目录
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
