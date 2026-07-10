import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/core/logger/file_logger.dart';
import 'package:audio_book/core/network/api_client.dart';
import 'package:audio_book/core/network/site_config.dart';
import 'package:audio_book/core/storage/local_library.dart';
import 'package:audio_book/features/book_detail/book_detail_models.dart';
import 'package:audio_book/features/player/player_api.dart';

class PlaybackController {
  PlaybackController._() {
    player.positionStream.listen((_) {
      _savePlaybackThrottled();
    });
    player.currentIndexStream.listen(_syncCurrentMediaItem);
  }

  static final PlaybackController instance = PlaybackController._();

  final AudioPlayer player = AudioPlayer();
  final PlayerApi _api = PlayerApi();
  final ApiClient _client = ApiClient();
  final LocalLibrary _library = LocalLibrary();

  PlayerInfo? _info;
  String _title = '';
  List<PlayerInfo> _sequenceInfos = const <PlayerInfo>[];
  List<String> _sequenceTitles = const <String>[];
  DateTime? _lastProgressSaveAt;

  PlayerInfo? get currentInfo => _info;

  String get currentTitle => _title;

  String? get currentFeatureKey => _info?.featureKey;

  Future<PlayerInfo> loadFeature({
    required String featureKey,
    required String fallbackTitle,
    bool autoPlay = false,
    double speed = 1,
    List<BookEpisode> episodes = const <BookEpisode>[],
    int currentIndex = 0,
  }) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    final playlist = await _buildPlaybackWindow(
      featureKey: featureKey,
      fallbackTitle: fallbackTitle,
      episodes: episodes,
      currentIndex: currentIndex,
    );
    final info = playlist.info;
    final title = playlist.title;
    final progress = await _library.chapterProgress(info.featureKey);
    final initialPosition = _resumePosition(progress);

    await player.setAudioSources(
      playlist.sources,
      initialIndex: playlist.initialIndex,
      initialPosition: initialPosition,
    );
    await player.setSpeed(speed);

    syncFromPage(info: info, title: title);
    await savePlayback();

    if (autoPlay) {
      await player.play();
    }

    return info;
  }

  Future<void> playRecord(PlaybackRecord record) async {
    await loadFeature(
      featureKey: record.featureKey,
      fallbackTitle: record.title,
      autoPlay: true,
    );
  }

  void syncFromPage({required PlayerInfo info, required String title}) {
    _info = info;
    _title = title;
  }

  Future<_PlaybackWindow> _buildPlaybackWindow({
    required String featureKey,
    required String fallbackTitle,
    required List<BookEpisode> episodes,
    required int currentIndex,
  }) async {
    if (episodes.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= episodes.length) {
      final info = await _fetchPlayInfo(featureKey);
      final title = _displayTitle(info, fallbackTitle);
      final source = await _audioSourceFor(info, title);
      _sequenceInfos = [info];
      _sequenceTitles = [title];
      return _PlaybackWindow(
        info: info,
        title: title,
        sources: [source],
        initialIndex: 0,
      );
    }

    final windowIndexes = <int>{
      if (currentIndex > 0) currentIndex - 1,
      currentIndex,
      if (currentIndex < episodes.length - 1) currentIndex + 1,
    }.toList()..sort();

    final sources = <AudioSource>[];
    final infos = <PlayerInfo>[];
    final titles = <String>[];
    var initialIndex = 0;
    PlayerInfo? selectedInfo;
    String selectedTitle = fallbackTitle;

    for (final index in windowIndexes) {
      final episode = episodes[index];
      final key = _extractFeatureKey(episode.playUrl);
      if (key.isEmpty) {
        continue;
      }
      try {
        final info = await _fetchPlayInfo(key);
        final title = _displayTitle(info, episode.title);
        if (index == currentIndex) {
          initialIndex = sources.length;
          selectedInfo = info;
          selectedTitle = title;
        }
        sources.add(await _audioSourceFor(info, title));
        infos.add(info);
        titles.add(title);
      } catch (_) {
        if (index == currentIndex) {
          rethrow;
        }
      }
    }

    if (selectedInfo == null || sources.isEmpty) {
      final info = await _fetchPlayInfo(featureKey);
      final title = _displayTitle(info, fallbackTitle);
      final source = await _audioSourceFor(info, title);
      _sequenceInfos = [info];
      _sequenceTitles = [title];
      return _PlaybackWindow(
        info: info,
        title: title,
        sources: [source],
        initialIndex: 0,
      );
    }

    _sequenceInfos = infos;
    _sequenceTitles = titles;
    return _PlaybackWindow(
      info: selectedInfo,
      title: selectedTitle,
      sources: sources,
      initialIndex: initialIndex,
    );
  }

  Future<PlayerInfo> _fetchPlayInfo(String featureKey) async {
    final info = await _api.fetchPlayInfo(featureKey);
    FileLogger().logPlayHtml(featureKey: featureKey, html: info.rawHtml);
    return info;
  }

  Future<AudioSource> _audioSourceFor(PlayerInfo info, String title) async {
    final cache = await _library.downloadCache(info.featureKey);
    final cachedFile = cache?.isReady == true ? File(cache!.filePath) : null;
    final hasCachedFile = cachedFile != null && await cachedFile.exists();
    final audioUri = hasCachedFile
        ? Uri.file(cachedFile.path)
        : Uri.parse(info.audioUrl);
    return AudioSource.uri(
      audioUri,
      headers: hasCachedFile ? null : _audioRequestHeaders(info),
      tag: MediaItem(
        id: info.featureKey,
        title: title,
        album: info.bookName.isEmpty ? null : info.bookName,
        artUri: info.coverUrl.isEmpty ? null : Uri.tryParse(info.coverUrl),
      ),
    );
  }

  Map<String, String> _audioRequestHeaders(PlayerInfo info) {
    final headers = <String, String>{
      'User-Agent': SiteConfig.mobileHeaders['User-Agent']!,
      'Accept': '*/*',
      'Accept-Language': SiteConfig.mobileHeaders['Accept-Language']!,
      'Referer': '${SiteConfig.baseUrl}/play/${info.featureKey}.html',
      'Origin': SiteConfig.baseUrl,
    };
    final cookie = _client.cookie;
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    return headers;
  }

  Duration _resumePosition(ChapterProgress? progress) {
    if (progress != null &&
        !progress.isPlayed &&
        progress.position > Duration.zero &&
        progress.position < (progress.duration - const Duration(seconds: 3))) {
      return progress.position;
    }
    return Duration.zero;
  }

  void _syncCurrentMediaItem(int? index) {
    if (index == null || index < 0 || index >= _sequenceInfos.length) {
      return;
    }
    _info = _sequenceInfos[index];
    _title = index < _sequenceTitles.length
        ? _sequenceTitles[index]
        : _displayTitle(_info!, '');
    savePlayback();
  }

  Future<void> savePlayback() async {
    final info = _info;
    if (info == null) {
      return;
    }
    await _library.savePlayback(
      PlaybackRecord(
        featureKey: info.featureKey,
        bookName: info.bookName,
        title: _title.isEmpty ? _displayTitle(info, '') : _title,
        coverUrl: info.coverUrl,
        position: player.position,
        duration: player.duration ?? Duration.zero,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _savePlaybackThrottled() async {
    final now = DateTime.now();
    if (_lastProgressSaveAt != null &&
        now.difference(_lastProgressSaveAt!) < const Duration(seconds: 8)) {
      return;
    }
    _lastProgressSaveAt = now;
    await savePlayback();
  }

  String _displayTitle(PlayerInfo info, String fallbackTitle) {
    final apiTitle = info.title.trim();
    if (apiTitle.isNotEmpty) {
      return apiTitle;
    }
    final fallback = fallbackTitle.trim();
    if (fallback.isNotEmpty &&
        !RegExp(r'^-?\d+(?:[-_]\d+)*$').hasMatch(fallback)) {
      return fallback;
    }
    return '正在播放';
  }

  String _extractFeatureKey(String playUrl) {
    final reg = RegExp(r'/play/([^/]+)\.html|/ting/([^/]+)\.html');
    final match = reg.firstMatch(playUrl);
    return match == null ? '' : (match.group(1) ?? match.group(2) ?? '');
  }
}

class _PlaybackWindow {
  const _PlaybackWindow({
    required this.info,
    required this.title,
    required this.sources,
    required this.initialIndex,
  });

  final PlayerInfo info;
  final String title;
  final List<AudioSource> sources;
  final int initialIndex;
}
