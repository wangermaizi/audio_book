import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';

class PlayerApi {
  PlayerApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final Random _random = Random.secure();

  static const String _baseUrl = SiteConfig.baseUrl;
  static const String _loginPath = '/user/public/login.html';

  Future<String> fetchPlayHtml(String featureKey) async {
    return _fetchPlayableHtml(featureKey);
  }

  Future<PlayerInfo> fetchPlayInfo(String featureKey) async {
    final html = await _fetchPlayableHtml(featureKey);
    final document = html_parser.parse(html);

    final title = _parseTitle(
      document.querySelector('h1')?.text.trim() ??
          _metaContent(document, 'og:title') ??
          '',
    );
    final novelId = _metaContent(document, '_b');
    final chapterId = _metaContent(document, '_p');
    final chapterSort = _metaContent(document, '_d') ?? 'read';
    final sign = _metaContent(document, '_c');
    final bookName = _metaContent(document, '_n') ?? '';
    final coverUrl =
        _metaContent(document, '_i') ??
        _metaContent(document, 'og:image') ??
        '';

    if (novelId == null || chapterId == null || sign == null) {
      throw StateError('播放页缺少音频接口参数');
    }

    final data = await _fetchPlayData(
      featureKey: featureKey,
      novelId: novelId,
      chapterId: chapterId,
      chapterSort: chapterSort,
      sign: sign,
    );

    final status = _readStatus(data['status']);
    if (status != 200) {
      final message = data['msg']?.toString() ?? '音频接口返回异常';
      if (status == 406 || data['loginurl'] != null) {
        throw LoginRequiredException(message);
      }
      throw StateError(message);
    }

    final audioUrl = (data['audioUrl'] ?? '').toString().trim();
    if (audioUrl.isEmpty) {
      throw StateError(data['msg']?.toString() ?? '没有获取到音频地址');
    }

    return PlayerInfo(
      featureKey: featureKey,
      title: title,
      bookName: bookName,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
      status: status.toString(),
      message: '',
      rawHtml: html,
    );
  }

  String _parseTitle(String value) {
    final title = value
        .replaceFirst(RegExp(r'在线收听$'), '')
        .replaceFirst(RegExp(r'有声小说$'), '')
        .trim();
    if (title.isEmpty) {
      return '';
    }
    if (RegExp(r'^-?\d+(?:[-_]\d+)*$').hasMatch(title)) {
      return '';
    }
    return title;
  }

  Future<String> _fetchPlayableHtml(String featureKey) async {
    final url = '$_baseUrl/play/$featureKey.html';

    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _client.dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {...SiteConfig.mobileHeaders, 'Referer': '$_baseUrl/'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final html = response.data ?? '';
      if (!_isChallengeHtml(html)) {
        return html;
      }

      if (!await _applyScriptCookies(html)) {
        return html;
      }
    }

    throw StateError('播放页安全校验失败，请重试');
  }

  Future<Map<String, dynamic>> _fetchPlayData({
    required String featureKey,
    required String novelId,
    required String chapterId,
    required String chapterSort,
    required String sign,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _postPlayData(
        featureKey: featureKey,
        novelId: novelId,
        chapterId: chapterId,
        chapterSort: chapterSort,
        sign: sign,
      );

      if (!_isChallengeHtml(response)) {
        return _asMap(response);
      }

      if (!await _applyScriptCookies(response)) {
        return _asMap(response);
      }
    }

    throw StateError('音频接口安全校验失败，请重试');
  }

  Future<String> _postPlayData({
    required String featureKey,
    required String novelId,
    required String chapterId,
    required String chapterSort,
    required String sign,
  }) async {
    final payload = {
      'novelid': novelId,
      'chapterid': chapterId,
      'type': chapterSort == 'read' ? 2 : 1,
      'salt': sign,
    };
    final encodedData = base64.encode(
      utf8.encode(Uri.encodeComponent(jsonEncode(payload))),
    );

    final response = await _client.dio.post<String>(
      '$_baseUrl/api/key/readplay',
      data: {'encodedData': encodedData},
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          ...SiteConfig.mobileHeaders,
          'Referer': '$_baseUrl/play/$featureKey.html',
          'Accept': 'application/json, text/plain, */*',
          'Content-Type': 'application/json',
          'sign': sign,
        },
      ),
    );
    return response.data ?? '';
  }

  bool _isChallengeHtml(String html) {
    return html.contains('<title>Loading...</title>') &&
        html.contains('var reversed =');
  }

  Future<bool> _applyScriptCookies(String html) async {
    final script = _decodeCookieScript(html) ?? html;
    var changed = false;

    final token = _readJsString(script, 'token');
    if (token != null) {
      await _client.upsertCookie('__51guid__', Uri.encodeComponent(token));
      changed = true;
    }

    final refreshToken = _readJsString(script, 'refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _client.upsertCookie('__51refresh__guid', refreshToken);
      changed = true;
    }

    final retry = RegExp(
      r'var\s+retry\s*=\s*(\d+)',
    ).firstMatch(script)?.group(1);
    if (retry != null) {
      await _client.upsertCookie('__51refresh__guid', retry);
      changed = true;
    }

    final directCookiePattern = RegExp(
      r"document\.cookie\s*=\s*'([^'=;]+)=([^';]*)",
    );
    for (final match in directCookiePattern.allMatches(script)) {
      final name = match.group(1) ?? '';
      final value = match.group(2) ?? '';
      if (name.isNotEmpty && value.isNotEmpty) {
        await _client.upsertCookie(name, value);
        changed = true;
      }
    }

    return changed;
  }

  String? _decodeCookieScript(String html) {
    final reversed = RegExp(
      r'var\s+reversed\s*=\s*"([^"]+)"',
    ).firstMatch(html)?.group(1);
    if (reversed == null) {
      return null;
    }

    try {
      return utf8.decode(base64.decode(reversed.split('').reversed.join()));
    } on FormatException {
      return null;
    }
  }

  String? _readJsString(String script, String name) {
    return RegExp(
      "var\\s+$name\\s*=\\s*'([^']*)'",
    ).firstMatch(script)?.group(1);
  }

  String? _metaContent(dynamic document, String name) {
    return document
            .querySelector('meta[name="$name"]')
            ?.attributes['content'] ??
        document.querySelector('meta[property="$name"]')?.attributes['content'];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return decoded.map((key, item) => MapEntry(key.toString(), item));
        }
      } on FormatException {
        throw StateError('音频接口返回无法解析');
      }
    }
    return <String, dynamic>{};
  }

  int _readStatus(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    return _loginWithSiteForm(username: username, password: password);
  }

  // ignore: unused_element
  Future<LoginResult> _legacyAjaxLogin({
    required String username,
    required String password,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _client.dio.get<String>(
        '$_baseUrl/user/public/ajaxlogin',
        queryParameters: {'username': username, 'password': password},
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            ...SiteConfig.mobileHeaders,
            'Referer': '$_baseUrl/user/public/login.html',
            'Accept': 'application/json, text/plain, */*',
          },
        ),
      );

      final text = response.data ?? '';
      if (_isChallengeHtml(text)) {
        if (await _applyScriptCookies(text)) {
          continue;
        }
      }

      final data = _asMap(text);
      final code = _readStatus(data['code']);
      return LoginResult(
        success: code == 200,
        message: data['msg']?.toString() ?? (code == 200 ? '登录成功' : '登录失败'),
      );
    }

    return const LoginResult(success: false, message: '登录安全校验失败，请重试');
  }

  Future<LoginResult> _loginWithSiteForm({
    required String username,
    required String password,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final loginPage = await _client.dio.get<String>(
        '$_baseUrl$_loginPath',
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          headers: {...SiteConfig.mobileHeaders, 'Referer': '$_baseUrl/'},
        ),
      );

      final pageText = loginPage.data ?? '';
      if (_isChallengeHtml(pageText)) {
        if (await _applyScriptCookies(pageText)) {
          continue;
        }
        return const LoginResult(success: false, message: '登录安全校验失败，请重试');
      }

      final verificationToken = _generateVerificationToken();
      await _client.dio.post<String>(
        '$_baseUrl/user/public/store_token.html',
        data: jsonEncode({'token': verificationToken}),
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            ...SiteConfig.mobileHeaders,
            'Referer': '$_baseUrl$_loginPath',
            'Accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await _client.dio.post<String>(
        '$_baseUrl$_loginPath',
        data: {
          'username': username,
          'password': password,
          'ptext': '',
          'verificationToken': verificationToken,
        },
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          followRedirects: true,
          headers: {
            ...SiteConfig.mobileHeaders,
            'Referer': '$_baseUrl$_loginPath',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final text = response.data ?? '';
      if (_isChallengeHtml(text)) {
        if (await _applyScriptCookies(text)) {
          continue;
        }
      }

      if (_isLoggedInHtml(text)) {
        return const LoginResult(success: true, message: '登录成功');
      }

      final data = _tryAsMap(text);
      if (data.isNotEmpty) {
        final code = _readStatus(data['code']);
        final status = _readStatus(data['status']);
        final success = code == 200 || status == 200;
        return LoginResult(
          success: success,
          message: data['msg']?.toString() ?? (success ? '登录成功' : '登录失败'),
        );
      }

      return LoginResult(
        success: false,
        message: _extractPageMessage(text) ?? '登录失败，请检查账号密码',
      );
    }

    return const LoginResult(success: false, message: '登录安全校验失败，请重试');
  }

  String _generateVerificationToken() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      16,
      (_) => characters[_random.nextInt(characters.length)],
    ).join();
  }

  Map<String, dynamic> _tryAsMap(String value) {
    try {
      return _asMap(value);
    } on StateError {
      return <String, dynamic>{};
    }
  }

  bool _isLoggedInHtml(String text) {
    final cookie = _client.cookie ?? '';
    return cookie.contains('PTCMS_userid=') ||
        cookie.contains('PTCMS_token=') ||
        text.contains('登录成功') ||
        text.toLowerCase().contains('success');
  }

  Future<LoginResult> sendRegisterCode({required String email}) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _client.dio.post<String>(
        '$_baseUrl/user/public/register_post',
        data: {'email': email},
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            ...SiteConfig.mobileHeaders,
            'Referer': '$_baseUrl/user/public/register.html',
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final text = response.data ?? '';
      if (_isChallengeHtml(text)) {
        if (await _applyScriptCookies(text)) {
          continue;
        }
      }

      final data = _asMap(text);
      final status = _readStatus(data['status']);
      return LoginResult(
        success: status == 200,
        message: data['msg']?.toString() ?? (status == 200 ? '验证码已发送' : '发送失败'),
      );
    }

    return const LoginResult(success: false, message: '发送验证码安全校验失败，请重试');
  }

  Future<LoginResult> registerByEmail({
    required String email,
    required String password,
    required String code,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _client.dio.post<String>(
        '$_baseUrl/user/public/register.html',
        data: {
          'email': email,
          'password': password,
          'password1': password,
          'ptext': '',
          'ptext_PwdTwo': '',
          'yanzhengma': code,
          'image': '7',
        },
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
          followRedirects: true,
          headers: {
            ...SiteConfig.mobileHeaders,
            'Referer': '$_baseUrl/user/public/register.html',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final text = response.data ?? '';
      if (_isChallengeHtml(text)) {
        if (await _applyScriptCookies(text)) {
          continue;
        }
      }

      final lower = text.toLowerCase();
      if (text.contains('注册成功') ||
          text.contains('登录成功') ||
          lower.contains('success')) {
        return const LoginResult(success: true, message: '注册成功');
      }

      final message = _extractPageMessage(text) ?? '注册失败，请检查邮箱验证码';
      return LoginResult(success: false, message: message);
    }

    return const LoginResult(success: false, message: '注册安全校验失败，请重试');
  }

  String? _extractPageMessage(String html) {
    final title = RegExp(
      r'<title>(.*?)</title>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html)?.group(1);
    if (title != null && title.trim().isNotEmpty) {
      return title.trim();
    }
    return null;
  }
}

class LoginRequiredException implements Exception {
  const LoginRequiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginResult {
  const LoginResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class PlayerInfo {
  const PlayerInfo({
    required this.featureKey,
    required this.title,
    required this.bookName,
    required this.coverUrl,
    required this.audioUrl,
    required this.status,
    required this.message,
    required this.rawHtml,
  });

  final String featureKey;
  final String title;
  final String bookName;
  final String coverUrl;
  final String audioUrl;
  final String status;
  final String message;
  final String rawHtml;
}
