import 'package:flutter/services.dart';

class SystemShare {
  static const MethodChannel _channel = MethodChannel(
    'com.wangermazi.audiobook.audio_book/share',
  );

  Future<void> text({required String title, required String content}) {
    return _channel.invokeMethod<void>('shareText', {
      'title': title,
      'content': content,
    });
  }
}
