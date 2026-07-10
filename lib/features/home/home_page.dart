import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/player/playback_controller.dart';
import 'package:audio_book/core/storage/local_library.dart';
import 'package:audio_book/features/book_detail/book_detail_page.dart';
import 'package:audio_book/features/home/home_api.dart';
import 'package:audio_book/features/home/home_models.dart';
import 'package:audio_book/features/player/player_page.dart';
import 'package:audio_book/features/search/search_page.dart';
import 'package:audio_book/features/update/update_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomeData> _future;
  final HomeApi _api = HomeApi();
  final LocalLibrary _library = LocalLibrary();
  final UpdateService _updateService = UpdateService();
  final TextEditingController _cookieController = TextEditingController();

  int _titleTapCount = 0;
  DateTime? _lastTitleTapTime;
  bool _checkingUpdate = false;
  bool _autoUpdateChecked = false;
  PlaybackRecord? _latestPlayback;
  int _selectedIndex = 0;
  String _searchQuery = '';
  int _searchPageVersion = 0;

  static const List<String> _categories = <String>[
    '全部',
    '悬疑恐怖',
    '都市言情',
    '玄幻修仙',
    '历史军事',
  ];

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHome();
    _loadLatestPlayback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate(silentWhenLatest: true);
    });
  }

  @override
  void dispose() {
    _cookieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = _latestPlayback;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            SearchPage(
              key: ValueKey('$_searchQuery-$_searchPageVersion'),
              query: _searchQuery,
              embedded: true,
            ),
            _BookshelfPage(onOpenBook: _openBook),
            _MinePage(
              onCheckUpdate: () => _checkForUpdate(silentWhenLatest: false),
              onOpenPlayback: _openPlayback,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _HomeBottomBar(
        activeIndex: _selectedIndex,
        miniTitle: latest?.bookName ?? '',
        miniSubtitle: latest == null
            ? ''
            : '继续收听 ${latest.title} · ${_progressText(latest)}',
        miniCoverUrl: latest?.coverUrl ?? '',
        onHome: () => _selectTab(0),
        onSearch: () => _openSearch(),
        onShelf: () => _selectTab(2),
        onMine: () => _selectTab(3),
        onMiniOpen: latest == null ? null : () => _openPlayback(latest),
        onMiniPlay: latest == null
            ? null
            : () async {
                try {
                  await PlaybackController.instance.playRecord(latest);
                  await _loadLatestPlayback();
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('播放失败：$error')));
                }
              },
        miniProgress: latest?.progress.clamp(0, 1) ?? 0,
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<HomeData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _StateView(
            title: '首页加载失败',
            message: '${snapshot.error}',
            onRetry: _reload,
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return _StateView(title: '暂无内容', onRetry: _reload);
        }

        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildBanner(data.banners)),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '为你推荐',
                  color: const Color(0xFF2E9AF2),
                  onTap: _onRecommendTitleTap,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildRecommendRail(data.recommendBooks),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '编辑精选',
                  color: const Color(0xFFFF9D2E),
                  trailing: '查看全部',
                ),
              ),
              SliverToBoxAdapter(child: _buildEditorPick(data.recommendBooks)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9AF2),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E9AF2).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.headphones_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '有声听书',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Spacer(),
          IconButton.filledTonal(
            tooltip: '搜索',
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: '检查更新',
            onPressed: _checkingUpdate
                ? null
                : () => _checkForUpdate(silentWhenLatest: false),
            icon: _checkingUpdate
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(List<HomeBanner> banners) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    final item = banners.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openBook(item.bookId, item.title),
        child: AspectRatio(
          aspectRatio: 1.9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NetworkImage(url: item.imageUrl, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9D2E),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            '热门推荐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final selected = index == 0;
          return ChoiceChip(
            selected: selected,
            label: Text(_categories[index]),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF59606A),
              fontWeight: FontWeight.w800,
            ),
            selectedColor: const Color(0xFF2E9AF2),
            backgroundColor: const Color(0xFFF7F8FA),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (_) => _openSearch(
              _categories[index] == '全部' ? '' : _categories[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendRail(List<HomeRecommendBook> books) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 300,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        scrollDirection: Axis.horizontal,
        itemCount: books.take(8).length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: 128,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openBook(book.bookId, book.title),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _NetworkImage(
                              url: book.coverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF2E9AF2),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _MetaLine(icon: Icons.person_outline, text: book.author),
                  const SizedBox(height: 4),
                  _MetaLine(
                    icon: Icons.headphones_outlined,
                    text: book.category,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorPick(List<HomeRecommendBook> books) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }
    final book = books.length > 1 ? books[1] : books.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openBook(book.bookId, book.title),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECEEF2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: _NetworkImage(url: book.coverUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '本周热盘',
                      style: TextStyle(
                        color: Color(0xFFFF8A00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.summary.isEmpty ? book.category : book.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF59606A),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() {
    setState(() {
      _future = _api.fetchHome();
    });
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
    _loadLatestPlayback();
  }

  void _openSearch([String query = '']) {
    setState(() {
      _selectedIndex = 1;
      _searchQuery = query;
      _searchPageVersion++;
    });
    _loadLatestPlayback();
  }

  void _openBook(String bookId, String title) {
    if (bookId.isEmpty) {
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BookDetailPage(bookId: bookId, initialTitle: title),
          ),
        )
        .then((_) {
          _loadLatestPlayback();
        });
  }

  Future<void> _loadLatestPlayback() async {
    final latest = await _library.latestPlayback();
    if (mounted) {
      setState(() => _latestPlayback = latest);
    }
  }

  void _openPlayback(PlaybackRecord record, {bool autoPlay = false}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PlayerPage(
              featureKey: record.featureKey,
              title: record.title,
              autoPlay: autoPlay,
            ),
          ),
        )
        .then((_) => _loadLatestPlayback());
  }

  String _progressText(PlaybackRecord record) {
    final progress = (record.progress.clamp(0, 1) * 100).round();
    return progress <= 0 ? '未播放' : '$progress%';
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
              decoration: const InputDecoration(hintText: '在这里粘贴从网页复制的 Cookie'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                await ApiClient().setCookie(_cookieController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkForUpdate({required bool silentWhenLatest}) async {
    if (_checkingUpdate || (silentWhenLatest && _autoUpdateChecked)) {
      return;
    }

    setState(() => _checkingUpdate = true);
    try {
      final update = await _updateService.checkForUpdate();
      _autoUpdateChecked = true;
      if (!mounted) {
        return;
      }
      if (update == null) {
        if (!silentWhenLatest) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('当前已是最新版本')));
        }
        return;
      }
      await _showUpdateDialog(update);
    } catch (error) {
      if (!mounted || silentWhenLatest) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('检查更新失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _checkingUpdate = false);
      }
    }
  }

  Future<void> _showUpdateDialog(UpdateInfo update) async {
    final notes = update.body
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^[-*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(4)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2328),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.system_update_alt,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '发现新版本',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _Pill(text: update.tagName),
                    _Pill(text: update.apkName.isEmpty ? '' : update.apkName),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFECEEF2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _DialogTitle(
                        icon: Icons.info_outline,
                        text: '更新日志',
                      ),
                      const SizedBox(height: 12),
                      for (final note
                          in notes.isEmpty ? const ['优化播放器体验。'] : notes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF2E9AF2),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  note,
                                  style: const TextStyle(height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadAndInstall(update);
                  },
                  icon: const Icon(Icons.arrow_circle_up_outlined),
                  label: const Text('立即更新'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('以后再说'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAndInstall(UpdateInfo update) async {
    var progress = 0.0;
    var installing = false;
    var downloadStarted = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> startDownload() async {
              try {
                final apkPath = await _updateService.downloadApk(
                  update,
                  onReceiveProgress: (received, total) {
                    if (total <= 0) {
                      return;
                    }
                    setDialogState(() => progress = received / total);
                  },
                );
                setDialogState(() => installing = true);
                await _updateService.installApk(apkPath);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (error) {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text('下载或安装失败：$error')));
                }
              }
            }

            if (!downloadStarted) {
              downloadStarted = true;
              Future.microtask(startDownload);
            }

            final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
            return AlertDialog(
              title: const Text('正在下载更新'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress == 0 ? null : progress,
                  ),
                  const SizedBox(height: 12),
                  Text(installing ? '正在打开安装界面...' : '$percent%'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.color,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Color color;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                '$trailing  ›',
                style: const TextStyle(
                  color: Color(0xFF59606A),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({
    required this.activeIndex,
    required this.miniTitle,
    required this.miniSubtitle,
    required this.miniCoverUrl,
    required this.miniProgress,
    required this.onHome,
    required this.onSearch,
    required this.onShelf,
    required this.onMine,
    required this.onMiniOpen,
    required this.onMiniPlay,
  });

  final int activeIndex;
  final String miniTitle;
  final String miniSubtitle;
  final String miniCoverUrl;
  final double miniProgress;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onShelf;
  final VoidCallback onMine;
  final VoidCallback? onMiniOpen;
  final VoidCallback? onMiniPlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            border: const Border(top: BorderSide(color: Color(0xFFECEEF2))),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (miniTitle.isNotEmpty)
                  LinearProgressIndicator(
                    value: miniProgress <= 0 ? null : miniProgress,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFEAF4FF),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (miniTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onMiniOpen,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 42,
                                height: 42,
                                child: _NetworkImage(
                                  url: miniCoverUrl,
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
                                    miniTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    miniSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF59606A),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filled(
                              onPressed: onMiniPlay,
                              icon: const Icon(Icons.play_arrow),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavButton(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: '首页',
                      active: activeIndex == 0,
                      onTap: onHome,
                    ),
                    _NavButton(
                      icon: Icons.search,
                      label: '搜索',
                      active: activeIndex == 1,
                      onTap: onSearch,
                    ),
                    _NavButton(
                      icon: Icons.library_books_outlined,
                      activeIcon: Icons.library_books,
                      label: '书架',
                      active: activeIndex == 2,
                      onTap: onShelf,
                    ),
                    _NavButton(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: '我的',
                      active: activeIndex == 3,
                      onTap: onMine,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.activeIcon,
    this.active = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF59606A);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? (activeIcon ?? icon) : icon,
                color: color,
                size: 28,
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookshelfPage extends StatefulWidget {
  const _BookshelfPage({required this.onOpenBook});

  final void Function(String bookId, String title) onOpenBook;

  @override
  State<_BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<_BookshelfPage> {
  final LocalLibrary _library = LocalLibrary();
  late Future<List<LocalBook>> _future = _library.bookshelf();

  Future<void> _reload() async {
    setState(() => _future = _library.bookshelf());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LocalBook>>(
      future: _future,
      builder: (context, snapshot) {
        final books = snapshot.data ?? const <LocalBook>[];
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 130),
            children: [
              const Text(
                '书架',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (books.isEmpty)
                _StateView(
                  title: '书架为空',
                  message: '在书籍详情页点击“加入书架”后会显示在这里',
                  onRetry: _reload,
                )
              else
                for (final book in books)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BookshelfCard(
                      book: book,
                      onTap: () => widget.onOpenBook(book.bookId, book.title),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _BookshelfCard extends StatelessWidget {
  const _BookshelfCard({required this.book, required this.onTap});

  final LocalBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (book.author.isNotEmpty) book.author,
      if (book.announcer.isNotEmpty) book.announcer,
      if (book.category.isNotEmpty) book.category,
    ].join(' · ');
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECEEF2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 58,
                height: 76,
                child: _NetworkImage(url: book.coverUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.isEmpty ? '本地收藏' : meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF59606A)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA4B2)),
          ],
        ),
      ),
    );
  }
}

class _MinePage extends StatefulWidget {
  const _MinePage({required this.onCheckUpdate, required this.onOpenPlayback});

  final VoidCallback onCheckUpdate;
  final void Function(PlaybackRecord record) onOpenPlayback;

  @override
  State<_MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<_MinePage> {
  final LocalLibrary _library = LocalLibrary();
  late Future<
    ({List<PlaybackRecord> records, List<DownloadCacheRecord> caches})
  >
  _future = _load();

  Future<({List<PlaybackRecord> records, List<DownloadCacheRecord> caches})>
  _load() async {
    final records = await _library.playbackHistory();
    final caches = await _library.downloadCaches();
    return (records: records, caches: caches);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({List<PlaybackRecord> records, List<DownloadCacheRecord> caches})
    >(
      future: _future,
      builder: (context, snapshot) {
        final data =
            snapshot.data ??
            (
              records: const <PlaybackRecord>[],
              caches: const <DownloadCacheRecord>[],
            );
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 130),
            children: [
              const Text(
                '我的',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.system_update_alt),
                title: const Text('检查更新'),
                subtitle: const Text('从 GitHub Releases 获取最新安装包'),
                onTap: widget.onCheckUpdate,
              ),
              const Divider(height: 24),
              _MineSectionTitle(
                icon: Icons.download_done_outlined,
                title: '下载缓存',
                trailing: data.caches.isEmpty
                    ? '暂无'
                    : '${data.caches.length} 个章节',
              ),
              const SizedBox(height: 10),
              if (data.caches.isEmpty)
                const Text('暂无缓存章节', style: TextStyle(color: Color(0xFF59606A)))
              else
                for (final cache in data.caches.take(8))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      cache.isReady
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                    ),
                    title: Text(cache.title),
                    subtitle: Text(
                      [
                        if (cache.bookName.isNotEmpty) cache.bookName,
                        if (cache.isReady)
                          _formatBytes(cache.bytes)
                        else
                          cache.status,
                      ].join(' · '),
                    ),
                  ),
              const SizedBox(height: 18),
              _MineSectionTitle(
                icon: Icons.history,
                title: '播放历史',
                trailing: data.records.isEmpty
                    ? '暂无'
                    : '${data.records.length} 条',
              ),
              const SizedBox(height: 10),
              if (data.records.isEmpty)
                const Text('暂无播放历史', style: TextStyle(color: Color(0xFF59606A)))
              else
                for (final record in data.records)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history),
                    title: Text(
                      record.bookName.isEmpty ? record.title : record.bookName,
                    ),
                    subtitle: Text(
                      '${record.title} · ${_progressText(record)}',
                    ),
                    onTap: () => widget.onOpenPlayback(record),
                  ),
            ],
          ),
        );
      },
    );
  }

  String _progressText(PlaybackRecord record) {
    final progress = (record.progress.clamp(0, 1) * 100).round();
    return progress <= 0 ? '未播放' : '$progress%';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 KB';
    }
    final mb = bytes / 1024 / 1024;
    if (mb >= 1) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).round()} KB';
  }
}

class _MineSectionTitle extends StatelessWidget {
  const _MineSectionTitle({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E9AF2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        Text(trailing, style: const TextStyle(color: Color(0xFF59606A))),
      ],
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox(height: 16);
    }
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF59606A)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF59606A), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2E9AF2),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E9AF2), size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.title, this.message, required this.onRetry});

  final String title;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF59606A)),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
