import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';

class BookDetailApi {
  BookDetailApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _baseUrl = 'https://m.huanting.cc';

  Future<BookDetail> fetchDetail(String bookId) async {
    final response = await _client.dio.get<String>(
      '$_baseUrl/book/$bookId.html',
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

    final name =
        document.querySelector('section.booksite .bookinfo .bookname')?.text
                .trim() ??
            '';

    final coverUrl =
        document.querySelector('section.booksite .bookimg img')?.attributes['src'] ??
            '';

    final info = document.querySelector('section.booksite .bookinfo .info');
    String author = '';
    String announcer = '';
    String category = '';
    String date = '';
    if (info != null) {
      final divs = info.querySelectorAll('div');
      for (final d in divs) {
        final text = d.text.trim();
        if (text.startsWith('作者：')) {
          author = text.replaceFirst('作者：', '').trim();
        } else if (text.startsWith('主播：')) {
          announcer = text.replaceFirst('主播：', '').trim();
        } else if (text.startsWith('类型：')) {
          category = text.replaceFirst('类型：', '').trim();
        } else if (text.startsWith('时间：')) {
          date = text.replaceFirst('时间：', '').trim();
        }
      }
    }

    final introSection = document.querySelector('section.bookintro');
    final introParagraphs = <String>[];
    if (introSection != null) {
      for (final p in introSection.querySelectorAll('p')) {
        final t = p.text.trim();
        if (t.isNotEmpty) {
          introParagraphs.add(t);
        }
      }
    }

    final episodes = <BookEpisode>[];
    final pressList = document.querySelector('ul.press');
    if (pressList != null) {
      for (final a in pressList.querySelectorAll('a')) {
        final href = a.attributes['href'] ?? '';
        final title = a.text.trim();
        if (href.isEmpty || title.isEmpty) continue;
        episodes.add(
          BookEpisode(
            title: title,
            playUrl: _absoluteUrl(href),
          ),
        );
      }
    }

    final recommends = <BookRecommend>[];
    for (final item in document.querySelectorAll('section .pic_list')) {
      final linkElement = item.querySelector('.img a');
      final href = linkElement?.attributes['href'] ?? '';
      final title =
          item.querySelector('.info .tit a')?.text.trim() ?? '';
      final img = item.querySelector('.img img');
      final cover =
          img?.attributes['data-original'] ?? img?.attributes['src'] ?? '';
      final authorText =
          item.querySelector('.info .author')?.text.trim() ?? '';
      final announcerText =
          item.querySelector('.info .announcer')?.text.trim() ?? '';
      final summary =
          item.querySelector('.info .text')?.text.trim() ?? '';

      if (href.isEmpty || title.isEmpty) continue;

      final recommendBookId = _extractBookId(href);

      recommends.add(
        BookRecommend(
          bookId: recommendBookId,
          title: title,
          coverUrl: cover,
          link: _absoluteUrl(href),
          author: authorText,
          announcer: announcerText,
          summary: summary,
        ),
      );
    }

    return BookDetail(
      bookId: bookId,
      name: name,
      coverUrl: coverUrl,
      author: author,
      announcer: announcer,
      category: category,
      date: date,
      introParagraphs: introParagraphs,
      episodes: episodes,
      recommends: recommends,
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

  String _extractBookId(String href) {
    final reg = RegExp(r'/book/(\d+)\.html');
    final match = reg.firstMatch(href);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }
    return '';
  }
}

