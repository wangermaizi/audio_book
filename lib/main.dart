import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestNotificationPermission();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wangermazi.audiobook.audio',
    androidNotificationChannelName: '有声听书',
    androidNotificationIcon: 'drawable/ic_stat_audio_book',
    androidNotificationOngoing: true,
    notificationColor: const Color(0xFF2E9AF2),
  );
  runApp(const MyAudioApp());
}

Future<void> _requestNotificationPermission() async {
  const channel = MethodChannel('com.wangermazi.audiobook.audio_book/system');
  try {
    await channel.invokeMethod<void>('requestPostNotifications');
  } on MissingPluginException {
    // Non-Android platforms do not need this runtime permission.
  }
}
