class BookEpisode {
  BookEpisode({
    required this.title,
    required this.playUrl,
  });

  final String title;
  final String playUrl;
}

class BookRecommend {
  BookRecommend({
    required this.bookId,
    required this.title,
    required this.coverUrl,
    required this.link,
    required this.author,
    required this.announcer,
    required this.summary,
  });

  final String bookId;
  final String title;
  final String coverUrl;
  final String link;
  final String author;
  final String announcer;
  final String summary;
}

class BookDetail {
  BookDetail({
    required this.bookId,
    required this.name,
    required this.coverUrl,
    required this.author,
    required this.announcer,
    required this.category,
    required this.date,
    required this.introParagraphs,
    required this.episodes,
    required this.recommends,
  });

  final String bookId;
  final String name;
  final String coverUrl;
  final String author;
  final String announcer;
  final String category;
  final String date;
  final List<String> introParagraphs;
  final List<BookEpisode> episodes;
  final List<BookRecommend> recommends;
}

