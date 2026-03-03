import 'package:flutter/material.dart';

import 'package:audio_book/features/home/home_page.dart';

class MyAudioApp extends StatelessWidget {
  const MyAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

