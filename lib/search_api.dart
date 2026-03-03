import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'search_models.dart';

class SearchApi {
  SearchApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://m.huanting.cc';

  Future<List<SearchResultItem>> search(String query) async {
    final response = await _dio.get<String>(
      '$_baseUrl/Ms.php',
      queryParameters: {'q': query},
      options: Options(
        responseType: ResponseType.plain,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
        },
      ),
    );

    final html = response.data ?? '';
    final document = html_parser.parse(html);

    return _parseResults(document);
  }

  List<SearchResultItem> _parseResults(dom.Document document) {
    final cards = document.querySelectorAll('section.page-content .card');
    final results = <SearchResultItem>[];

    for (final card in cards) {
      final link = card.querySelector('a.link');
      if (link == null) {
        continue;
      }

      final href = link.attributes['href'] ?? '';

      final img = card.querySelector('.sumext-pic-con .pic img');
      final coverUrl = img?.attributes['src'] ?? '';

      final titleElement = card.querySelector('.sumext-pic-con .con .title');
      final title = titleElement?.text.trim() ?? '';

      final entElements = card.querySelectorAll('.sumext-pic-con .con .ent');
      String announcer = '';
      String category = '';
      if (entElements.length >= 2) {
        announcer = entElements[0].text.replaceFirst('播音：', '').trim();
        category = entElements[1].text.replaceFirst('栏目：', '').trim();
      } else {
        for (final e in entElements) {
          final text = e.text.trim();
          if (text.startsWith('播音：')) {
            announcer = text.replaceFirst('播音：', '').trim();
          } else if (text.startsWith('栏目：')) {
            category = text.replaceFirst('栏目：', '').trim();
          }
        }
      }

      final summary =
          card.querySelector('.sumext-pic-con .con .summary')?.text.trim() ??
              '';

      if (title.isEmpty) {
        continue;
      }

      results.add(
        SearchResultItem(
          title: title,
          coverUrl: coverUrl,
          link: _absoluteUrl(href),
          announcer: announcer,
          category: category,
          summary: summary,
        ),
      );
    }

    return results;
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

