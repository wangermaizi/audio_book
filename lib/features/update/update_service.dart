import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UpdateService {
  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _latestReleaseUrl =
      'https://api.github.com/repos/wangermaizi/audio_book/releases/latest';
  static const MethodChannel _channel = MethodChannel(
    'com.wangermazi.audiobook.audio_book/update',
  );

  Future<UpdateInfo?> checkForUpdate() async {
    if (!Platform.isAndroid) {
      return null;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final response = await _dio.get<Map<String, dynamic>>(
      _latestReleaseUrl,
      options: Options(headers: const {'User-Agent': 'AudioBookApp'}),
    );

    final data = response.data;
    if (data == null) {
      return null;
    }

    final tagName = (data['tag_name'] as String? ?? '').trim();
    final latestVersion = _normalizeVersion(tagName);
    if (latestVersion.isEmpty ||
        !_isRemoteVersionNewer(latestVersion, packageInfo.version)) {
      return null;
    }

    final assets = data['assets'];
    if (assets is! List) {
      return null;
    }

    Map<String, dynamic>? apkAsset;
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) {
        continue;
      }
      final name = asset['name'] as String? ?? '';
      if (name.endsWith('.apk')) {
        apkAsset = asset;
        break;
      }
    }
    if (apkAsset == null) {
      return null;
    }

    final downloadUrl = apkAsset['browser_download_url'] as String? ?? '';
    if (downloadUrl.isEmpty) {
      return null;
    }

    return UpdateInfo(
      version: latestVersion,
      tagName: tagName,
      releaseUrl: data['html_url'] as String? ?? '',
      body: data['body'] as String? ?? '',
      apkName: apkAsset['name'] as String? ?? 'audio-book-$tagName.apk',
      apkDownloadUrl: downloadUrl,
      publishedAt: data['published_at'] as String? ?? '',
    );
  }

  Future<String> downloadApk(
    UpdateInfo update, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final updateDirectory = Directory(path.join(directory.path, 'updates'));
    if (!updateDirectory.existsSync()) {
      updateDirectory.createSync(recursive: true);
    }

    final filePath = path.join(updateDirectory.path, update.apkName);
    await _dio.download(
      update.apkDownloadUrl,
      filePath,
      options: Options(headers: const {'User-Agent': 'AudioBookApp'}),
      onReceiveProgress: onReceiveProgress,
    );
    return filePath;
  }

  Future<void> installApk(String apkPath) async {
    await _channel.invokeMethod<void>('installApk', {'path': apkPath});
  }

  String _normalizeVersion(String value) {
    return value.trim().replaceFirst(RegExp(r'^[vV]'), '');
  }

  bool _isRemoteVersionNewer(String remote, String current) {
    final remoteParts = _versionParts(remote);
    final currentParts = _versionParts(current);
    final length = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;

    for (var i = 0; i < length; i++) {
      final remotePart = i < remoteParts.length ? remoteParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (remotePart > currentPart) {
        return true;
      }
      if (remotePart < currentPart) {
        return false;
      }
    }
    return false;
  }

  List<int> _versionParts(String value) {
    final normalized = value.split('+').first;
    return normalized
        .split('.')
        .map((part) => int.tryParse(part.replaceAll(RegExp(r'\D'), '')) ?? 0)
        .toList();
  }
}

class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.tagName,
    required this.releaseUrl,
    required this.body,
    required this.apkName,
    required this.apkDownloadUrl,
    required this.publishedAt,
  });

  final String version;
  final String tagName;
  final String releaseUrl;
  final String body;
  final String apkName;
  final String apkDownloadUrl;
  final String publishedAt;
}
