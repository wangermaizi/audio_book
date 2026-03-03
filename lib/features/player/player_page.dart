import 'package:flutter/material.dart';

import 'package:audio_book/core/logger/file_logger.dart';
import 'package:audio_book/features/player/player_api.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
    required this.featureKey,
    required this.title,
  });

  final String featureKey;
  final String title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late Future<String> _future;
  final PlayerApi _api = PlayerApi();

  @override
  void initState() {
    super.initState();
    _future = _api.fetchPlayHtml(widget.featureKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<String>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('加载播放页失败'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _future =
                              _api.fetchPlayHtml(widget.featureKey);
                        });
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          final html = snapshot.data ?? '';

          // 全量内容写入本地 log 文件
          FileLogger().logPlayHtml(
            featureKey: widget.featureKey,
            html: html,
          );

          return const Center(
            child: Text('播放页 HTML 已写入 player_html.log'),
          );
        },
      ),
    );
  }
}

