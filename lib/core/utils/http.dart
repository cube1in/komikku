import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import '../../data/services/store.dart';
import '../../dex/apis/auth_api.dart';
import '../../dex/models/refresh_token.dart';

class HttpUtil {
  /// MangaDex Server url.
  static const serverUrl = 'https://api.mangadex.org';

  /// The singleton of [HttpUtil].
  static final HttpUtil _instance = HttpUtil._internal();

  /// The singleton factory constructor.
  factory HttpUtil() => _instance;

  Dio? dio;
  CancelToken? cancelToken = CancelToken();

  HttpUtil._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      headers: {},
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    dio?.interceptors.addAll([
      RetryInterceptor(
        dio: dio!,
        // Specify log function (optional)
        logPrint: print,
        // Retry count (optional)
        retries: 3,
        retryDelays: const [
          // Set delays between retries (optional)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
      InterceptorsWrapper(onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); //continue
        // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onError: (DioError e, handler) async {
        // Do something with response error
        return handler.next(e); //continue
        // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
      }),
    ]);
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel('cancelled');
  }

  /// Load local options.
  Future<Options> getLocalOptions() async {
    Options options = Options();

    if (StoreService().loginStatus) {
      if (StoreService().sessionToken == null) {
        final res = await AuthApi.refreshAsync(
            RefreshToken(token: StoreService().refreshToken!));
        StoreService().sessionToken = res.token.session;
      }

      options = Options(headers: {
        'Authorization': 'Bearer ${StoreService().sessionToken}',
      });
    }
    return options;
  }

  /// Restful get.
  Future<T> get<T>(
    String path, {
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.get(
        path,
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful post.
  Future<T> post<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.post(
        path,
        data: data,
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful put.
  Future<T> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.put(
        path,
        data: data,
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful patch.
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.patch(
        path,
        data: data,
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful delete.
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.delete(
        path,
        data: data,
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful post form.
  Future<T> postForm<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.post(
        path,
        data: FormData.fromMap(data),
        options: internalOptions,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onSendProgress: onReceiveProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return res?.data;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Restful download.
  Future<Response> download(
    String path, {
    dynamic data,
    Options? options,
    String? savePath,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    String Function(Headers)? savePathCallback,
  }) async {
    assert(
      savePath != null || savePathCallback != null,
      'One of the two must not be empty.',
    );

    try {
      final internalOptions = options ?? await getLocalOptions();
      final res = await dio?.download(
        path,
        savePath ?? savePathCallback!,
        data: data,
        options: internalOptions.copyWith(receiveTimeout: 60000),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return res!;
    } on DioError catch (e) {
      throw createException(e);
    }
  }

  /// Handle exception.
  HttpException createException(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        {
          return HttpException(code: -1, message: '请求取消');
        }
      case DioErrorType.connectTimeout:
        {
          return HttpException(code: -1, message: '连接超时');
        }

      case DioErrorType.sendTimeout:
        {
          return HttpException(code: -1, message: '请求超时');
        }

      case DioErrorType.receiveTimeout:
        {
          return HttpException(code: -1, message: '响应超时');
        }

      case DioErrorType.response:
        {
          try {
            int? errCode = error.response?.statusCode ?? 000;
            switch (errCode) {
              case 400:
                {
                  return HttpException(code: errCode, message: '请求语法错误');
                }
              case 401:
                {
                  return HttpException(code: errCode, message: '没有权限');
                }
              case 403:
                {
                  return HttpException(code: errCode, message: '服务器拒绝执行');
                }
              case 404:
                {
                  return HttpException(code: errCode, message: '无法找到数据');
                }
              case 405:
                {
                  return HttpException(code: errCode, message: '请求方法被禁止');
                }
              case 409:
                {
                  return HttpException(code: errCode, message: '请求次数过多');
                }
              case 412:
                {
                  return HttpException(code: errCode, message: '需要验证码');
                }
              case 500:
                {
                  return HttpException(code: errCode, message: '服务器内部错误');
                }
              case 502:
                {
                  return HttpException(code: errCode, message: '无效的请求');
                }
              case 503:
                {
                  return HttpException(code: errCode, message: '服务器挂了');
                }
              case 505:
                {
                  return HttpException(code: errCode, message: '不支持HTTP协议请求');
                }
              default:
                {
                  return HttpException(
                      code: errCode,
                      message: error.response?.statusMessage ?? '网络错误');
                }
            }
          } on Exception catch (_) {
            return HttpException(code: -1, message: '未知错误');
          }
        }
      default:
        {
          return HttpException(code: -1, message: error.message);
        }
    }
  }
}

/// Http exception.
class HttpException implements Exception {
  int code;
  String message;

  HttpException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'Exception: code $code, $message';
}
