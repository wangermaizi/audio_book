import 'package:dio/dio.dart';

import 'package:audio_book/core/network/api_client.dart';

class PlayerApi {
  PlayerApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = 'https://m.huanting.cc';

  Future<String> fetchPlayHtml(String featureKey) async {
    final response = await _client.dio.get<String>(
      '$_baseUrl/ting/$featureKey.html',
      options: Options(
        responseType: ResponseType.plain,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
        },
      ),
    );

    return response.data ?? '';
  }
}

