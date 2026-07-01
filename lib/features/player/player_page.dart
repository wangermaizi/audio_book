import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/core/logger/file_logger.dart';
import 'package:audio_book/features/book_detail/book_detail_api.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';
import 'package:audio_book/features/player/player_api.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
    required this.featureKey,
    required this.title,
    this.episodes = const <BookEpisode>[],
    this.directoryPageLinks = const <DirectoryPageLink>[],
    this.loadedDirectoryPages = const <int>{},
    this.initialIndex = 0,
  });

  final String featureKey;
  final String title;
  final List<BookEpisode> episodes;
  final List<DirectoryPageLink> directoryPageLinks;
  final Set<int> loadedDirectoryPages;
  final int initialIndex;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late Future<PlayerInfo> _future;
  late final AudioPlayer _player;
  final PlayerApi _api = PlayerApi();
  final BookDetailApi _bookDetailApi = BookDetailApi();

  PlayerInfo? _info;
  double _speed = 1;
  bool _audioReady = false;
  bool _playAfterLoad = false;
  bool _loadingEpisodes = false;
  String? _loginSheetShownForFeatureKey;
  String? _playerError;
  late int _currentIndex;
  late String _currentFeatureKey;
  late String _currentTitle;
  late final List<BookEpisode> _episodes;
  late final Set<int> _loadedDirectoryPages;
  late List<DirectoryPageLink> _directoryPageLinks;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _episodes = List<BookEpisode>.of(widget.episodes);
    _directoryPageLinks = List<DirectoryPageLink>.of(widget.directoryPageLinks)
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    _loadedDirectoryPages = widget.loadedDirectoryPages.isEmpty
        ? <int>{if (_episodes.isNotEmpty) 1}
        : Set<int>.of(widget.loadedDirectoryPages);
    _currentIndex = _normalizedInitialIndex();
    if (_episodes.isEmpty) {
      _currentFeatureKey = widget.featureKey;
      _currentTitle = widget.title;
    } else {
      final episode = _episodes[_currentIndex];
      _currentFeatureKey = _extractFeatureKey(episode.playUrl);
      _currentTitle = episode.title;
    }
    _future = _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<PlayerInfo> _load() async {
    setState(() {
      _audioReady = false;
      _playerError = null;
    });

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    final info = await _api.fetchPlayInfo(_currentFeatureKey);
    FileLogger().logPlayHtml(
      featureKey: _currentFeatureKey,
      html: info.rawHtml,
    );

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(info.audioUrl),
        tag: MediaItem(
          id: info.featureKey,
          title: _displayTitle(info),
          album: info.bookName.isEmpty ? null : info.bookName,
          artUri: info.coverUrl.isEmpty ? null : Uri.tryParse(info.coverUrl),
        ),
      ),
    );
    await _player.setSpeed(_speed);

    if (mounted) {
      setState(() {
        _info = info;
        _audioReady = true;
      });
    }

    if (_playAfterLoad) {
      _playAfterLoad = false;
      await _player.play();
    }

    return info;
  }

  Future<void> _retry() async {
    await _player.stop();
    setState(() {
      _info = null;
      _audioReady = false;
      _playerError = null;
      _future = _load();
    });
  }

  Future<void> _showLoginSheet() async {
    if (!mounted) {
      return;
    }
    final loggedIn = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _LoginSheet(api: _api),
    );
    if (loggedIn == true) {
      await _retry();
    }
  }

  Future<void> _togglePlay() async {
    if (!_audioReady) {
      return;
    }
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } on PlayerException catch (error) {
      setState(() => _playerError = error.message);
    } on PlayerInterruptedException catch (error) {
      setState(() => _playerError = error.message);
    }
  }

  Future<void> _changeSpeed(double speed) async {
    setState(() => _speed = speed);
    await _player.setSpeed(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_pageTitle())),
      body: FutureBuilder<PlayerInfo>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            if (snapshot.error is LoginRequiredException &&
                _loginSheetShownForFeatureKey != _currentFeatureKey) {
              _loginSheetShownForFeatureKey = _currentFeatureKey;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showLoginSheet();
                }
              });
            }
            return _ErrorView(
              error: snapshot.error,
              onRetry: _retry,
              onLogin: snapshot.error is LoginRequiredException
                  ? _showLoginSheet
                  : null,
            );
          }

          final info = snapshot.data ?? _info;
          if (info == null) {
            return _ErrorView(error: '没有播放数据', onRetry: _retry);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildNowPlaying(context, info),
              const SizedBox(height: 22),
              _buildControls(context),
              if (_episodes.isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildPlaylist(context),
              ],
              if (_playerError != null) ...[
                const SizedBox(height: 14),
                Text(
                  _playerError!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context, PlayerInfo info) {
    final title = _displayTitle(info);
    final bookName = info.bookName.isEmpty ? '' : info.bookName;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: info.coverUrl.isEmpty
                  ? const Icon(Icons.graphic_eq, size: 96)
                  : Image.network(info.coverUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (bookName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            bookName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          children: [
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              initialData: Duration.zero,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  initialData: _player.duration,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final max = duration.inMilliseconds.toDouble();
                    final value = position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble();

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 5,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max: max <= 0 ? 1 : max,
                            value: max <= 0 ? 0 : value,
                            onChanged: max <= 0
                                ? null
                                : (next) {
                                    _player.seek(
                                      Duration(milliseconds: next.round()),
                                    );
                                  },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundControlButton(
                  tooltip: '上一集',
                  icon: Icons.skip_previous,
                  onPressed: _canPlayPrevious ? _playPrevious : null,
                ),
                const SizedBox(width: 24),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  initialData: _player.playerState,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final processing =
                        state?.processingState ?? ProcessingState.idle;
                    final buffering =
                        processing == ProcessingState.loading ||
                        processing == ProcessingState.buffering;
                    final completed = processing == ProcessingState.completed;

                    if (buffering) {
                      return const SizedBox.square(
                        dimension: 72,
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      );
                    }

                    return FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: const Size.square(72),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _audioReady
                          ? () async {
                              if (completed) {
                                await _player.seek(Duration.zero);
                              }
                              await _togglePlay();
                            }
                          : null,
                      child: Icon(
                        _player.playing && !completed
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 40,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                _RoundControlButton(
                  tooltip: '下一集',
                  icon: Icons.skip_next,
                  onPressed: _canPlayNext ? _playNext : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _audioReady
                      ? () => _seekRelative(const Duration(seconds: -15))
                      : null,
                  icon: const Icon(Icons.replay_10),
                  label: const Text('后退 15 秒'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _audioReady
                      ? () => _seekRelative(const Duration(seconds: 15))
                      : null,
                  icon: const Icon(Icons.forward_10),
                  label: const Text('前进 15 秒'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final speed in const [0.75, 1.0, 1.25, 1.5, 2.0])
                  ChoiceChip(
                    label: Text(_speedLabel(speed)),
                    selected: _speed == speed,
                    onSelected: _audioReady ? (_) => _changeSpeed(speed) : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.queue_music,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '播放列表',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentIndex + 1}/${_episodes.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (_directoryPageLinks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadingEpisodes
                        ? null
                        : _showDirectoryPagePicker,
                    icon: const Icon(Icons.view_list, size: 18),
                    label: const Text('选集范围'),
                  ),
                  const Spacer(),
                  if (_loadingEpisodes)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_nextDirectoryPageLink != null)
                    TextButton.icon(
                      onPressed: _loadNextDirectoryPage,
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: const Text('加载更多'),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _episodes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                final selected = index == _currentIndex;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: SizedBox(
                    width: 34,
                    child: selected
                        ? Icon(
                            Icons.volume_up,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                  ),
                  title: Text(
                    episode.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected
                        ? TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )
                        : null,
                  ),
                  onTap: selected ? null : () => _playEpisodeAt(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seekRelative(Duration offset) async {
    final duration = _player.duration ?? Duration.zero;
    final next = _player.position + offset;
    if (next <= Duration.zero) {
      await _player.seek(Duration.zero);
      return;
    }
    if (duration > Duration.zero && next >= duration) {
      await _player.seek(duration);
      return;
    }
    await _player.seek(next);
  }

  bool get _canPlayPrevious =>
      _episodes.isNotEmpty && _currentIndex > 0 && _audioReady;

  bool get _canPlayNext =>
      _episodes.isNotEmpty &&
      _currentIndex < _episodes.length - 1 &&
      _audioReady;

  Future<void> _playPrevious() async {
    if (!_canPlayPrevious) {
      return;
    }
    await _playEpisodeAt(_currentIndex - 1);
  }

  Future<void> _playNext() async {
    if (!_canPlayNext) {
      return;
    }
    await _playEpisodeAt(_currentIndex + 1);
  }

  Future<void> _playEpisodeAt(int index) async {
    if (index < 0 || index >= _episodes.length || index == _currentIndex) {
      return;
    }

    final episode = _episodes[index];
    await _player.stop();
    _playAfterLoad = true;
    setState(() {
      _currentIndex = index;
      _currentFeatureKey = _extractFeatureKey(episode.playUrl);
      _currentTitle = episode.title;
      _loginSheetShownForFeatureKey = null;
      _info = null;
      _audioReady = false;
      _playerError = null;
      _future = _load();
    });
  }

  int _normalizedInitialIndex() {
    if (_episodes.isEmpty) {
      return 0;
    }
    if (widget.initialIndex < 0) {
      return 0;
    }
    if (widget.initialIndex >= _episodes.length) {
      return _episodes.length - 1;
    }
    return widget.initialIndex;
  }

  Future<void> _loadNextDirectoryPage() async {
    final link = _nextDirectoryPageLink;
    if (link == null) {
      return;
    }
    await _loadDirectoryPage(link);
  }

  Future<void> _loadDirectoryPage(DirectoryPageLink link) async {
    if (_loadingEpisodes || _loadedDirectoryPages.contains(link.pageNumber)) {
      return;
    }

    setState(() => _loadingEpisodes = true);
    try {
      final currentPlayUrl = _currentEpisodePlayUrl;
      final data = await _bookDetailApi.fetchDirectoryPageData(link.url);
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
        _syncCurrentIndex(currentPlayUrl);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载章节失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _loadingEpisodes = false);
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

  String get _currentEpisodePlayUrl {
    if (_episodes.isEmpty ||
        _currentIndex < 0 ||
        _currentIndex >= _episodes.length) {
      return '';
    }
    return _episodes[_currentIndex].playUrl;
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

  void _syncCurrentIndex(String currentPlayUrl) {
    if (currentPlayUrl.isEmpty) {
      return;
    }
    final nextIndex = _episodes.indexWhere(
      (episode) => episode.playUrl == currentPlayUrl,
    );
    if (nextIndex >= 0) {
      _currentIndex = nextIndex;
    }
  }

  int _episodeNumber(BookEpisode episode) {
    final titleNumber = RegExp(r'\d+').firstMatch(episode.title)?.group(0);
    if (titleNumber != null) {
      return int.tryParse(titleNumber) ?? 0;
    }

    final urlNumber = RegExp(r'_(\d+)_').firstMatch(episode.playUrl)?.group(1);
    return int.tryParse(urlNumber ?? '') ?? 0;
  }

  String _pageTitle() {
    final title = _currentTitle.trim();
    if (title.isEmpty || RegExp(r'^-?\d+(?:[-_]\d+)*$').hasMatch(title)) {
      return '正在播放';
    }
    return title;
  }

  String _displayTitle(PlayerInfo info) {
    final apiTitle = info.title.trim();
    if (apiTitle.isNotEmpty) {
      return apiTitle;
    }
    return _pageTitle();
  }

  String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.round()}x';
    }
    return '${speed}x';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
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

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      iconSize: 28,
      style: IconButton.styleFrom(fixedSize: const Size.square(52)),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry, this.onLogin});

  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('加载播放信息失败'),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                if (onLogin != null)
                  FilledButton.icon(
                    onPressed: onLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('打开登录'),
                  ),
                OutlinedButton(onPressed: onRetry, child: const Text('重试')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet({required this.api});

  final PlayerApi api;

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _submitting = false;
  bool _sendingCode = false;
  bool _registerMode = false;
  String? _message;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _registerMode ? '邮箱注册' : '站点登录',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _submitting || _sendingCode
                      ? null
                      : () {
                          setState(() {
                            _registerMode = !_registerMode;
                            _message = null;
                          });
                        },
                  child: Text(_registerMode ? '去登录' : '去注册'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _registerMode ? '注册 13听书网 邮箱账号后会自动重试播放。' : '这一集需要登录 13听书网 后继续收听。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '账号或邮箱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),
            if (_registerMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '确认密码',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: '邮箱验证码',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _sendingCode || _submitting
                          ? null
                          : _sendRegisterCode,
                      child: _sendingCode
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('获取'),
                    ),
                  ),
                ],
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_registerMode ? '注册并重试' : '登录'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _message = _registerMode ? '请输入邮箱和密码' : '请输入账号和密码');
      return;
    }
    if (_registerMode) {
      final confirmPassword = _confirmPasswordController.text;
      final code = _codeController.text.trim();
      if (password != confirmPassword) {
        setState(() => _message = '两次输入的密码不一致');
        return;
      }
      if (code.isEmpty) {
        setState(() => _message = '请输入邮箱验证码');
        return;
      }
      await _register(username, password, code);
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });
    try {
      final result = await widget.api.login(
        username: username,
        password: password,
      );
      if (!mounted) {
        return;
      }
      if (result.success) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _message = result.message);
    } catch (error) {
      if (mounted) {
        setState(() => _message = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _sendRegisterCode() async {
    final email = _usernameController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = '请输入邮箱');
      return;
    }

    setState(() {
      _sendingCode = true;
      _message = null;
    });
    try {
      final result = await widget.api.sendRegisterCode(email: email);
      if (mounted) {
        setState(() => _message = result.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _sendingCode = false);
      }
    }
  }

  Future<void> _register(String email, String password, String code) async {
    setState(() {
      _submitting = true;
      _message = null;
    });
    try {
      final result = await widget.api.registerByEmail(
        email: email,
        password: password,
        code: code,
      );
      if (!mounted) {
        return;
      }
      if (result.success) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _message = result.message);
    } catch (error) {
      if (mounted) {
        setState(() => _message = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
