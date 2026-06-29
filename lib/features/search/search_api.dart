import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';
import 'package:audio_book/features/search/search_models.dart';

class SearchApi {
  SearchApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = SiteConfig.baseUrl;

  Future<List<SearchResultItem>> search(String query) async {
    final apiResults = await _tryApiSearch(query);
    if (apiResults.isNotEmpty) {
      return apiResults;
    }

    final response = await _client.dio.post<String>(
      '$_baseUrl/novelsearch/search/result.html',
      data: {'searchword': query},
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.formUrlEncodedContentType,
        headers: {...SiteConfig.mobileHeaders, 'Referer': _baseUrl},
      ),
    );

    return _parseHtmlResults(html_parser.parse(response.data ?? ''));
  }

  Future<List<SearchResultItem>> _tryApiSearch(String query) async {
    try {
      final response = await _client.dio.get<Object?>(
        '$_baseUrl/api/ajax/solist',
        queryParameters: {'word': query, 'type': 'name', 'page': 1, 'order': 1},
        options: Options(
          responseType: ResponseType.json,
          headers: SiteConfig.mobileHeaders,
        ),
      );

      final data = response.data;
      if (data is Map) {
        return _parseApiResults(Map<String, dynamic>.from(data));
      }
    } on DioException {
      return const <SearchResultItem>[];
    }

    return const <SearchResultItem>[];
  }

  List<SearchResultItem> _parseApiResults(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! List) {
      return const <SearchResultItem>[];
    }

    return data
        .whereType<Map>()
        .map((item) {
          final novel = item['novel'];
          final boyin = item['boyin'];
          final novelMap = novel is Map ? novel : const <String, dynamic>{};
          final boyinMap = boyin is Map ? boyin : const <String, dynamic>{};
          final title = (novelMap['name'] ?? '').toString();
          final href = (novelMap['url'] ?? '').toString();

          return SearchResultItem(
            title: title,
            coverUrl: (novelMap['cover'] ?? '').toString(),
            link: _absoluteUrl(href),
            announcer: (boyinMap['name'] ?? '').toString(),
            category: '',
            summary: (novelMap['intro'] ?? '').toString(),
          );
        })
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  List<SearchResultItem> _parseHtmlResults(dom.Document document) {
    final results = <SearchResultItem>[];
    final seen = <String>{};

    for (final card in document.querySelectorAll(
      '.book-ol .book-li, .list-li, .pic_list, section.page-content .card',
    )) {
      final item = _parseHtmlCard(card);
      if (item == null || !seen.add(item.link)) {
        continue;
      }
      results.add(item);
    }

    return results;
  }

  SearchResultItem? _parseHtmlCard(dom.Element card) {
    final link = card.querySelector('a[href*="/youshengxiaoshuo/"]');
    final href = link?.attributes['href'] ?? '';
    final img = card.querySelector('img');
    final titleFromText = _cleanText(
      card
              .querySelector(
                '.book-title a, .list-name, .module-slide-caption, .title',
              )
              ?.text ??
          '',
    );
    final title = titleFromText.isNotEmpty
        ? titleFromText
        : _stripAudioBookSuffix(
            img?.attributes['alt'] ?? link?.attributes['title'] ?? '',
          );

    if (href.isEmpty || title.isEmpty) {
      return null;
    }

    final metas = card.querySelectorAll('.book-meta, .ent');
    return SearchResultItem(
      title: title,
      coverUrl: _imageUrl(img) ?? '',
      link: _absoluteUrl(href),
      announcer: metas.length > 1
          ? _cleanText(
              metas[1].text,
            ).replaceFirst(RegExp(r'^\u64ad\u97f3[:\uff1a]'), '')
          : '',
      category: _cleanText(
        card.querySelector('.module-slide-author')?.text ?? '',
      ),
      summary: _cleanText(
        card.querySelector('.book-desc, .summary, .text')?.text ?? '',
      ),
    );
  }

  String? _imageUrl(dom.Element? img) {
    if (img == null) {
      return null;
    }
    return img.attributes['data-original'] ?? img.attributes['src'];
  }

  String _stripAudioBookSuffix(String value) {
    return _cleanText(
      value,
    ).replaceFirst(RegExp(r'\u6709\u58f0\u5c0f\u8bf4$'), '');
  }

  String _cleanText(String text) {
    return text
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _absoluteUrl(String href) {
    if (href.startsWith('http')) {
      return href;
    }
    if (!href.startsWith('/')) {
      return '$_baseUrl/$href';
    }
    return '$_baseUrl$href';
  }
}
