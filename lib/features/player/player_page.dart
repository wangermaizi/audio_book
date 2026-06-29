import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/core/logger/file_logger.dart';
import 'package:audio_book/features/player/player_api.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.featureKey, required this.title});

  final String featureKey;
  final String title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late Future<PlayerInfo> _future;
  late final AudioPlayer _player;
  final PlayerApi _api = PlayerApi();

  PlayerInfo? _info;
  double _speed = 1;
  bool _audioReady = false;
  String? _playerError;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
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

    final info = await _api.fetchPlayInfo(widget.featureKey);
    FileLogger().logPlayHtml(featureKey: widget.featureKey, html: info.rawHtml);

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
            return _ErrorView(error: snapshot.error, onRetry: _retry);
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
                  tooltip: '后退 15 秒',
                  icon: Icons.replay_10,
                  onPressed: _audioReady
                      ? () => _seekRelative(const Duration(seconds: -15))
                      : null,
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
                  tooltip: '前进 15 秒',
                  icon: Icons.forward_10,
                  onPressed: _audioReady
                      ? () => _seekRelative(const Duration(seconds: 15))
                      : null,
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

  String _pageTitle() {
    final title = widget.title.trim();
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
            ElevatedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
