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
  static const String _webBaseUrl = 'https://www.ting13.cc';

  Future<List<SearchResultItem>> search(String query) async {
    final apiResults = await _tryApiSearch(query);
    if (apiResults.isNotEmpty) {
      return apiResults;
    }

    final response = await _client.dio.post<String>(
      '$_webBaseUrl/novelsearch/search/result.html',
      data: {'searchword': query},
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36',
          'Referer': _webBaseUrl,
        },
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
      '.list-works > li, .book-ol .book-li, .list-li, .pic_list, section.page-content .card',
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
    final link = card.querySelector(
      '.list-book-dt a[href*="/youshengxiaoshuo/"], '
      '.book-title a[href*="/youshengxiaoshuo/"], '
      'a.thumb[href*="/youshengxiaoshuo/"], '
      'a[href*="/youshengxiaoshuo/"]',
    );
    final href = link?.attributes['href'] ?? '';
    final img = card.querySelector('img');
    final titleFromText = _cleanText(
      card
              .querySelector(
                '.list-book-dt a[href*="/youshengxiaoshuo/"], .book-title a, .list-name, .module-slide-caption, .title',
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
      announcer: _parseAnnouncer(card, metas),
      category: _cleanText(
        card.querySelector('.module-slide-author, .ztlz')?.text ?? '',
      ),
      summary: _cleanText(
        card
                .querySelector('.list-book-des, .book-desc, .summary, .text')
                ?.text ??
            '',
      ),
    );
  }

  String _parseAnnouncer(dom.Element card, List<dom.Element> metas) {
    final boyin = _cleanText(
      card.querySelector('.book-boyin')?.text ?? '',
    ).replaceFirst(RegExp(r'^\u6f14\u64ad[:\uff1a]'), '');
    if (boyin.isNotEmpty) {
      return boyin;
    }
    if (metas.length > 1) {
      return _cleanText(
        metas[1].text,
      ).replaceFirst(RegExp(r'^\u64ad\u97f3[:\uff1a]'), '');
    }
    return '';
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
