import 'package:flutter/material.dart';

import 'package:audio_book/features/book_detail/book_detail_api.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';
import 'package:audio_book/features/player/player_page.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.bookId,
    this.initialTitle,
  });

  final String bookId;
  final String? initialTitle;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<BookDetail> _future;
  final BookDetailApi _api = BookDetailApi();

  @override
  void initState() {
    super.initState();
    _future = _api.fetchDetail(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTitle ?? '书籍详情'),
      ),
      body: FutureBuilder<BookDetail>(
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
                    const Text('加载书籍详情失败'),
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
                          _future = _api.fetchDetail(widget.bookId);
                        });
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('没有数据'));
          }

          return ListView(
            children: [
              _buildHeader(context, detail),
              const SizedBox(height: 12),
              _buildIntro(context, detail),
              const SizedBox(height: 12),
              _buildEpisodes(context, detail),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BookDetail detail) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 110,
              height: 150,
              child: Image.network(
                detail.coverUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (detail.author.isNotEmpty)
                  Text('作者：${detail.author}'),
                if (detail.announcer.isNotEmpty)
                  Text('主播：${detail.announcer}'),
                if (detail.category.isNotEmpty)
                  Text('类型：${detail.category}'),
                if (detail.date.isNotEmpty)
                  Text('时间：${detail.date}'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (detail.episodes.isEmpty) return;
                    final first = detail.episodes.first;
                    final featureKey = _extractFeatureKey(first.playUrl);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerPage(
                          featureKey: featureKey,
                          title: first.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('立即收听'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context, BookDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '内容简介',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (detail.introParagraphs.isEmpty)
                const Text('暂无简介')
              else
                ...detail.introParagraphs.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      p,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodes(BuildContext context, BookDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '作品目录',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (detail.episodes.isEmpty)
                const Text('暂无章节')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detail.episodes.length,
                  itemBuilder: (context, index) {
                    final ep = detail.episodes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        ep.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        final featureKey = _extractFeatureKey(ep.playUrl);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerPage(
                              featureKey: featureKey,
                              title: ep.title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractFeatureKey(String playUrl) {
    final reg = RegExp(r'/play/([^/]+)\.html|/ting/([^/]+)\.html');
    final match = reg.firstMatch(playUrl);
    if (match != null) {
      return match.group(1) ?? match.group(2) ?? '';
    }
    return playUrl;
  }
}

