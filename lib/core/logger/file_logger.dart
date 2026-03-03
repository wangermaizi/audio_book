import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileLogger {
  FileLogger._internal();

  static final FileLogger _instance = FileLogger._internal();

  factory FileLogger() => _instance;

  File? _logFile;

  Future<File> _ensureFile() async {
    if (_logFile != null) return _logFile!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/player_html.log');
    _logFile = file;
    return file;
  }

  Future<void> logPlayHtml({
    required String featureKey,
    required String html,
  }) async {
    try {
      final file = await _ensureFile();
      final now = DateTime.now().toIso8601String();
      final header =
          '===== $now featureKey=$featureKey =====\n';
      await file.writeAsString(
        '$header$html\n\n',
        mode: FileMode.append,
      );
      debugPrint(
          '已将播放页 HTML 写入日志文件: ${file.path} (featureKey=$featureKey)');
    } catch (e, st) {
      debugPrint('写入播放页 HTML 日志失败: $e\n$st');
    }
  }
}

