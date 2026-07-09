import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:audio_book/core/storage/local_library.dart';
import 'package:audio_book/features/book_detail/book_detail_page.dart';
import 'package:audio_book/features/home/home_api.dart';
import 'package:audio_book/features/search/search_api.dart';
import 'package:audio_book/features/search/search_models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.query = ''});

  final String query;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchApi _api = SearchApi();
  final HomeApi _homeApi = HomeApi();
  final LocalLibrary _library = LocalLibrary();
  late final TextEditingController _controller;
  Future<List<SearchResultItem>>? _future;
  String _query = '';
  List<String> _hotWords = const <String>[];
  List<String> _historyWords = const <String>[];

  @override
  void initState() {
    super.initState();
    _query = widget.query.trim();
    _controller = TextEditingController(text: _query);
    _loadDiscoveryWords();
    if (_query.isNotEmpty) {
      _future = _api.search(_query);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(
              child: _query.isEmpty ? _buildDiscovery() : _buildResults(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SearchBottomBar(
        onHome: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 18, 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '搜索',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: '历史记录',
            onPressed: () {},
            icon: const Icon(Icons.history, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: TextField(
        controller: _controller,
        autofocus: _query.isEmpty,
        textInputAction: TextInputAction.search,
        onSubmitted: _submit,
        decoration: InputDecoration(
          hintText: '搜索作品、作者、主播...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  tooltip: '清空',
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _query = '';
                      _future = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.mic_none, color: Color(0xFF2E9AF2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscovery() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 120),
      children: [
        _SearchSection(
          icon: Icons.trending_up,
          title: '热门搜索',
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _hotWords.length; i++)
                  ActionChip(
                    label: Text(
                      i < 3 ? '0${i + 1} ${_hotWords[i]}' : _hotWords[i],
                    ),
                    side: BorderSide.none,
                    backgroundColor: i < 3
                        ? const Color(0xFFEAF4FF)
                        : const Color(0xFFF7F8FA),
                    labelStyle: TextStyle(
                      color: i < 3
                          ? const Color(0xFF2E9AF2)
                          : const Color(0xFF59606A),
                      fontWeight: FontWeight.w800,
                    ),
                    onPressed: () => _submit(_hotWords[i]),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SearchSection(
          icon: Icons.schedule,
          title: '历史记录',
          trailing: IconButton(
            tooltip: '清空历史',
            onPressed: _historyWords.isEmpty ? null : _clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final word in _historyWords)
                  ActionChip(
                    label: Text(word),
                    side: const BorderSide(color: Color(0xFFE4E8EE)),
                    backgroundColor: Colors.white,
                    onPressed: () => _submit(word),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Divider(color: Color(0xFFECEEF2)),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                '搜索发现',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('换一换')),
          ],
        ),
        const SizedBox(height: 12),
        if (_hotWords.isEmpty)
          const Text(
            '站点推荐暂时没有解析到内容',
            style: TextStyle(color: Color(0xFF59606A)),
          )
        else
          Row(
            children: [
              Expanded(
                child: _DiscoveryCard(
                  title: _hotWords.first,
                  subtitle: '来自首页推荐',
                  onTap: () => _submit(_hotWords.first),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DiscoveryCard(
                  title: _hotWords.length > 1 ? _hotWords[1] : _hotWords.first,
                  subtitle: '来自首页推荐',
                  onTap: () => _submit(
                    _hotWords.length > 1 ? _hotWords[1] : _hotWords.first,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResults() {
    final future = _future;
    if (future == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<List<SearchResultItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _StateView(
            title: '搜索失败',
            message: '${snapshot.error}',
            onRetry: () => _submit(_query),
          );
        }

        final items = snapshot.data ?? const <SearchResultItem>[];
        if (items.isEmpty) {
          return _StateView(
            title: '没有找到相关有声小说',
            onRetry: () => _submit(_query),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) => _ResultCard(
            item: items[index],
            onTap: () {
              final bookId = _extractBookId(items[index].link);
              if (bookId.isEmpty) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(
                    bookId: bookId,
                    initialTitle: items[index].title,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      return;
    }
    _library.addSearchWord(query);
    _loadHistory();
    setState(() {
      _query = query;
      _controller.text = query;
      _future = _api.search(query);
    });
  }

  Future<void> _loadDiscoveryWords() async {
    await _loadHistory();
    try {
      final home = await _homeApi.fetchHome();
      final titles = <String>[];
      for (final book in home.recommendBooks) {
        if (book.title.isNotEmpty && !titles.contains(book.title)) {
          titles.add(book.title);
        }
        if (titles.length >= 8) {
          break;
        }
      }
      if (mounted) {
        setState(() => _hotWords = titles);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hotWords = const <String>[]);
      }
    }
  }

  Future<void> _loadHistory() async {
    final words = await _library.searchHistory();
    if (mounted) {
      setState(() => _historyWords = words);
    }
  }

  Future<void> _clearHistory() async {
    await _library.clearSearchHistory();
    if (mounted) {
      setState(() => _historyWords = const <String>[]);
    }
  }

  String _extractBookId(String link) {
    final reg = RegExp(r'/youshengxiaoshuo/(\d+)/|/book/(\d+)\.html');
    final match = reg.firstMatch(link);
    return match == null ? '' : (match.group(1) ?? match.group(2) ?? '');
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF2E9AF2)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFEAF4FF),
              child: Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF8A00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF59606A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item, required this.onTap});

  final SearchResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEEF2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 86,
                height: 112,
                child: _NetworkImage(url: item.coverUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.announcer.isNotEmpty)
                    _MetaLine(icon: Icons.person_outline, text: item.announcer),
                  if (item.category.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _MetaLine(
                      icon: Icons.category_outlined,
                      text: item.category,
                    ),
                  ],
                  if (item.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF59606A),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBottomBar extends StatelessWidget {
  const _SearchBottomBar({required this.onHome});

  final VoidCallback onHome;

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
            child: Row(
              children: [
                _NavButton(
                  icon: Icons.home_outlined,
                  label: '首页',
                  onTap: onHome,
                ),
                _NavButton(
                  icon: Icons.search,
                  label: '搜索',
                  active: true,
                  onTap: () {},
                ),
                _NavButton(
                  icon: Icons.playlist_play,
                  label: '播放',
                  onTap: () {},
                ),
                _NavButton(
                  icon: Icons.person_outline,
                  label: '我的',
                  onTap: () {},
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
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF59606A);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
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

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFF0F4F8),
        child: Icon(Icons.menu_book, color: Color(0xFF9AA4B2), size: 36),
      );
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFF0F4F8),
        child: Icon(Icons.menu_book, color: Color(0xFF9AA4B2), size: 36),
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
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF59606A)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF59606A)),
          ),
        ),
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
