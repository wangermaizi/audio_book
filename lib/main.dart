import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:audio_book/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wangermazi.audiobook.audio',
    androidNotificationChannelName: 'Audio Book',
    androidNotificationOngoing: true,
  );
  runApp(const MyAudioApp());
}
