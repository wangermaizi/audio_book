import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class SearchHistoryWords extends Table {
  TextColumn get word => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}

class BookshelfEntries extends Table {
  TextColumn get bookId => text()();
  TextColumn get title => text()();
  TextColumn get coverUrl => text()();
  TextColumn get author => text()();
  TextColumn get announcer => text()();
  TextColumn get category => text()();
  TextColumn get link => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {bookId};
}

class PlaybackHistoryEntries extends Table {
  TextColumn get featureKey => text()();
  TextColumn get bookName => text()();
  TextColumn get title => text()();
  TextColumn get coverUrl => text()();
  IntColumn get positionMs => integer()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {featureKey};
}

class ChapterProgressEntries extends Table {
  TextColumn get featureKey => text()();
  TextColumn get title => text()();
  IntColumn get positionMs => integer()();
  IntColumn get durationMs => integer()();
  BoolColumn get isPlayed => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {featureKey};
}

class DownloadCacheEntries extends Table {
  TextColumn get featureKey => text()();
  TextColumn get title => text()();
  TextColumn get bookName => text()();
  TextColumn get coverUrl => text()();
  TextColumn get filePath => text()();
  TextColumn get status => text()();
  IntColumn get bytes => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {featureKey};
}

class CookieEntries extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class AppSettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    SearchHistoryWords,
    BookshelfEntries,
    PlaybackHistoryEntries,
    ChapterProgressEntries,
    DownloadCacheEntries,
    CookieEntries,
    AppSettingEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(chapterProgressEntries);
          await migrator.createTable(downloadCacheEntries);
          await migrator.createTable(cookieEntries);
        }
        if (from < 3) {
          await migrator.createTable(appSettingEntries);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'audio_book',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
