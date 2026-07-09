// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SearchHistoryWordsTable extends SearchHistoryWords
    with TableInfo<$SearchHistoryWordsTable, SearchHistoryWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [word, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  SearchHistoryWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryWord(
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SearchHistoryWordsTable createAlias(String alias) {
    return $SearchHistoryWordsTable(attachedDatabase, alias);
  }
}

class SearchHistoryWord extends DataClass
    implements Insertable<SearchHistoryWord> {
  final String word;
  final DateTime updatedAt;
  const SearchHistoryWord({required this.word, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SearchHistoryWordsCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryWordsCompanion(
      word: Value(word),
      updatedAt: Value(updatedAt),
    );
  }

  factory SearchHistoryWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryWord(
      word: serializer.fromJson<String>(json['word']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SearchHistoryWord copyWith({String? word, DateTime? updatedAt}) =>
      SearchHistoryWord(
        word: word ?? this.word,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SearchHistoryWord copyWithCompanion(SearchHistoryWordsCompanion data) {
    return SearchHistoryWord(
      word: data.word.present ? data.word.value : this.word,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryWord(')
          ..write('word: $word, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryWord &&
          other.word == this.word &&
          other.updatedAt == this.updatedAt);
}

class SearchHistoryWordsCompanion extends UpdateCompanion<SearchHistoryWord> {
  final Value<String> word;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SearchHistoryWordsCompanion({
    this.word = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryWordsCompanion.insert({
    required String word,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : word = Value(word),
       updatedAt = Value(updatedAt);
  static Insertable<SearchHistoryWord> custom({
    Expression<String>? word,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryWordsCompanion copyWith({
    Value<String>? word,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SearchHistoryWordsCompanion(
      word: word ?? this.word,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryWordsCompanion(')
          ..write('word: $word, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookshelfEntriesTable extends BookshelfEntries
    with TableInfo<$BookshelfEntriesTable, BookshelfEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookshelfEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _announcerMeta = const VerificationMeta(
    'announcer',
  );
  @override
  late final GeneratedColumn<String> announcer = GeneratedColumn<String>(
    'announcer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    title,
    coverUrl,
    author,
    announcer,
    category,
    link,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookshelf_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookshelfEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('announcer')) {
      context.handle(
        _announcerMeta,
        announcer.isAcceptableOrUnknown(data['announcer']!, _announcerMeta),
      );
    } else if (isInserting) {
      context.missing(_announcerMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  BookshelfEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookshelfEntry(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      announcer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}announcer'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BookshelfEntriesTable createAlias(String alias) {
    return $BookshelfEntriesTable(attachedDatabase, alias);
  }
}

class BookshelfEntry extends DataClass implements Insertable<BookshelfEntry> {
  final String bookId;
  final String title;
  final String coverUrl;
  final String author;
  final String announcer;
  final String category;
  final String link;
  final DateTime updatedAt;
  const BookshelfEntry({
    required this.bookId,
    required this.title,
    required this.coverUrl,
    required this.author,
    required this.announcer,
    required this.category,
    required this.link,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['title'] = Variable<String>(title);
    map['cover_url'] = Variable<String>(coverUrl);
    map['author'] = Variable<String>(author);
    map['announcer'] = Variable<String>(announcer);
    map['category'] = Variable<String>(category);
    map['link'] = Variable<String>(link);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookshelfEntriesCompanion toCompanion(bool nullToAbsent) {
    return BookshelfEntriesCompanion(
      bookId: Value(bookId),
      title: Value(title),
      coverUrl: Value(coverUrl),
      author: Value(author),
      announcer: Value(announcer),
      category: Value(category),
      link: Value(link),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookshelfEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookshelfEntry(
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      author: serializer.fromJson<String>(json['author']),
      announcer: serializer.fromJson<String>(json['announcer']),
      category: serializer.fromJson<String>(json['category']),
      link: serializer.fromJson<String>(json['link']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'author': serializer.toJson<String>(author),
      'announcer': serializer.toJson<String>(announcer),
      'category': serializer.toJson<String>(category),
      'link': serializer.toJson<String>(link),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookshelfEntry copyWith({
    String? bookId,
    String? title,
    String? coverUrl,
    String? author,
    String? announcer,
    String? category,
    String? link,
    DateTime? updatedAt,
  }) => BookshelfEntry(
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    coverUrl: coverUrl ?? this.coverUrl,
    author: author ?? this.author,
    announcer: announcer ?? this.announcer,
    category: category ?? this.category,
    link: link ?? this.link,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookshelfEntry copyWithCompanion(BookshelfEntriesCompanion data) {
    return BookshelfEntry(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      author: data.author.present ? data.author.value : this.author,
      announcer: data.announcer.present ? data.announcer.value : this.announcer,
      category: data.category.present ? data.category.value : this.category,
      link: data.link.present ? data.link.value : this.link,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookshelfEntry(')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('announcer: $announcer, ')
          ..write('category: $category, ')
          ..write('link: $link, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookId,
    title,
    coverUrl,
    author,
    announcer,
    category,
    link,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookshelfEntry &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.author == this.author &&
          other.announcer == this.announcer &&
          other.category == this.category &&
          other.link == this.link &&
          other.updatedAt == this.updatedAt);
}

class BookshelfEntriesCompanion extends UpdateCompanion<BookshelfEntry> {
  final Value<String> bookId;
  final Value<String> title;
  final Value<String> coverUrl;
  final Value<String> author;
  final Value<String> announcer;
  final Value<String> category;
  final Value<String> link;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BookshelfEntriesCompanion({
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.announcer = const Value.absent(),
    this.category = const Value.absent(),
    this.link = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookshelfEntriesCompanion.insert({
    required String bookId,
    required String title,
    required String coverUrl,
    required String author,
    required String announcer,
    required String category,
    required String link,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       title = Value(title),
       coverUrl = Value(coverUrl),
       author = Value(author),
       announcer = Value(announcer),
       category = Value(category),
       link = Value(link),
       updatedAt = Value(updatedAt);
  static Insertable<BookshelfEntry> custom({
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<String>? author,
    Expression<String>? announcer,
    Expression<String>? category,
    Expression<String>? link,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (author != null) 'author': author,
      if (announcer != null) 'announcer': announcer,
      if (category != null) 'category': category,
      if (link != null) 'link': link,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookshelfEntriesCompanion copyWith({
    Value<String>? bookId,
    Value<String>? title,
    Value<String>? coverUrl,
    Value<String>? author,
    Value<String>? announcer,
    Value<String>? category,
    Value<String>? link,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BookshelfEntriesCompanion(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      announcer: announcer ?? this.announcer,
      category: category ?? this.category,
      link: link ?? this.link,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (announcer.present) {
      map['announcer'] = Variable<String>(announcer.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookshelfEntriesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('announcer: $announcer, ')
          ..write('category: $category, ')
          ..write('link: $link, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackHistoryEntriesTable extends PlaybackHistoryEntries
    with TableInfo<$PlaybackHistoryEntriesTable, PlaybackHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureKeyMeta = const VerificationMeta(
    'featureKey',
  );
  @override
  late final GeneratedColumn<String> featureKey = GeneratedColumn<String>(
    'feature_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    featureKey,
    bookName,
    title,
    coverUrl,
    positionMs,
    durationMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature_key')) {
      context.handle(
        _featureKeyMeta,
        featureKey.isAcceptableOrUnknown(data['feature_key']!, _featureKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_featureKeyMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {featureKey};
  @override
  PlaybackHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistoryEntry(
      featureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature_key'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackHistoryEntriesTable createAlias(String alias) {
    return $PlaybackHistoryEntriesTable(attachedDatabase, alias);
  }
}

class PlaybackHistoryEntry extends DataClass
    implements Insertable<PlaybackHistoryEntry> {
  final String featureKey;
  final String bookName;
  final String title;
  final String coverUrl;
  final int positionMs;
  final int durationMs;
  final DateTime updatedAt;
  const PlaybackHistoryEntry({
    required this.featureKey,
    required this.bookName,
    required this.title,
    required this.coverUrl,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature_key'] = Variable<String>(featureKey);
    map['book_name'] = Variable<String>(bookName);
    map['title'] = Variable<String>(title);
    map['cover_url'] = Variable<String>(coverUrl);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackHistoryEntriesCompanion(
      featureKey: Value(featureKey),
      bookName: Value(bookName),
      title: Value(title),
      coverUrl: Value(coverUrl),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistoryEntry(
      featureKey: serializer.fromJson<String>(json['featureKey']),
      bookName: serializer.fromJson<String>(json['bookName']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'featureKey': serializer.toJson<String>(featureKey),
      'bookName': serializer.toJson<String>(bookName),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackHistoryEntry copyWith({
    String? featureKey,
    String? bookName,
    String? title,
    String? coverUrl,
    int? positionMs,
    int? durationMs,
    DateTime? updatedAt,
  }) => PlaybackHistoryEntry(
    featureKey: featureKey ?? this.featureKey,
    bookName: bookName ?? this.bookName,
    title: title ?? this.title,
    coverUrl: coverUrl ?? this.coverUrl,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackHistoryEntry copyWithCompanion(PlaybackHistoryEntriesCompanion data) {
    return PlaybackHistoryEntry(
      featureKey: data.featureKey.present
          ? data.featureKey.value
          : this.featureKey,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryEntry(')
          ..write('featureKey: $featureKey, ')
          ..write('bookName: $bookName, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    featureKey,
    bookName,
    title,
    coverUrl,
    positionMs,
    durationMs,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistoryEntry &&
          other.featureKey == this.featureKey &&
          other.bookName == this.bookName &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.updatedAt == this.updatedAt);
}

class PlaybackHistoryEntriesCompanion
    extends UpdateCompanion<PlaybackHistoryEntry> {
  final Value<String> featureKey;
  final Value<String> bookName;
  final Value<String> title;
  final Value<String> coverUrl;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaybackHistoryEntriesCompanion({
    this.featureKey = const Value.absent(),
    this.bookName = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackHistoryEntriesCompanion.insert({
    required String featureKey,
    required String bookName,
    required String title,
    required String coverUrl,
    required int positionMs,
    required int durationMs,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : featureKey = Value(featureKey),
       bookName = Value(bookName),
       title = Value(title),
       coverUrl = Value(coverUrl),
       positionMs = Value(positionMs),
       durationMs = Value(durationMs),
       updatedAt = Value(updatedAt);
  static Insertable<PlaybackHistoryEntry> custom({
    Expression<String>? featureKey,
    Expression<String>? bookName,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (featureKey != null) 'feature_key': featureKey,
      if (bookName != null) 'book_name': bookName,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackHistoryEntriesCompanion copyWith({
    Value<String>? featureKey,
    Value<String>? bookName,
    Value<String>? title,
    Value<String>? coverUrl,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaybackHistoryEntriesCompanion(
      featureKey: featureKey ?? this.featureKey,
      bookName: bookName ?? this.bookName,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (featureKey.present) {
      map['feature_key'] = Variable<String>(featureKey.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryEntriesCompanion(')
          ..write('featureKey: $featureKey, ')
          ..write('bookName: $bookName, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterProgressEntriesTable extends ChapterProgressEntries
    with TableInfo<$ChapterProgressEntriesTable, ChapterProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureKeyMeta = const VerificationMeta(
    'featureKey',
  );
  @override
  late final GeneratedColumn<String> featureKey = GeneratedColumn<String>(
    'feature_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlayedMeta = const VerificationMeta(
    'isPlayed',
  );
  @override
  late final GeneratedColumn<bool> isPlayed = GeneratedColumn<bool>(
    'is_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_played" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    featureKey,
    title,
    positionMs,
    durationMs,
    isPlayed,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature_key')) {
      context.handle(
        _featureKeyMeta,
        featureKey.isAcceptableOrUnknown(data['feature_key']!, _featureKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_featureKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    } else if (isInserting) {
      context.missing(_isPlayedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {featureKey};
  @override
  ChapterProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressEntry(
      featureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChapterProgressEntriesTable createAlias(String alias) {
    return $ChapterProgressEntriesTable(attachedDatabase, alias);
  }
}

class ChapterProgressEntry extends DataClass
    implements Insertable<ChapterProgressEntry> {
  final String featureKey;
  final String title;
  final int positionMs;
  final int durationMs;
  final bool isPlayed;
  final DateTime updatedAt;
  const ChapterProgressEntry({
    required this.featureKey,
    required this.title,
    required this.positionMs,
    required this.durationMs,
    required this.isPlayed,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature_key'] = Variable<String>(featureKey);
    map['title'] = Variable<String>(title);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_played'] = Variable<bool>(isPlayed);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChapterProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressEntriesCompanion(
      featureKey: Value(featureKey),
      title: Value(title),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      isPlayed: Value(isPlayed),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChapterProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressEntry(
      featureKey: serializer.fromJson<String>(json['featureKey']),
      title: serializer.fromJson<String>(json['title']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'featureKey': serializer.toJson<String>(featureKey),
      'title': serializer.toJson<String>(title),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChapterProgressEntry copyWith({
    String? featureKey,
    String? title,
    int? positionMs,
    int? durationMs,
    bool? isPlayed,
    DateTime? updatedAt,
  }) => ChapterProgressEntry(
    featureKey: featureKey ?? this.featureKey,
    title: title ?? this.title,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    isPlayed: isPlayed ?? this.isPlayed,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChapterProgressEntry copyWithCompanion(ChapterProgressEntriesCompanion data) {
    return ChapterProgressEntry(
      featureKey: data.featureKey.present
          ? data.featureKey.value
          : this.featureKey,
      title: data.title.present ? data.title.value : this.title,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressEntry(')
          ..write('featureKey: $featureKey, ')
          ..write('title: $title, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    featureKey,
    title,
    positionMs,
    durationMs,
    isPlayed,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressEntry &&
          other.featureKey == this.featureKey &&
          other.title == this.title &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.isPlayed == this.isPlayed &&
          other.updatedAt == this.updatedAt);
}

class ChapterProgressEntriesCompanion
    extends UpdateCompanion<ChapterProgressEntry> {
  final Value<String> featureKey;
  final Value<String> title;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<bool> isPlayed;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChapterProgressEntriesCompanion({
    this.featureKey = const Value.absent(),
    this.title = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressEntriesCompanion.insert({
    required String featureKey,
    required String title,
    required int positionMs,
    required int durationMs,
    required bool isPlayed,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : featureKey = Value(featureKey),
       title = Value(title),
       positionMs = Value(positionMs),
       durationMs = Value(durationMs),
       isPlayed = Value(isPlayed),
       updatedAt = Value(updatedAt);
  static Insertable<ChapterProgressEntry> custom({
    Expression<String>? featureKey,
    Expression<String>? title,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<bool>? isPlayed,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (featureKey != null) 'feature_key': featureKey,
      if (title != null) 'title': title,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isPlayed != null) 'is_played': isPlayed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressEntriesCompanion copyWith({
    Value<String>? featureKey,
    Value<String>? title,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<bool>? isPlayed,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChapterProgressEntriesCompanion(
      featureKey: featureKey ?? this.featureKey,
      title: title ?? this.title,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      isPlayed: isPlayed ?? this.isPlayed,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (featureKey.present) {
      map['feature_key'] = Variable<String>(featureKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressEntriesCompanion(')
          ..write('featureKey: $featureKey, ')
          ..write('title: $title, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadCacheEntriesTable extends DownloadCacheEntries
    with TableInfo<$DownloadCacheEntriesTable, DownloadCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureKeyMeta = const VerificationMeta(
    'featureKey',
  );
  @override
  late final GeneratedColumn<String> featureKey = GeneratedColumn<String>(
    'feature_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    featureKey,
    title,
    bookName,
    coverUrl,
    filePath,
    status,
    bytes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature_key')) {
      context.handle(
        _featureKeyMeta,
        featureKey.isAcceptableOrUnknown(data['feature_key']!, _featureKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_featureKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_coverUrlMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {featureKey};
  @override
  DownloadCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadCacheEntry(
      featureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadCacheEntriesTable createAlias(String alias) {
    return $DownloadCacheEntriesTable(attachedDatabase, alias);
  }
}

class DownloadCacheEntry extends DataClass
    implements Insertable<DownloadCacheEntry> {
  final String featureKey;
  final String title;
  final String bookName;
  final String coverUrl;
  final String filePath;
  final String status;
  final int bytes;
  final DateTime updatedAt;
  const DownloadCacheEntry({
    required this.featureKey,
    required this.title,
    required this.bookName,
    required this.coverUrl,
    required this.filePath,
    required this.status,
    required this.bytes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature_key'] = Variable<String>(featureKey);
    map['title'] = Variable<String>(title);
    map['book_name'] = Variable<String>(bookName);
    map['cover_url'] = Variable<String>(coverUrl);
    map['file_path'] = Variable<String>(filePath);
    map['status'] = Variable<String>(status);
    map['bytes'] = Variable<int>(bytes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return DownloadCacheEntriesCompanion(
      featureKey: Value(featureKey),
      title: Value(title),
      bookName: Value(bookName),
      coverUrl: Value(coverUrl),
      filePath: Value(filePath),
      status: Value(status),
      bytes: Value(bytes),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadCacheEntry(
      featureKey: serializer.fromJson<String>(json['featureKey']),
      title: serializer.fromJson<String>(json['title']),
      bookName: serializer.fromJson<String>(json['bookName']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      filePath: serializer.fromJson<String>(json['filePath']),
      status: serializer.fromJson<String>(json['status']),
      bytes: serializer.fromJson<int>(json['bytes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'featureKey': serializer.toJson<String>(featureKey),
      'title': serializer.toJson<String>(title),
      'bookName': serializer.toJson<String>(bookName),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'filePath': serializer.toJson<String>(filePath),
      'status': serializer.toJson<String>(status),
      'bytes': serializer.toJson<int>(bytes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadCacheEntry copyWith({
    String? featureKey,
    String? title,
    String? bookName,
    String? coverUrl,
    String? filePath,
    String? status,
    int? bytes,
    DateTime? updatedAt,
  }) => DownloadCacheEntry(
    featureKey: featureKey ?? this.featureKey,
    title: title ?? this.title,
    bookName: bookName ?? this.bookName,
    coverUrl: coverUrl ?? this.coverUrl,
    filePath: filePath ?? this.filePath,
    status: status ?? this.status,
    bytes: bytes ?? this.bytes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadCacheEntry copyWithCompanion(DownloadCacheEntriesCompanion data) {
    return DownloadCacheEntry(
      featureKey: data.featureKey.present
          ? data.featureKey.value
          : this.featureKey,
      title: data.title.present ? data.title.value : this.title,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      status: data.status.present ? data.status.value : this.status,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadCacheEntry(')
          ..write('featureKey: $featureKey, ')
          ..write('title: $title, ')
          ..write('bookName: $bookName, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('bytes: $bytes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    featureKey,
    title,
    bookName,
    coverUrl,
    filePath,
    status,
    bytes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadCacheEntry &&
          other.featureKey == this.featureKey &&
          other.title == this.title &&
          other.bookName == this.bookName &&
          other.coverUrl == this.coverUrl &&
          other.filePath == this.filePath &&
          other.status == this.status &&
          other.bytes == this.bytes &&
          other.updatedAt == this.updatedAt);
}

class DownloadCacheEntriesCompanion
    extends UpdateCompanion<DownloadCacheEntry> {
  final Value<String> featureKey;
  final Value<String> title;
  final Value<String> bookName;
  final Value<String> coverUrl;
  final Value<String> filePath;
  final Value<String> status;
  final Value<int> bytes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadCacheEntriesCompanion({
    this.featureKey = const Value.absent(),
    this.title = const Value.absent(),
    this.bookName = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    this.status = const Value.absent(),
    this.bytes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadCacheEntriesCompanion.insert({
    required String featureKey,
    required String title,
    required String bookName,
    required String coverUrl,
    required String filePath,
    required String status,
    required int bytes,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : featureKey = Value(featureKey),
       title = Value(title),
       bookName = Value(bookName),
       coverUrl = Value(coverUrl),
       filePath = Value(filePath),
       status = Value(status),
       bytes = Value(bytes),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadCacheEntry> custom({
    Expression<String>? featureKey,
    Expression<String>? title,
    Expression<String>? bookName,
    Expression<String>? coverUrl,
    Expression<String>? filePath,
    Expression<String>? status,
    Expression<int>? bytes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (featureKey != null) 'feature_key': featureKey,
      if (title != null) 'title': title,
      if (bookName != null) 'book_name': bookName,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (filePath != null) 'file_path': filePath,
      if (status != null) 'status': status,
      if (bytes != null) 'bytes': bytes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadCacheEntriesCompanion copyWith({
    Value<String>? featureKey,
    Value<String>? title,
    Value<String>? bookName,
    Value<String>? coverUrl,
    Value<String>? filePath,
    Value<String>? status,
    Value<int>? bytes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadCacheEntriesCompanion(
      featureKey: featureKey ?? this.featureKey,
      title: title ?? this.title,
      bookName: bookName ?? this.bookName,
      coverUrl: coverUrl ?? this.coverUrl,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      bytes: bytes ?? this.bytes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (featureKey.present) {
      map['feature_key'] = Variable<String>(featureKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadCacheEntriesCompanion(')
          ..write('featureKey: $featureKey, ')
          ..write('title: $title, ')
          ..write('bookName: $bookName, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('bytes: $bytes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CookieEntriesTable extends CookieEntries
    with TableInfo<$CookieEntriesTable, CookieEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookieEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cookie_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CookieEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CookieEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookieEntry(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CookieEntriesTable createAlias(String alias) {
    return $CookieEntriesTable(attachedDatabase, alias);
  }
}

class CookieEntry extends DataClass implements Insertable<CookieEntry> {
  final String name;
  final String value;
  final DateTime updatedAt;
  const CookieEntry({
    required this.name,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CookieEntriesCompanion toCompanion(bool nullToAbsent) {
    return CookieEntriesCompanion(
      name: Value(name),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory CookieEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookieEntry(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CookieEntry copyWith({String? name, String? value, DateTime? updatedAt}) =>
      CookieEntry(
        name: name ?? this.name,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CookieEntry copyWithCompanion(CookieEntriesCompanion data) {
    return CookieEntry(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookieEntry(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookieEntry &&
          other.name == this.name &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CookieEntriesCompanion extends UpdateCompanion<CookieEntry> {
  final Value<String> name;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CookieEntriesCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookieEntriesCompanion.insert({
    required String name,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<CookieEntry> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookieEntriesCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CookieEntriesCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookieEntriesCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SearchHistoryWordsTable searchHistoryWords =
      $SearchHistoryWordsTable(this);
  late final $BookshelfEntriesTable bookshelfEntries = $BookshelfEntriesTable(
    this,
  );
  late final $PlaybackHistoryEntriesTable playbackHistoryEntries =
      $PlaybackHistoryEntriesTable(this);
  late final $ChapterProgressEntriesTable chapterProgressEntries =
      $ChapterProgressEntriesTable(this);
  late final $DownloadCacheEntriesTable downloadCacheEntries =
      $DownloadCacheEntriesTable(this);
  late final $CookieEntriesTable cookieEntries = $CookieEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    searchHistoryWords,
    bookshelfEntries,
    playbackHistoryEntries,
    chapterProgressEntries,
    downloadCacheEntries,
    cookieEntries,
  ];
}

typedef $$SearchHistoryWordsTableCreateCompanionBuilder =
    SearchHistoryWordsCompanion Function({
      required String word,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SearchHistoryWordsTableUpdateCompanionBuilder =
    SearchHistoryWordsCompanion Function({
      Value<String> word,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SearchHistoryWordsTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryWordsTable> {
  $$SearchHistoryWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryWordsTable> {
  $$SearchHistoryWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryWordsTable> {
  $$SearchHistoryWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SearchHistoryWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryWordsTable,
          SearchHistoryWord,
          $$SearchHistoryWordsTableFilterComposer,
          $$SearchHistoryWordsTableOrderingComposer,
          $$SearchHistoryWordsTableAnnotationComposer,
          $$SearchHistoryWordsTableCreateCompanionBuilder,
          $$SearchHistoryWordsTableUpdateCompanionBuilder,
          (
            SearchHistoryWord,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryWordsTable,
              SearchHistoryWord
            >,
          ),
          SearchHistoryWord,
          PrefetchHooks Function()
        > {
  $$SearchHistoryWordsTableTableManager(
    _$AppDatabase db,
    $SearchHistoryWordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryWordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> word = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryWordsCompanion(
                word: word,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String word,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryWordsCompanion.insert(
                word: word,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryWordsTable,
      SearchHistoryWord,
      $$SearchHistoryWordsTableFilterComposer,
      $$SearchHistoryWordsTableOrderingComposer,
      $$SearchHistoryWordsTableAnnotationComposer,
      $$SearchHistoryWordsTableCreateCompanionBuilder,
      $$SearchHistoryWordsTableUpdateCompanionBuilder,
      (
        SearchHistoryWord,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryWordsTable,
          SearchHistoryWord
        >,
      ),
      SearchHistoryWord,
      PrefetchHooks Function()
    >;
typedef $$BookshelfEntriesTableCreateCompanionBuilder =
    BookshelfEntriesCompanion Function({
      required String bookId,
      required String title,
      required String coverUrl,
      required String author,
      required String announcer,
      required String category,
      required String link,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BookshelfEntriesTableUpdateCompanionBuilder =
    BookshelfEntriesCompanion Function({
      Value<String> bookId,
      Value<String> title,
      Value<String> coverUrl,
      Value<String> author,
      Value<String> announcer,
      Value<String> category,
      Value<String> link,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BookshelfEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BookshelfEntriesTable> {
  $$BookshelfEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get announcer => $composableBuilder(
    column: $table.announcer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookshelfEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookshelfEntriesTable> {
  $$BookshelfEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get announcer => $composableBuilder(
    column: $table.announcer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookshelfEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookshelfEntriesTable> {
  $$BookshelfEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get announcer =>
      $composableBuilder(column: $table.announcer, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BookshelfEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookshelfEntriesTable,
          BookshelfEntry,
          $$BookshelfEntriesTableFilterComposer,
          $$BookshelfEntriesTableOrderingComposer,
          $$BookshelfEntriesTableAnnotationComposer,
          $$BookshelfEntriesTableCreateCompanionBuilder,
          $$BookshelfEntriesTableUpdateCompanionBuilder,
          (
            BookshelfEntry,
            BaseReferences<
              _$AppDatabase,
              $BookshelfEntriesTable,
              BookshelfEntry
            >,
          ),
          BookshelfEntry,
          PrefetchHooks Function()
        > {
  $$BookshelfEntriesTableTableManager(
    _$AppDatabase db,
    $BookshelfEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookshelfEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookshelfEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookshelfEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> announcer = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookshelfEntriesCompanion(
                bookId: bookId,
                title: title,
                coverUrl: coverUrl,
                author: author,
                announcer: announcer,
                category: category,
                link: link,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String title,
                required String coverUrl,
                required String author,
                required String announcer,
                required String category,
                required String link,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookshelfEntriesCompanion.insert(
                bookId: bookId,
                title: title,
                coverUrl: coverUrl,
                author: author,
                announcer: announcer,
                category: category,
                link: link,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookshelfEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookshelfEntriesTable,
      BookshelfEntry,
      $$BookshelfEntriesTableFilterComposer,
      $$BookshelfEntriesTableOrderingComposer,
      $$BookshelfEntriesTableAnnotationComposer,
      $$BookshelfEntriesTableCreateCompanionBuilder,
      $$BookshelfEntriesTableUpdateCompanionBuilder,
      (
        BookshelfEntry,
        BaseReferences<_$AppDatabase, $BookshelfEntriesTable, BookshelfEntry>,
      ),
      BookshelfEntry,
      PrefetchHooks Function()
    >;
typedef $$PlaybackHistoryEntriesTableCreateCompanionBuilder =
    PlaybackHistoryEntriesCompanion Function({
      required String featureKey,
      required String bookName,
      required String title,
      required String coverUrl,
      required int positionMs,
      required int durationMs,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlaybackHistoryEntriesTableUpdateCompanionBuilder =
    PlaybackHistoryEntriesCompanion Function({
      Value<String> featureKey,
      Value<String> bookName,
      Value<String> title,
      Value<String> coverUrl,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlaybackHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryEntriesTable> {
  $$PlaybackHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryEntriesTable> {
  $$PlaybackHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryEntriesTable> {
  $$PlaybackHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackHistoryEntriesTable,
          PlaybackHistoryEntry,
          $$PlaybackHistoryEntriesTableFilterComposer,
          $$PlaybackHistoryEntriesTableOrderingComposer,
          $$PlaybackHistoryEntriesTableAnnotationComposer,
          $$PlaybackHistoryEntriesTableCreateCompanionBuilder,
          $$PlaybackHistoryEntriesTableUpdateCompanionBuilder,
          (
            PlaybackHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $PlaybackHistoryEntriesTable,
              PlaybackHistoryEntry
            >,
          ),
          PlaybackHistoryEntry,
          PrefetchHooks Function()
        > {
  $$PlaybackHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $PlaybackHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackHistoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlaybackHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> featureKey = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoryEntriesCompanion(
                featureKey: featureKey,
                bookName: bookName,
                title: title,
                coverUrl: coverUrl,
                positionMs: positionMs,
                durationMs: durationMs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String featureKey,
                required String bookName,
                required String title,
                required String coverUrl,
                required int positionMs,
                required int durationMs,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoryEntriesCompanion.insert(
                featureKey: featureKey,
                bookName: bookName,
                title: title,
                coverUrl: coverUrl,
                positionMs: positionMs,
                durationMs: durationMs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackHistoryEntriesTable,
      PlaybackHistoryEntry,
      $$PlaybackHistoryEntriesTableFilterComposer,
      $$PlaybackHistoryEntriesTableOrderingComposer,
      $$PlaybackHistoryEntriesTableAnnotationComposer,
      $$PlaybackHistoryEntriesTableCreateCompanionBuilder,
      $$PlaybackHistoryEntriesTableUpdateCompanionBuilder,
      (
        PlaybackHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $PlaybackHistoryEntriesTable,
          PlaybackHistoryEntry
        >,
      ),
      PlaybackHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$ChapterProgressEntriesTableCreateCompanionBuilder =
    ChapterProgressEntriesCompanion Function({
      required String featureKey,
      required String title,
      required int positionMs,
      required int durationMs,
      required bool isPlayed,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChapterProgressEntriesTableUpdateCompanionBuilder =
    ChapterProgressEntriesCompanion Function({
      Value<String> featureKey,
      Value<String> title,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> isPlayed,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChapterProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChapterProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterProgressEntriesTable,
          ChapterProgressEntry,
          $$ChapterProgressEntriesTableFilterComposer,
          $$ChapterProgressEntriesTableOrderingComposer,
          $$ChapterProgressEntriesTableAnnotationComposer,
          $$ChapterProgressEntriesTableCreateCompanionBuilder,
          $$ChapterProgressEntriesTableUpdateCompanionBuilder,
          (
            ChapterProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $ChapterProgressEntriesTable,
              ChapterProgressEntry
            >,
          ),
          ChapterProgressEntry,
          PrefetchHooks Function()
        > {
  $$ChapterProgressEntriesTableTableManager(
    _$AppDatabase db,
    $ChapterProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChapterProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> featureKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressEntriesCompanion(
                featureKey: featureKey,
                title: title,
                positionMs: positionMs,
                durationMs: durationMs,
                isPlayed: isPlayed,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String featureKey,
                required String title,
                required int positionMs,
                required int durationMs,
                required bool isPlayed,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressEntriesCompanion.insert(
                featureKey: featureKey,
                title: title,
                positionMs: positionMs,
                durationMs: durationMs,
                isPlayed: isPlayed,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterProgressEntriesTable,
      ChapterProgressEntry,
      $$ChapterProgressEntriesTableFilterComposer,
      $$ChapterProgressEntriesTableOrderingComposer,
      $$ChapterProgressEntriesTableAnnotationComposer,
      $$ChapterProgressEntriesTableCreateCompanionBuilder,
      $$ChapterProgressEntriesTableUpdateCompanionBuilder,
      (
        ChapterProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $ChapterProgressEntriesTable,
          ChapterProgressEntry
        >,
      ),
      ChapterProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadCacheEntriesTableCreateCompanionBuilder =
    DownloadCacheEntriesCompanion Function({
      required String featureKey,
      required String title,
      required String bookName,
      required String coverUrl,
      required String filePath,
      required String status,
      required int bytes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadCacheEntriesTableUpdateCompanionBuilder =
    DownloadCacheEntriesCompanion Function({
      Value<String> featureKey,
      Value<String> title,
      Value<String> bookName,
      Value<String> coverUrl,
      Value<String> filePath,
      Value<String> status,
      Value<int> bytes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DownloadCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadCacheEntriesTable> {
  $$DownloadCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadCacheEntriesTable> {
  $$DownloadCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadCacheEntriesTable> {
  $$DownloadCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadCacheEntriesTable,
          DownloadCacheEntry,
          $$DownloadCacheEntriesTableFilterComposer,
          $$DownloadCacheEntriesTableOrderingComposer,
          $$DownloadCacheEntriesTableAnnotationComposer,
          $$DownloadCacheEntriesTableCreateCompanionBuilder,
          $$DownloadCacheEntriesTableUpdateCompanionBuilder,
          (
            DownloadCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $DownloadCacheEntriesTable,
              DownloadCacheEntry
            >,
          ),
          DownloadCacheEntry,
          PrefetchHooks Function()
        > {
  $$DownloadCacheEntriesTableTableManager(
    _$AppDatabase db,
    $DownloadCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadCacheEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DownloadCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> featureKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadCacheEntriesCompanion(
                featureKey: featureKey,
                title: title,
                bookName: bookName,
                coverUrl: coverUrl,
                filePath: filePath,
                status: status,
                bytes: bytes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String featureKey,
                required String title,
                required String bookName,
                required String coverUrl,
                required String filePath,
                required String status,
                required int bytes,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadCacheEntriesCompanion.insert(
                featureKey: featureKey,
                title: title,
                bookName: bookName,
                coverUrl: coverUrl,
                filePath: filePath,
                status: status,
                bytes: bytes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadCacheEntriesTable,
      DownloadCacheEntry,
      $$DownloadCacheEntriesTableFilterComposer,
      $$DownloadCacheEntriesTableOrderingComposer,
      $$DownloadCacheEntriesTableAnnotationComposer,
      $$DownloadCacheEntriesTableCreateCompanionBuilder,
      $$DownloadCacheEntriesTableUpdateCompanionBuilder,
      (
        DownloadCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $DownloadCacheEntriesTable,
          DownloadCacheEntry
        >,
      ),
      DownloadCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$CookieEntriesTableCreateCompanionBuilder =
    CookieEntriesCompanion Function({
      required String name,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CookieEntriesTableUpdateCompanionBuilder =
    CookieEntriesCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CookieEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CookieEntriesTable> {
  $$CookieEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CookieEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CookieEntriesTable> {
  $$CookieEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CookieEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CookieEntriesTable> {
  $$CookieEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CookieEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CookieEntriesTable,
          CookieEntry,
          $$CookieEntriesTableFilterComposer,
          $$CookieEntriesTableOrderingComposer,
          $$CookieEntriesTableAnnotationComposer,
          $$CookieEntriesTableCreateCompanionBuilder,
          $$CookieEntriesTableUpdateCompanionBuilder,
          (
            CookieEntry,
            BaseReferences<_$AppDatabase, $CookieEntriesTable, CookieEntry>,
          ),
          CookieEntry,
          PrefetchHooks Function()
        > {
  $$CookieEntriesTableTableManager(_$AppDatabase db, $CookieEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookieEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookieEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CookieEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CookieEntriesCompanion(
                name: name,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CookieEntriesCompanion.insert(
                name: name,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CookieEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CookieEntriesTable,
      CookieEntry,
      $$CookieEntriesTableFilterComposer,
      $$CookieEntriesTableOrderingComposer,
      $$CookieEntriesTableAnnotationComposer,
      $$CookieEntriesTableCreateCompanionBuilder,
      $$CookieEntriesTableUpdateCompanionBuilder,
      (
        CookieEntry,
        BaseReferences<_$AppDatabase, $CookieEntriesTable, CookieEntry>,
      ),
      CookieEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SearchHistoryWordsTableTableManager get searchHistoryWords =>
      $$SearchHistoryWordsTableTableManager(_db, _db.searchHistoryWords);
  $$BookshelfEntriesTableTableManager get bookshelfEntries =>
      $$BookshelfEntriesTableTableManager(_db, _db.bookshelfEntries);
  $$PlaybackHistoryEntriesTableTableManager get playbackHistoryEntries =>
      $$PlaybackHistoryEntriesTableTableManager(
        _db,
        _db.playbackHistoryEntries,
      );
  $$ChapterProgressEntriesTableTableManager get chapterProgressEntries =>
      $$ChapterProgressEntriesTableTableManager(
        _db,
        _db.chapterProgressEntries,
      );
  $$DownloadCacheEntriesTableTableManager get downloadCacheEntries =>
      $$DownloadCacheEntriesTableTableManager(_db, _db.downloadCacheEntries);
  $$CookieEntriesTableTableManager get cookieEntries =>
      $$CookieEntriesTableTableManager(_db, _db.cookieEntries);
}
