import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';
import 'package:audio_book/features/home/home_models.dart';

class HomeApi {
  HomeApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = SiteConfig.baseUrl;

  Future<HomeData> fetchHome() async {
    final response = await _client.dio.get<String>(
      _baseUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: SiteConfig.mobileHeaders,
      ),
    );

    final document = html_parser.parse(response.data ?? '');
    return HomeData(
      banners: _parseBanners(document),
      recommendBooks: _parseRecommends(document),
    );
  }

  List<HomeBanner> _parseBanners(dom.Document document) {
    final elements = document.querySelectorAll(
      '.focusBox .pic a[href*="/youshengxiaoshuo/"], '
      'section.swiper-container .swiper-slide a[href*="/youshengxiaoshuo/"]',
    );

    return elements
        .map((a) {
          final href = a.attributes['href'] ?? '';
          final img = a.querySelector('img');
          final titleFromAttr = _cleanText(a.attributes['title'] ?? '');
          final title = titleFromAttr.isNotEmpty
              ? titleFromAttr
              : _stripAudioBookSuffix(img?.attributes['alt'] ?? '');

          return HomeBanner(
            title: title,
            imageUrl: _imageUrl(img) ?? '',
            link: _absoluteUrl(href),
            bookId: _extractBookId(href),
          );
        })
        .where((item) => item.bookId.isNotEmpty)
        .toList();
  }

  List<HomeRecommendBook> _parseRecommends(dom.Document document) {
    final editorSection = document
        .querySelectorAll('.list')
        .where(
          (section) =>
              section
                  .querySelector('.module-title-h')
                  ?.text
                  .contains('\u7f16\u8f91\u63a8\u8350') ??
              false,
        )
        .firstOrNull;

    final source = editorSection != null
        ? editorSection.querySelectorAll('.list-li')
        : document.querySelectorAll('.list-li, .module-slide-li');

    final result = <HomeRecommendBook>[];
    final seen = <String>{};
    for (final item in source) {
      final book = _parseGridBook(item);
      if (book == null || !seen.add(book.link)) {
        continue;
      }
      result.add(book);
      if (result.length >= 12) {
        break;
      }
    }

    return result;
  }

  HomeRecommendBook? _parseGridBook(dom.Element item) {
    final link = item.querySelector('a[href*="/youshengxiaoshuo/"]');
    if (link == null) {
      return null;
    }

    final href = link.attributes['href'] ?? '';
    final img = link.querySelector('img') ?? item.querySelector('img');
    final titleFromText = _cleanText(
      item.querySelector('.list-name, .module-slide-caption')?.text ?? '',
    );
    final title = titleFromText.isNotEmpty
        ? titleFromText
        : _stripAudioBookSuffix(
            img?.attributes['alt'] ?? link.attributes['title'] ?? '',
          );

    if (href.isEmpty || title.isEmpty) {
      return null;
    }

    final status = _cleanText(item.querySelector('.score')?.text ?? '');
    final category = _cleanText(
      item.querySelector('.module-slide-author')?.text ?? '',
    );

    return HomeRecommendBook(
      title: title,
      author: status,
      category: category,
      coverUrl: _imageUrl(img) ?? '',
      link: _absoluteUrl(href),
      summary: status,
      bookId: _extractBookId(href),
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

  String _extractBookId(String href) {
    final match = RegExp(r'/youshengxiaoshuo/(\d+)/').firstMatch(href);
    return match?.group(1) ?? '';
  }
}
