import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._internal() {
    dio = Dio();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final cookie = _cookie;
          if (cookie != null && cookie.isNotEmpty) {
            options.headers['Cookie'] = cookie;
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio dio;

  String? _cookie;

  String? get cookie => _cookie;

  void setCookie(String value) {
    // 去掉首尾空格以及换行，避免 HTTP 头格式错误
    var v = value.trim();
    v = v.replaceAll('\r', '').replaceAll('\n', '');
    _cookie = v;
  }
}

