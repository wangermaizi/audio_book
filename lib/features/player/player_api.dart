import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';

class PlayerApi {
  PlayerApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = SiteConfig.baseUrl;

  Future<String> fetchPlayHtml(String featureKey) async {
    return _fetchPlayableHtml(featureKey);
  }

  Future<PlayerInfo> fetchPlayInfo(String featureKey) async {
    final html = await _fetchPlayableHtml(featureKey);
    final document = html_parser.parse(html);

    final title =
        document.querySelector('h1')?.text.trim() ??
        _metaContent(document, 'og:title') ??
        '';
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
      throw StateError(data['msg']?.toString() ?? '音频接口返回异常');
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
      message: data['msg']?.toString() ?? '',
      rawHtml: html,
    );
  }

  Future<String> _fetchPlayableHtml(String featureKey) async {
    final url = '$_baseUrl/play/$featureKey.html';
    final response = await _client.dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: {...SiteConfig.mobileHeaders, 'Referer': _baseUrl},
      ),
    );

    final html = response.data ?? '';
    if (!_isChallengeHtml(html)) {
      return html;
    }

    final challenge = _parseChallenge(html);
    if (challenge == null) {
      return html;
    }

    await _client.upsertCookie('__51guid__', Uri.encodeComponent(challenge));
    await _client.upsertCookie('__51refresh__guid', '1');

    final retry = await _client.dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: {...SiteConfig.mobileHeaders, 'Referer': _baseUrl},
      ),
    );
    return retry.data ?? '';
  }

  Future<Map<String, dynamic>> _fetchPlayData({
    required String featureKey,
    required String novelId,
    required String chapterId,
    required String chapterSort,
    required String sign,
  }) async {
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

    final challenge = _parseChallenge(response);
    if (challenge == null) {
      return _asMap(response);
    }

    await _client.upsertCookie('__51guid__', Uri.encodeComponent(challenge));
    await _client.upsertCookie('__51refresh__guid', '1');

    final retry = await _postPlayData(
      featureKey: featureKey,
      novelId: novelId,
      chapterId: chapterId,
      chapterSort: chapterSort,
      sign: sign,
    );
    return _asMap(retry);
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

  String? _parseChallenge(String html) {
    final reversed = RegExp(r'var reversed = "([^"]+)"').firstMatch(html);
    final encoded = reversed?.group(1);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    final js = utf8.decode(base64.decode(encoded.split('').reversed.join()));
    return RegExp(r"var token = '([^']+)'").firstMatch(js)?.group(1);
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
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return decoded.map((key, item) => MapEntry(key.toString(), item));
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
