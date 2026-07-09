import 'dart:io';

import 'package:dio/dio.dart';

import 'package:audio_book/core/storage/local_library.dart';

class ApiClient {
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 12),
      ),
    );
    _loadCookieFuture = _loadCookie();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _loadCookieFuture;
          final cookie = _cookieHeader;
          if (cookie.isNotEmpty) {
            options.headers['Cookie'] = cookie;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          await _storeResponseCookies(response.headers);
          handler.next(response);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio dio;
  late final Future<void> _loadCookieFuture;
  final LocalLibrary _library = LocalLibrary();

  final Map<String, String> _cookies = <String, String>{};

  String? get cookie {
    final header = _cookieHeader;
    return header.isEmpty ? null : header;
  }

  Future<void> setCookie(String value) async {
    // 去掉首尾空格以及换行，避免 HTTP 头格式错误
    var v = value.trim();
    v = v.replaceAll('\r', '').replaceAll('\n', '');
    _cookies
      ..clear()
      ..addAll(_parseCookieHeader(v));
    await _saveCookie();
  }

  Future<void> upsertCookie(String name, String value) async {
    await _loadCookieFuture;
    final cleanName = name.trim();
    final cleanValue = value.trim().replaceAll('\r', '').replaceAll('\n', '');
    if (cleanName.isEmpty) {
      return;
    }
    _cookies[cleanName] = cleanValue;
    await _saveCookie();
  }

  String get _cookieHeader {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  Future<void> _loadCookie() async {
    final savedCookies = await _library.cookies();
    _cookies
      ..clear()
      ..addAll(savedCookies);
  }

  Future<void> _saveCookie() async {
    await _library.replaceCookies(_cookies);
  }

  Future<void> _storeResponseCookies(Headers headers) async {
    final setCookieHeaders = _readSetCookieHeaders(headers);
    if (setCookieHeaders.isEmpty) {
      return;
    }

    var changed = false;
    for (final header in _splitSetCookieHeaders(setCookieHeaders)) {
      final cookie = _parseSetCookie(header);
      if (cookie == null) {
        continue;
      }

      final name = cookie.name;
      if (cookie.isExpired) {
        changed = _cookies.remove(name) != null || changed;
        continue;
      }

      if (_cookies[name] != cookie.value) {
        _cookies[name] = cookie.value;
        changed = true;
      }
    }

    if (changed) {
      await _saveCookie();
    }
  }

  List<String> _readSetCookieHeaders(Headers headers) {
    for (final entry in headers.map.entries) {
      if (entry.key.toLowerCase() == 'set-cookie') {
        return entry.value;
      }
    }
    return const <String>[];
  }

  List<String> _splitSetCookieHeaders(List<String> headers) {
    final result = <String>[];
    final cookieStart = RegExp(r'(?:(?<=^)|(?<=,\s))[^=;,\s]+=');

    for (final header in headers) {
      final matches = cookieStart.allMatches(header).toList();
      if (matches.isEmpty) {
        continue;
      }

      for (var i = 0; i < matches.length; i++) {
        final start = matches[i].start;
        final end = i + 1 < matches.length
            ? matches[i + 1].start
            : header.length;
        result.add(
          header.substring(start, end).trim().replaceFirst(RegExp(r',$'), ''),
        );
      }
    }

    return result;
  }

  Map<String, String> _parseCookieHeader(String header) {
    final cookies = <String, String>{};
    for (final part in header.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final index = trimmed.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = trimmed.substring(0, index).trim();
      final value = trimmed.substring(index + 1).trim();
      if (name.isNotEmpty) {
        cookies[name] = value;
      }
    }
    return cookies;
  }

  _ResponseCookie? _parseSetCookie(String header) {
    final parts = header.split(';');
    if (parts.isEmpty) {
      return null;
    }

    final pair = parts.first.trim();
    final index = pair.indexOf('=');
    if (index <= 0) {
      return null;
    }

    final name = pair.substring(0, index).trim();
    final value = pair.substring(index + 1).trim();
    if (name.isEmpty) {
      return null;
    }

    var isExpired = false;
    for (final attribute in parts.skip(1)) {
      final trimmed = attribute.trim();
      final lower = trimmed.toLowerCase();
      if (lower == 'max-age=0' || lower.startsWith('max-age=-')) {
        isExpired = true;
        break;
      }
      if (lower.startsWith('expires=')) {
        final rawDate = trimmed.substring('expires='.length).trim();
        DateTime? expires;
        try {
          expires = HttpDate.parse(rawDate);
        } on Exception {
          expires = null;
        }
        if (expires != null && expires.isBefore(DateTime.now().toUtc())) {
          isExpired = true;
          break;
        }
      }
    }

    return _ResponseCookie(name: name, value: value, isExpired: isExpired);
  }
}

class _ResponseCookie {
  const _ResponseCookie({
    required this.name,
    required this.value,
    required this.isExpired,
  });

  final String name;
  final String value;
  final bool isExpired;
}
