import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'home_models.dart';

class HomeApi {
  HomeApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://m.huanting.cc';

  Future<HomeData> fetchHome() async {
    final response = await _dio.get<String>(
      _baseUrl,
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

    final banners = _parseBanners(document);
    final recommends = _parseRecommends(document);

    return HomeData(
      banners: banners,
      recommendBooks: recommends,
    );
  }

  List<HomeBanner> _parseBanners(dom.Document document) {
    final elements =
        document.querySelectorAll('section.swiper-container .swiper-slide a');

    return elements.map((a) {
      final href = a.attributes['href'] ?? '';
      final title = a.attributes['title'] ?? '';
      final img = a.querySelector('img');
      final src = img?.attributes['src'] ?? '';

      return HomeBanner(
        title: title,
        imageUrl: src,
        link: _absoluteUrl(href),
      );
    }).toList();
  }

  List<HomeRecommendBook> _parseRecommends(dom.Document document) {
    final result = <HomeRecommendBook>[];

    final section = document
        .querySelectorAll('section')
        .firstWhere((e) => e.text.contains('有声小说推荐收听'), orElse: () => dom.Element.tag('section'));

    final header =
        section.querySelector('h2.cat_tit');
    if (section.children.isEmpty || header == null) {
      return result;
    }

    final parentChildren = section.children;
    final startIndex = parentChildren.indexOf(header);
    if (startIndex < 0) {
      return result;
    }

    for (var i = startIndex + 1;
        i < parentChildren.length;
        i++) {
      final node = parentChildren[i];
      if (node.localName == 'h5') {
        break;
      }
      if (node.localName == 'a' &&
          node.classes.contains('bookbox')) {
        final book = _parseRecommendBook(node);
        if (book != null) {
          result.add(book);
        }
      }
    }

    return result;
  }

  HomeRecommendBook? _parseRecommendBook(dom.Element a) {
    final href = a.attributes['href'] ?? '';

    final img = a.querySelector('.bookimg img');
    final cover =
        img?.attributes['data-original'] ?? img?.attributes['src'] ?? '';

    final title =
        a.querySelector('.bookinfo .bookname')?.text.trim() ?? '';
    final author =
        a.querySelector('.bookinfo .author')?.text.trim() ?? '';
    final category =
        a.querySelector('.bookinfo .cat')?.text.trim() ?? '';
    final summary =
        a.querySelector('.bookinfo .intro, .bookinfo p.intro')
                ?.text
                .trim() ??
            '';

    if (title.isEmpty) {
      return null;
    }

    return HomeRecommendBook(
      title: title,
      author: author,
      category: category,
      coverUrl: cover,
      link: _absoluteUrl(href),
      summary: summary,
    );
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

