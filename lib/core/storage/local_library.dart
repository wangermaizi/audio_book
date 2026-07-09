import 'package:drift/drift.dart';

import 'package:audio_book/core/storage/app_database.dart';

class LocalBook {
  const LocalBook({
    required this.bookId,
    required this.title,
    required this.coverUrl,
    required this.author,
    required this.announcer,
    required this.category,
    required this.link,
    required this.updatedAt,
  });

  final String bookId;
  final String title;
  final String coverUrl;
  final String author;
  final String announcer;
  final String category;
  final String link;
  final DateTime updatedAt;
}

class PlaybackRecord {
  const PlaybackRecord({
    required this.featureKey,
    required this.bookName,
    required this.title,
    required this.coverUrl,
    required this.position,
    required this.duration,
    required this.updatedAt,
  });

  final String featureKey;
  final String bookName;
  final String title;
  final String coverUrl;
  final Duration position;
  final Duration duration;
  final DateTime updatedAt;

  double get progress {
    if (duration.inMilliseconds <= 0) {
      return 0;
    }
    return position.inMilliseconds / duration.inMilliseconds;
  }
}

class ChapterProgress {
  const ChapterProgress({
    required this.featureKey,
    required this.title,
    required this.position,
    required this.duration,
    required this.isPlayed,
    required this.updatedAt,
  });

  final String featureKey;
  final String title;
  final Duration position;
  final Duration duration;
  final bool isPlayed;
  final DateTime updatedAt;

  double get progress {
    if (duration.inMilliseconds <= 0) {
      return 0;
    }
    return position.inMilliseconds / duration.inMilliseconds;
  }
}

class DownloadCacheRecord {
  const DownloadCacheRecord({
    required this.featureKey,
    required this.title,
    required this.bookName,
    required this.coverUrl,
    required this.filePath,
    required this.status,
    required this.bytes,
    required this.updatedAt,
  });

  final String featureKey;
  final String title;
  final String bookName;
  final String coverUrl;
  final String filePath;
  final String status;
  final int bytes;
  final DateTime updatedAt;

  bool get isReady => status == 'ready' && filePath.isNotEmpty;
}

class LocalLibrary {
  LocalLibrary({AppDatabase? database})
    : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<String>> searchHistory() async {
    final rows =
        await (_db.select(_db.searchHistoryWords)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(12))
            .get();
    return rows.map((row) => row.word).toList();
  }

  Future<void> addSearchWord(String word) async {
    final value = word.trim();
    if (value.isEmpty) {
      return;
    }
    await _db
        .into(_db.searchHistoryWords)
        .insertOnConflictUpdate(
          SearchHistoryWordsCompanion(
            word: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );

    final stale =
        await (_db.select(_db.searchHistoryWords)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(999, offset: 12))
            .get();
    for (final row in stale) {
      await (_db.delete(
        _db.searchHistoryWords,
      )..where((table) => table.word.equals(row.word))).go();
    }
  }

  Future<void> clearSearchHistory() {
    return _db.delete(_db.searchHistoryWords).go();
  }

  Future<List<LocalBook>> bookshelf() async {
    final rows = await (_db.select(
      _db.bookshelfEntries,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).get();
    return rows.map(_bookFromRow).toList();
  }

  Future<bool> isInBookshelf(String bookId) async {
    final row =
        await (_db.select(_db.bookshelfEntries)
              ..where((table) => table.bookId.equals(bookId))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> addBook(LocalBook book) {
    return _db
        .into(_db.bookshelfEntries)
        .insertOnConflictUpdate(
          BookshelfEntriesCompanion(
            bookId: Value(book.bookId),
            title: Value(book.title),
            coverUrl: Value(book.coverUrl),
            author: Value(book.author),
            announcer: Value(book.announcer),
            category: Value(book.category),
            link: Value(book.link),
            updatedAt: Value(book.updatedAt),
          ),
        );
  }

  Future<void> removeBook(String bookId) {
    return (_db.delete(
      _db.bookshelfEntries,
    )..where((table) => table.bookId.equals(bookId))).go();
  }

  Future<List<PlaybackRecord>> playbackHistory() async {
    final rows =
        await (_db.select(_db.playbackHistoryEntries)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(30))
            .get();
    return rows.map(_playbackFromRow).toList();
  }

  Future<PlaybackRecord?> latestPlayback() async {
    final row =
        await (_db.select(_db.playbackHistoryEntries)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _playbackFromRow(row);
  }

  Future<void> savePlayback(PlaybackRecord record) async {
    await _db
        .into(_db.playbackHistoryEntries)
        .insertOnConflictUpdate(
          PlaybackHistoryEntriesCompanion(
            featureKey: Value(record.featureKey),
            bookName: Value(record.bookName),
            title: Value(record.title),
            coverUrl: Value(record.coverUrl),
            positionMs: Value(record.position.inMilliseconds),
            durationMs: Value(record.duration.inMilliseconds),
            updatedAt: Value(record.updatedAt),
          ),
        );
    await saveChapterProgress(
      ChapterProgress(
        featureKey: record.featureKey,
        title: record.title,
        position: record.position,
        duration: record.duration,
        isPlayed: _isPlayed(record.position, record.duration),
        updatedAt: record.updatedAt,
      ),
    );

    final stale =
        await (_db.select(_db.playbackHistoryEntries)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(999, offset: 30))
            .get();
    for (final row in stale) {
      await (_db.delete(
        _db.playbackHistoryEntries,
      )..where((table) => table.featureKey.equals(row.featureKey))).go();
    }
  }

  Future<Map<String, ChapterProgress>> chapterProgressByFeatureKeys(
    Iterable<String> featureKeys,
  ) async {
    final keys = featureKeys.where((key) => key.isNotEmpty).toSet();
    if (keys.isEmpty) {
      return const <String, ChapterProgress>{};
    }
    final rows = await (_db.select(
      _db.chapterProgressEntries,
    )..where((table) => table.featureKey.isIn(keys))).get();
    return {
      for (final row in rows) row.featureKey: _chapterProgressFromRow(row),
    };
  }

  Future<ChapterProgress?> chapterProgress(String featureKey) async {
    final row =
        await (_db.select(_db.chapterProgressEntries)
              ..where((table) => table.featureKey.equals(featureKey))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _chapterProgressFromRow(row);
  }

  Future<void> saveChapterProgress(ChapterProgress progress) {
    return _db
        .into(_db.chapterProgressEntries)
        .insertOnConflictUpdate(
          ChapterProgressEntriesCompanion(
            featureKey: Value(progress.featureKey),
            title: Value(progress.title),
            positionMs: Value(progress.position.inMilliseconds),
            durationMs: Value(progress.duration.inMilliseconds),
            isPlayed: Value(progress.isPlayed),
            updatedAt: Value(progress.updatedAt),
          ),
        );
  }

  Future<Map<String, DownloadCacheRecord>> downloadCacheByFeatureKeys(
    Iterable<String> featureKeys,
  ) async {
    final keys = featureKeys.where((key) => key.isNotEmpty).toSet();
    if (keys.isEmpty) {
      return const <String, DownloadCacheRecord>{};
    }
    final rows = await (_db.select(
      _db.downloadCacheEntries,
    )..where((table) => table.featureKey.isIn(keys))).get();
    return {for (final row in rows) row.featureKey: _downloadCacheFromRow(row)};
  }

  Future<List<DownloadCacheRecord>> downloadCaches() async {
    final rows = await (_db.select(
      _db.downloadCacheEntries,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).get();
    return rows.map(_downloadCacheFromRow).toList();
  }

  Future<DownloadCacheRecord?> downloadCache(String featureKey) async {
    final row =
        await (_db.select(_db.downloadCacheEntries)
              ..where((table) => table.featureKey.equals(featureKey))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _downloadCacheFromRow(row);
  }

  Future<void> saveDownloadCache(DownloadCacheRecord record) {
    return _db
        .into(_db.downloadCacheEntries)
        .insertOnConflictUpdate(
          DownloadCacheEntriesCompanion(
            featureKey: Value(record.featureKey),
            title: Value(record.title),
            bookName: Value(record.bookName),
            coverUrl: Value(record.coverUrl),
            filePath: Value(record.filePath),
            status: Value(record.status),
            bytes: Value(record.bytes),
            updatedAt: Value(record.updatedAt),
          ),
        );
  }

  Future<Map<String, String>> cookies() async {
    final rows = await _db.select(_db.cookieEntries).get();
    return {for (final row in rows) row.name: row.value};
  }

  Future<void> replaceCookies(Map<String, String> cookies) async {
    await _db.transaction(() async {
      await _db.delete(_db.cookieEntries).go();
      for (final entry in cookies.entries) {
        await upsertCookie(entry.key, entry.value);
      }
    });
  }

  Future<void> upsertCookie(String name, String value) {
    return _db
        .into(_db.cookieEntries)
        .insertOnConflictUpdate(
          CookieEntriesCompanion(
            name: Value(name),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> removeCookie(String name) {
    return (_db.delete(
      _db.cookieEntries,
    )..where((table) => table.name.equals(name))).go();
  }

  LocalBook _bookFromRow(BookshelfEntry row) {
    return LocalBook(
      bookId: row.bookId,
      title: row.title,
      coverUrl: row.coverUrl,
      author: row.author,
      announcer: row.announcer,
      category: row.category,
      link: row.link,
      updatedAt: row.updatedAt,
    );
  }

  PlaybackRecord _playbackFromRow(PlaybackHistoryEntry row) {
    return PlaybackRecord(
      featureKey: row.featureKey,
      bookName: row.bookName,
      title: row.title,
      coverUrl: row.coverUrl,
      position: Duration(milliseconds: row.positionMs),
      duration: Duration(milliseconds: row.durationMs),
      updatedAt: row.updatedAt,
    );
  }

  ChapterProgress _chapterProgressFromRow(ChapterProgressEntry row) {
    return ChapterProgress(
      featureKey: row.featureKey,
      title: row.title,
      position: Duration(milliseconds: row.positionMs),
      duration: Duration(milliseconds: row.durationMs),
      isPlayed: row.isPlayed,
      updatedAt: row.updatedAt,
    );
  }

  DownloadCacheRecord _downloadCacheFromRow(DownloadCacheEntry row) {
    return DownloadCacheRecord(
      featureKey: row.featureKey,
      title: row.title,
      bookName: row.bookName,
      coverUrl: row.coverUrl,
      filePath: row.filePath,
      status: row.status,
      bytes: row.bytes,
      updatedAt: row.updatedAt,
    );
  }

  bool _isPlayed(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) {
      return false;
    }
    final remaining = duration - position;
    return remaining <= const Duration(seconds: 20) ||
        position.inMilliseconds / duration.inMilliseconds >= 0.95;
  }
}
