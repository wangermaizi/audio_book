import 'package:flutter/material.dart';

import 'package:audio_book/features/book_detail/book_detail_api.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';
import 'package:audio_book/features/player/player_page.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.bookId, this.initialTitle});

  final String bookId;
  final String? initialTitle;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<BookDetail> _future;
  final BookDetailApi _api = BookDetailApi();
  final ScrollController _scrollController = ScrollController();

  final List<BookEpisode> _episodes = <BookEpisode>[];
  final Set<int> _loadedDirectoryPages = <int>{1};
  List<DirectoryPageLink> _directoryPageLinks = <DirectoryPageLink>[];
  bool _episodesAscending = true;
  bool _loadingMoreEpisodes = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchDetail(widget.bookId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialTitle ?? '书籍详情')),
      body: FutureBuilder<BookDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error,
              onRetry: () {
                setState(() {
                  _episodes.clear();
                  _directoryPageLinks = <DirectoryPageLink>[];
                  _loadedDirectoryPages
                    ..clear()
                    ..add(1);
                  _future = _api.fetchDetail(widget.bookId);
                });
              },
            );
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('没有数据'));
          }
          _syncEpisodes(detail);

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildHeader(context, detail),
              const SizedBox(height: 12),
              _buildIntro(context, detail),
              const SizedBox(height: 12),
              _buildEpisodes(context),
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
              child: Image.network(detail.coverUrl, fit: BoxFit.cover),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (detail.author.isNotEmpty) Text('作者：${detail.author}'),
                if (detail.announcer.isNotEmpty) Text('主播：${detail.announcer}'),
                if (detail.category.isNotEmpty) Text('类型：${detail.category}'),
                if (detail.date.isNotEmpty) Text('时间：${detail.date}'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_episodes.isEmpty) return;
                    _openPlayer(context, _episodes.first);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '内容简介',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildEpisodes(BuildContext context) {
    final episodes = _episodesAscending
        ? _episodes
        : _episodes.reversed.toList();
    final canLoadMore = _nextDirectoryPageLink != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '作品目录',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (episodes.isNotEmpty)
                    Text(
                      '已加载 ${episodes.length} 集',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_directoryPageLinks.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _loadingMoreEpisodes
                          ? null
                          : _showDirectoryPagePicker,
                      icon: const Icon(Icons.view_list, size: 18),
                      label: const Text('选集范围'),
                    ),
                  const Spacer(),
                  if (episodes.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _episodesAscending = !_episodesAscending;
                        });
                      },
                      icon: Icon(
                        _episodesAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                      label: Text(_episodesAscending ? '正序' : '倒序'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (episodes.isEmpty)
                const Text('暂无章节')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final episode = episodes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: SizedBox(
                        width: 36,
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      title: Text(
                        episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openPlayer(context, episode),
                    );
                  },
                ),
              if (canLoadMore || _loadingMoreEpisodes) ...[
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _loadingMoreEpisodes ? null : _loadNextPage,
                    icon: _loadingMoreEpisodes
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(_loadingMoreEpisodes ? '加载中...' : '加载更多章节'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _syncEpisodes(BookDetail detail) {
    if (_episodes.isNotEmpty) {
      return;
    }
    _episodes.addAll(detail.episodes);
    _directoryPageLinks = detail.directoryPageLinks;
  }

  void _onScroll() {
    if (_loadingMoreEpisodes || _nextDirectoryPageLink == null) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.extentAfter < 500) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    final link = _nextDirectoryPageLink;
    if (link == null) {
      return;
    }
    await _loadDirectoryPage(link);
  }

  Future<void> _loadDirectoryPage(DirectoryPageLink link) async {
    if (_loadingMoreEpisodes ||
        _loadedDirectoryPages.contains(link.pageNumber)) {
      return;
    }

    setState(() => _loadingMoreEpisodes = true);
    try {
      final data = await _api.fetchDirectoryPageData(link.url);
      final nextEpisodes = data.episodes;
      final seen = _episodes.map((episode) => episode.playUrl).toSet();
      setState(() {
        for (final episode in nextEpisodes) {
          if (seen.add(episode.playUrl)) {
            _episodes.add(episode);
          }
        }
        _episodes.sort(
          (a, b) => _episodeNumber(a).compareTo(_episodeNumber(b)),
        );
        _loadedDirectoryPages.add(link.pageNumber);
        _mergeDirectoryPageLinks(data.pageLinks);
      });
    } finally {
      if (mounted) {
        setState(() => _loadingMoreEpisodes = false);
      }
    }
  }

  Future<void> _showDirectoryPagePicker() async {
    final selected = await showModalBottomSheet<DirectoryPageLink>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final links = _directoryPageLinks.toList()
          ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: links.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final link = links[index];
              final loaded = _loadedDirectoryPages.contains(link.pageNumber);
              return ListTile(
                leading: Icon(
                  loaded ? Icons.check_circle : Icons.radio_button_unchecked,
                ),
                title: Text('第 ${link.label} 集'),
                subtitle: Text(loaded ? '已加载' : '点击加载这个范围'),
                onTap: loaded
                    ? () => Navigator.of(context).pop()
                    : () => Navigator.of(context).pop(link),
              );
            },
          ),
        );
      },
    );

    if (selected != null) {
      await _loadDirectoryPage(selected);
    }
  }

  DirectoryPageLink? get _nextDirectoryPageLink {
    final links = _directoryPageLinks.toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    for (final link in links) {
      if (!_loadedDirectoryPages.contains(link.pageNumber)) {
        return link;
      }
    }
    return null;
  }

  void _mergeDirectoryPageLinks(List<DirectoryPageLink> links) {
    final byPage = <int, DirectoryPageLink>{
      for (final link in _directoryPageLinks) link.pageNumber: link,
    };
    for (final link in links) {
      byPage[link.pageNumber] = link;
    }
    _directoryPageLinks = byPage.values.toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  void _openPlayer(BuildContext context, BookEpisode episode) {
    final featureKey = _extractFeatureKey(episode.playUrl);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PlayerPage(featureKey: featureKey, title: episode.title),
      ),
    );
  }

  int _episodeNumber(BookEpisode episode) {
    final titleNumber = RegExp(r'\d+').firstMatch(episode.title)?.group(0);
    return int.tryParse(titleNumber ?? '') ?? 0;
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('加载书籍详情失败'),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
