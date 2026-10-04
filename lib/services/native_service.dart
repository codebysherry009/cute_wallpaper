import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

enum WallpaperTarget { home, lock, both }

class NativeService {
  static const _channel = MethodChannel('com.brightapps.cutewall/native');

  static Future<void> setWallpaper(Uint8List bytes, WallpaperTarget target) async {
    final code = switch (target) {
      WallpaperTarget.home => 1,
      WallpaperTarget.lock => 2,
      WallpaperTarget.both => 3,
    };
    await _channel.invokeMethod('setWallpaper', {'bytes': bytes, 'target': code});
  }

  static Future<void> saveToGallery(Uint8List bytes, String name, String mime) async {
    await _channel.invokeMethod('saveToGallery', {
      'bytes': bytes,
      'name': name,
      'mime': mime,
    });
  }
}

class ImageService {
  static Future<Uint8List> fetch(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));
    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }
    return res.bodyBytes;
  }

  static String extension(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    for (final e in const ['png', 'webp', 'jpeg', 'jpg']) {
      if (path.endsWith('.$e')) return e;
    }
    return 'jpg';
  }

  static String mime(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
}
