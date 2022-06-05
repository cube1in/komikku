import 'dart:convert';

import 'package:flutter/material.dart';

/// 对象拓展
extension ObjectExtensions<T> on T {
  dynamic get deepClone => jsonDecode(jsonEncode(this));
}

/// 滚动控制器拓展
extension ScrollControllerExtensions on ScrollController {
  /// 在底部
  bool get onBottom {
    return position.atEdge && position.pixels != 0;
  }

  /// 在顶部
  bool get onTop {
    return position.atEdge && position.pixels == 0;
  }
}
