import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';

class BookDetailApi {
  BookDetailApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = SiteConfig.baseUrl;
  static const String _fullWidthColon = '\uff1a';

  Future<BookDetail> fetchDetail(String bookId) async {
    final response = await _client.dio.get<String>(
      '$_baseUrl/youshengxiaoshuo/$bookId/',
      options: Options(
        responseType: ResponseType.plain,
        headers: SiteConfig.mobileHeaders,
      ),
    );

    final document = html_parser.parse(response.data ?? '');

    return BookDetail(
      bookId: bookId,
      name: _cleanText(document.querySelector('.book .book-title')?.text ?? ''),
      coverUrl: _imageUrl(document.querySelector('.book .book-cover')) ?? '',
      author: _parseInfo(document, '\u4f5c\u8005'),
      announcer: _parseInfo(
        document,
        '\u64ad\u8bb2',
        fallbackLabel: '\u4e3b\u64ad',
      ),
      category: _parseInfo(document, '\u7c7b\u578b'),
      date: _parseDate(document),
      introParagraphs: _parseIntro(document),
      episodes: _parseEpisodes(document),
      recommends: _parseRecommends(document),
    );
  }

  List<String> _parseIntro(dom.Document document) {
    final intro = document.querySelector('.book-des#play, .book-des');
    if (intro == null) {
      return const <String>[];
    }

    final parts = intro.innerHtml
        .split(RegExp(r'<br\s*/?>', caseSensitive: false))
        .map((part) => _cleanText(html_parser.parseFragment(part).text ?? ''))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isNotEmpty) {
      return parts;
    }

    final text = _cleanText(intro.text);
    return text.isEmpty ? const <String>[] : <String>[text];
  }

  List<BookEpisode> _parseEpisodes(dom.Document document) {
    final result = <BookEpisode>[];
    final seen = <String>{};

    for (final a in document.querySelectorAll('.play-list a[href*="/play/"]')) {
      final href = a.attributes['href'] ?? '';
      final title = _episodeTitle(a);
      if (href.isEmpty || title.isEmpty || !seen.add(href)) {
        continue;
      }

      result.add(BookEpisode(title: title, playUrl: _absoluteUrl(href)));
    }

    return result;
  }

  List<BookRecommend> _parseRecommends(dom.Document document) {
    final recommends = <BookRecommend>[];

    for (final item in document.querySelectorAll('.book-ol .book-li')) {
      final href =
          item
              .querySelector('a[href*="/youshengxiaoshuo/"]')
              ?.attributes['href'] ??
          '';
      final img = item.querySelector('img');
      final titleFromLink = _cleanText(
        item.querySelector('.book-title a')?.text ?? '',
      );
      final title = titleFromLink.isNotEmpty
          ? titleFromLink
          : _stripAudioBookSuffix(img?.attributes['alt'] ?? '');

      if (href.isEmpty || title.isEmpty) {
        continue;
      }

      final meta = item.querySelectorAll('.book-meta');
      recommends.add(
        BookRecommend(
          bookId: _extractBookId(href),
          title: title,
          coverUrl: _imageUrl(img) ?? '',
          link: _absoluteUrl(href),
          author: meta.isNotEmpty ? _cleanText(meta.first.text) : '',
          announcer: meta.length > 1 ? _cleanText(meta[1].text) : '',
          summary: _cleanText(item.querySelector('.book-desc')?.text ?? ''),
        ),
      );
    }

    return recommends;
  }

  String _parseInfo(
    dom.Document document,
    String label, {
    String? fallbackLabel,
  }) {
    final labels = {label, ?fallbackLabel};
    for (final item in document.querySelectorAll('.book .book-rand-a')) {
      final text = _cleanText(item.text);
      final separator = text.indexOf(_fullWidthColon);
      if (separator <= 0) {
        continue;
      }

      final itemLabel = text.substring(0, separator).trim();
      if (labels.contains(itemLabel)) {
        return text.substring(separator + 1).trim();
      }
    }
    return '';
  }

  String _parseDate(dom.Document document) {
    for (final item in document.querySelectorAll('.book .book-rand-a')) {
      final match = RegExp(
        r'\d{4}/\d{2}/\d{2}(?:\s+\d{2}:\d{2}:\d{2})?',
      ).firstMatch(item.text);
      if (match != null) {
        return match.group(0) ?? '';
      }
    }
    return '';
  }

  String _episodeTitle(dom.Element a) {
    final clone = dom.Element.html(a.outerHtml);
    for (final noise in clone.querySelectorAll('span, i')) {
      noise.remove();
    }

    final visibleTitle = _cleanText(
      clone.text
          .replaceFirst(RegExp(r'^\d{2}-\d{2}'), '')
          .replaceFirst(RegExp(r'^\d+\s*'), ''),
    );
    if (visibleTitle.isNotEmpty) {
      return visibleTitle;
    }

    final rawTitle = a.attributes['title'] ?? '';
    return _cleanText(
      rawTitle
          .replaceFirst(RegExp(r'^.+?\u6709\u58f0\u5c0f\u8bf4\s*'), '')
          .replaceFirst('\u5728\u7ebf\u6536\u542c', ''),
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
