import 'package:flutter/material.dart';

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/features/book_detail/book_detail_page.dart';
import 'package:audio_book/features/home/home_api.dart';
import 'package:audio_book/features/home/home_models.dart';
import 'package:audio_book/features/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<HomeData> _future;
  final HomeApi _api = HomeApi();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cookieController = TextEditingController();

  int _titleTapCount = 0;
  DateTime? _lastTitleTapTime;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: FutureBuilder<HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('加载首页失败'),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _future = _api.fetchHome();
                          });
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text('没有数据'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _future = _api.fetchHome();
                });
                await _future;
              },
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _buildSearchBar(context),
                  ),
                  _buildBanner(context, data.banners),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _onRecommendTitleTap,
                      child: Text(
                        '有声小说推荐收听',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...data.recommendBooks
                      .map((b) => _buildRecommendItem(context, b)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _onSearchSubmitted,
      decoration: InputDecoration(
        hintText: '搜索有声小说',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _onSearchSubmitted(_searchController.text),
        ),
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(query: query),
      ),
    );
  }

  void _onRecommendTitleTap() {
    final now = DateTime.now();
    if (_lastTitleTapTime == null ||
        now.difference(_lastTitleTapTime!) > const Duration(seconds: 2)) {
      _titleTapCount = 0;
    }
    _lastTitleTapTime = now;
    _titleTapCount++;
    if (_titleTapCount >= 3) {
      _titleTapCount = 0;
      _showCookieDialog();
    }
  }

  Future<void> _showCookieDialog() async {
    _cookieController.text = ApiClient().cookie ?? '';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置 Cookie'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _cookieController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '在这里粘贴从网页复制的 Cookie',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ApiClient().setCookie(_cookieController.text);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context, List<HomeBanner> banners) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final item = banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendItem(
    BuildContext context,
    HomeRecommendBook book,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (book.bookId.isEmpty) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookDetailPage(
                  bookId: book.bookId,
                  initialTitle: book.title,
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                height: 128,
                child: Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.category,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.blue),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

