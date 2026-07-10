import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/core/logger/file_logger.dart';
import 'package:audio_book/core/storage/local_library.dart';
import 'package:audio_book/features/player/player_api.dart';

class PlaybackController {
  PlaybackController._() {
    player.positionStream.listen((_) {
      _savePlaybackThrottled();
    });
  }

  static final PlaybackController instance = PlaybackController._();

  final AudioPlayer player = AudioPlayer();
  final PlayerApi _api = PlayerApi();
  final LocalLibrary _library = LocalLibrary();

  PlayerInfo? _info;
  String _title = '';
  DateTime? _lastProgressSaveAt;

  Future<PlayerInfo> loadFeature({
    required String featureKey,
    required String fallbackTitle,
    bool autoPlay = false,
    double speed = 1,
  }) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    final info = await _api.fetchPlayInfo(featureKey);
    FileLogger().logPlayHtml(featureKey: featureKey, html: info.rawHtml);

    final title = _displayTitle(info, fallbackTitle);
    final cache = await _library.downloadCache(info.featureKey);
    final cachedFile = cache?.isReady == true ? File(cache!.filePath) : null;
    final audioUri = cachedFile != null && await cachedFile.exists()
        ? Uri.file(cachedFile.path)
        : Uri.parse(info.audioUrl);

    await player.setAudioSource(
      AudioSource.uri(
        audioUri,
        tag: MediaItem(
          id: info.featureKey,
          title: title,
          album: info.bookName.isEmpty ? null : info.bookName,
          artUri: info.coverUrl.isEmpty ? null : Uri.tryParse(info.coverUrl),
        ),
      ),
    );
    await player.setSpeed(speed);

    final progress = await _library.chapterProgress(info.featureKey);
    if (progress != null &&
        !progress.isPlayed &&
        progress.position > Duration.zero &&
        progress.position < (progress.duration - const Duration(seconds: 3))) {
      await player.seek(progress.position);
    }

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
}
