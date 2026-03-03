class HomeBanner {
  HomeBanner({
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.bookId,
  });

  final String title;
  final String imageUrl;
  final String link;
  final String bookId;
}

class HomeRecommendBook {
  HomeRecommendBook({
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.link,
    required this.summary,
    required this.bookId,
  });

  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final String link;
  final String summary;
  final String bookId;
}

class HomeData {
  HomeData({
    required this.banners,
    required this.recommendBooks,
  });

  final List<HomeBanner> banners;
  final List<HomeRecommendBook> recommendBooks;
}

