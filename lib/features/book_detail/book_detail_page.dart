import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:audio_book/core/platform/system_share.dart';
import 'package:audio_book/core/storage/local_library.dart';
import 'package:audio_book/features/book_detail/book_detail_api.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';
import 'package:audio_book/features/player/player_api.dart';
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
  final PlayerApi _playerApi = PlayerApi();
  final Dio _downloadDio = Dio();
  final LocalLibrary _library = LocalLibrary();
  final SystemShare _share = SystemShare();
  final ScrollController _scrollController = ScrollController();

  final List<BookEpisode> _episodes = <BookEpisode>[];
  final Set<int> _loadedDirectoryPages = <int>{1};
  List<DirectoryPageLink> _directoryPageLinks = <DirectoryPageLink>[];
  bool _episodesAscending = true;
  bool _loadingMoreEpisodes = false;
  bool _inBookshelf = false;
  PlaybackRecord? _latestPlayback;
  Map<String, ChapterProgress> _chapterProgress = const {};
  Map<String, DownloadCacheRecord> _downloadCaches = const {};
  final Set<String> _downloadingFeatureKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _future = _api.fetchDetail(widget.bookId);
    _scrollController.addListener(_onScroll);
    _loadBookshelfStatus();
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
      body: FutureBuilder<BookDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error, onRetry: _reload);
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('暂无数据'));
          }
          _syncEpisodes(detail);

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: const Text('书籍详情'),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(child: _buildHero(detail)),
                  SliverToBoxAdapter(child: _buildStats(detail)),
                  SliverToBoxAdapter(child: _buildIntro(detail)),
                  SliverToBoxAdapter(child: _buildEpisodes(detail)),
                  SliverToBoxAdapter(child: _buildRecommends(detail)),
                  const SliverToBoxAdapter(child: SizedBox(height: 112)),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomPlayBar(
                  text: _episodes.isEmpty ? '暂无可播放章节' : '继续播放',
                  subtitle: _episodes.isEmpty ? '' : _episodes.first.title,
                  onPressed: _episodes.isEmpty
                      ? null
                      : () => _openPlayer(context, _episodes.first),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BookDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F8FD), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 168,
            height: 214,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFD8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _NetworkImage(url: detail.coverUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            detail.name.isEmpty ? (widget.initialTitle ?? '') : detail.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (detail.author.isNotEmpty)
                Text(
                  detail.author,
                  style: const TextStyle(
                    color: Color(0xFF59606A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (detail.announcer.isNotEmpty)
                Text(
                  '主播 ${detail.announcer}',
                  style: const TextStyle(
                    color: Color(0xFF59606A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (detail.category.isNotEmpty) _Tag(text: detail.category),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroAction(
                icon: _inBookshelf ? Icons.favorite : Icons.favorite_border,
                label: _inBookshelf ? '已在书架' : '加入书架',
                onTap: () => _toggleBookshelf(detail),
              ),
              const SizedBox(width: 18),
              _HeroAction(
                icon: Icons.download_outlined,
                label: '离线缓存',
                onTap: () => _showCacheHint(detail),
              ),
              const SizedBox(width: 18),
              _HeroAction(
                icon: Icons.share_outlined,
                label: '分享书籍',
                onTap: () => _shareBook(detail),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BookDetail detail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEEF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                icon: Icons.menu_book_outlined,
                label: '连载状态',
                value: _statusText(detail),
              ),
            ),
            const _DividerLine(),
            Expanded(
              child: _StatCell(
                icon: Icons.local_fire_department_outlined,
                label: '全网热度',
                value: detail.heat,
              ),
            ),
            const _DividerLine(),
            Expanded(
              child: _StatCell(
                icon: Icons.format_list_numbered,
                label: '总章节',
                value: detail.totalEpisodes > 0
                    ? '${detail.totalEpisodes}章'
                    : '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(BookDetail detail) {
    final intro = detail.introParagraphs.join('\n\n').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(title: '简介', trailing: detail.category),
          const SizedBox(height: 12),
          Text(
            intro.isEmpty ? '暂无简介' : intro,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF59606A),
              height: 1.75,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('展开全文')),
        ],
      ),
    );
  }

  Widget _buildEpisodes(BookDetail detail) {
    final episodes = _episodesAscending
        ? _episodes
        : _episodes.reversed.toList();
    final canLoadMore = _nextDirectoryPageLink != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _episodeSectionTitle(detail),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _loadingMoreEpisodes
                    ? null
                    : _showDirectoryPagePicker,
                icon: const Icon(Icons.swap_vert, size: 18),
                label: const Text('选集'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _episodesAscending = !_episodesAscending);
                },
                child: Text(_episodesAscending ? '正序' : '倒序'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (episodes.isEmpty)
            const Text('暂无章节')
          else
            for (var i = 0; i < episodes.take(12).length; i++)
              Builder(
                builder: (context) {
                  final episode = episodes[i];
                  final featureKey = _extractFeatureKey(episode.playUrl);
                  return _EpisodeTile(
                    index: i + 1,
                    episode: episode,
                    selected: _latestPlayback?.featureKey == featureKey,
                    progress: _chapterProgress[featureKey],
                    cache: _downloadCaches[featureKey],
                    downloading: _downloadingFeatureKeys.contains(featureKey),
                    onTap: () => _openPlayer(context, episode),
                    onDownload: () => _downloadEpisode(detail, episode),
                  );
                },
              ),
          if (episodes.length > 12 || canLoadMore || _loadingMoreEpisodes)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton(
                onPressed: _loadingMoreEpisodes
                    ? null
                    : (canLoadMore ? _loadNextPage : null),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _loadingMoreEpisodes
                      ? '加载中...'
                      : (canLoadMore ? '查看更多章节' : '已显示部分章节'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommends(BookDetail detail) {
    if (detail.recommends.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '听过此书的人还在听',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 188,
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 24),
              scrollDirection: Axis.horizontal,
              itemCount: detail.recommends.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final book = detail.recommends[index];
                return SizedBox(
                  width: 112,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (book.bookId.isEmpty) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(
                            bookId: book.bookId,
                            initialTitle: book.title,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _NetworkImage(
                              url: book.coverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _reload() {
    setState(() {
      _episodes.clear();
      _directoryPageLinks = <DirectoryPageLink>[];
      _loadedDirectoryPages
        ..clear()
        ..add(1);
      _future = _api.fetchDetail(widget.bookId);
    });
  }

  void _syncEpisodes(BookDetail detail) {
    if (_episodes.isNotEmpty) {
      return;
    }
    _episodes.addAll(detail.episodes);
    _directoryPageLinks = detail.directoryPageLinks;
    _loadEpisodeStates();
  }

  Future<void> _loadBookshelfStatus() async {
    final inBookshelf = await _library.isInBookshelf(widget.bookId);
    if (mounted) {
      setState(() => _inBookshelf = inBookshelf);
    }
  }

  Future<void> _toggleBookshelf(BookDetail detail) async {
    if (_inBookshelf) {
      await _library.removeBook(detail.bookId);
      if (mounted) {
        setState(() => _inBookshelf = false);
        _snack('已从书架移除');
      }
      return;
    }

    await _library.addBook(
      LocalBook(
        bookId: detail.bookId,
        title: detail.name,
        coverUrl: detail.coverUrl,
        author: detail.author,
        announcer: detail.announcer,
        category: detail.category,
        link: 'https://m.ting13.cc/youshengxiaoshuo/${detail.bookId}/',
        updatedAt: DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() => _inBookshelf = true);
      _snack('已加入书架');
    }
  }

  Future<void> _shareBook(BookDetail detail) async {
    final url = 'https://m.ting13.cc/youshengxiaoshuo/${detail.bookId}/';
    await _share.text(title: detail.name, content: '${detail.name}\n$url');
  }

  Future<void> _loadEpisodeStates() async {
    final featureKeys = _episodes.map((episode) {
      return _extractFeatureKey(episode.playUrl);
    });
    final progress = await _library.chapterProgressByFeatureKeys(featureKeys);
    final caches = await _library.downloadCacheByFeatureKeys(featureKeys);
    final latest = await _library.latestPlayback();
    if (mounted) {
      setState(() {
        _chapterProgress = progress;
        _downloadCaches = caches;
        _latestPlayback = latest;
      });
    }
  }

  Future<void> _showCacheHint(BookDetail detail) async {
    if (_episodes.isEmpty) {
      _snack('暂无可缓存章节');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(Icons.download_outlined),
                  title: Text('离线缓存'),
                  subtitle: Text('当前支持单集缓存，点击章节右侧下载按钮即可缓存音频'),
                ),
                ListTile(
                  leading: const Icon(Icons.download_for_offline_outlined),
                  title: Text('缓存 ${_episodes.first.title}'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _downloadEpisode(detail, _episodes.first);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadEpisode(BookDetail detail, BookEpisode episode) async {
    final featureKey = _extractFeatureKey(episode.playUrl);
    if (featureKey.isEmpty || _downloadingFeatureKeys.contains(featureKey)) {
      return;
    }
    final cached = _downloadCaches[featureKey];
    if (cached?.isReady ?? false) {
      _snack('已缓存 ${episode.title}');
      return;
    }

    setState(() => _downloadingFeatureKeys.add(featureKey));
    await _library.saveDownloadCache(
      DownloadCacheRecord(
        featureKey: featureKey,
        title: episode.title,
        bookName: detail.name,
        coverUrl: detail.coverUrl,
        filePath: '',
        status: 'downloading',
        bytes: 0,
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final info = await _playerApi.fetchPlayInfo(featureKey);
      final uri = Uri.parse(info.audioUrl);
      final extension = p.extension(uri.path).isEmpty
          ? '.m4a'
          : p.extension(uri.path);
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory(p.join(dir.path, 'audio_cache'));
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      final file = File(p.join(cacheDir.path, '$featureKey$extension'));
      await _downloadDio.download(info.audioUrl, file.path);
      final bytes = await file.length();
      await _library.saveDownloadCache(
        DownloadCacheRecord(
          featureKey: featureKey,
          title: episode.title,
          bookName: detail.name,
          coverUrl: detail.coverUrl,
          filePath: file.path,
          status: 'ready',
          bytes: bytes,
          updatedAt: DateTime.now(),
        ),
      );
      await _loadEpisodeStates();
      _snack('已缓存 ${episode.title}');
    } catch (error) {
      await _library.saveDownloadCache(
        DownloadCacheRecord(
          featureKey: featureKey,
          title: episode.title,
          bookName: detail.name,
          coverUrl: detail.coverUrl,
          filePath: '',
          status: 'failed',
          bytes: 0,
          updatedAt: DateTime.now(),
        ),
      );
      _snack('缓存失败：$error');
    } finally {
      if (mounted) {
        setState(() => _downloadingFeatureKeys.remove(featureKey));
      }
    }
  }

  String _episodeSectionTitle(BookDetail detail) {
    final total = detail.totalEpisodes;
    if (total > 0 && total > _episodes.length) {
      return '正文目录 已加载${_episodes.length} / 共$total章';
    }
    return '正文目录 共${_episodes.length}章';
  }

  void _onScroll() {
    if (_loadingMoreEpisodes || _nextDirectoryPageLink == null) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 500) {
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
      final seen = _episodes.map((episode) => episode.playUrl).toSet();
      setState(() {
        for (final episode in data.episodes) {
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
      await _loadEpisodeStates();
    } finally {
      if (mounted) {
        setState(() => _loadingMoreEpisodes = false);
      }
    }
  }

  Future<void> _showDirectoryPagePicker() async {
    if (_directoryPageLinks.isEmpty) {
      return;
    }
    final selected = await showModalBottomSheet<DirectoryPageLink>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final links = _directoryPageLinks.toList()
          ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            itemCount: links.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final link = links[index];
              final loaded = _loadedDirectoryPages.contains(link.pageNumber);
              return ListTile(
                leading: Icon(
                  loaded ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: loaded ? Theme.of(context).colorScheme.primary : null,
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
    final playlist = List<BookEpisode>.unmodifiable(_episodes);
    final currentIndex = playlist.indexWhere(
      (item) => item.playUrl == episode.playUrl,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          featureKey: featureKey,
          title: episode.title,
          episodes: playlist,
          directoryPageLinks: List<DirectoryPageLink>.unmodifiable(
            _directoryPageLinks,
          ),
          loadedDirectoryPages: Set<int>.unmodifiable(_loadedDirectoryPages),
          initialIndex: currentIndex < 0 ? 0 : currentIndex,
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusText(BookDetail detail) {
    if (detail.date.contains('完结') || detail.category.contains('完结')) {
      return '已完结';
    }
    return '连载中';
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

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF59606A)),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF59606A), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 70,
      child: VerticalDivider(width: 1, color: Color(0xFFECEEF2)),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        if (trailing != null && trailing!.isNotEmpty) _Tag(text: trailing!),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF59606A), fontSize: 12),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.index,
    required this.episode,
    required this.selected,
    required this.progress,
    required this.cache,
    required this.downloading,
    required this.onTap,
    required this.onDownload,
  });

  final int index;
  final BookEpisode episode;
  final bool selected;
  final ChapterProgress? progress;
  final DownloadCacheRecord? cache;
  final bool downloading;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF4FF) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: Color(0xFFECEEF2))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: selected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFF0F2F4),
              child: Text(
                '$index',
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF59606A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF1F2328),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF59606A),
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: downloading || (cache?.isReady ?? false)
                  ? null
                  : onDownload,
              icon: downloading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      (cache?.isReady ?? false)
                          ? Icons.download_done
                          : Icons.download_outlined,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final cacheReady = cache?.isReady ?? false;
    final cacheText = cacheReady ? ' · 已缓存' : '';
    if (selected) {
      final percent = _progressPercent;
      return percent > 0 ? '正在播放 · $percent%$cacheText' : '正在播放$cacheText';
    }
    final p = progress;
    if (p == null) {
      return '未播放$cacheText';
    }
    if (p.isPlayed) {
      return '已播$cacheText';
    }
    final percent = _progressPercent;
    return percent > 0 ? '播放至 $percent%$cacheText' : '未播放$cacheText';
  }

  int get _progressPercent {
    final p = progress;
    if (p == null) {
      return 0;
    }
    return (p.progress.clamp(0, 1) * 100).round();
  }
}

class _BottomPlayBar extends StatelessWidget {
  const _BottomPlayBar({
    required this.text,
    required this.subtitle,
    required this.onPressed,
  });

  final String text;
  final String subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            border: const Border(top: BorderSide(color: Color(0xFFECEEF2))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.play_arrow),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFF0F4F8),
        child: Icon(Icons.menu_book, color: Color(0xFF9AA4B2), size: 42),
      );
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFF0F4F8),
        child: Icon(Icons.menu_book, color: Color(0xFF9AA4B2), size: 42),
      ),
    );
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '加载书籍详情失败',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF59606A)),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
