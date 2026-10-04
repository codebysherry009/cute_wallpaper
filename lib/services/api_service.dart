import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../core/errors.dart';
import '../core/json_utils.dart';
import '../models/category.dart';
import '../models/wallpaper.dart';

class ApiService {
  static const _timeout = Duration(seconds: 25);

  Future<List<Map<String, dynamic>>> _parse(http.Response res) async {
    if (res.statusCode != 200) {
      throw ApiException('Server error (${res.statusCode})');
    }
    final decoded = decodeLoose(res.body);
    final list = extractList(decoded);
    if (list.isEmpty) {
      final err = serverError(decoded);
      if (err != null) throw ApiException(err);
      // Nothing recognizable was found — print the raw body so it can be
      // inspected in `flutter run` logs / DevTools console.
      debugPrint('[CuteWall] ${res.request?.url}: could not find a list in '
          '-> ${res.body.length > 800 ? res.body.substring(0, 800) : res.body}');
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> _get(String endpoint) async {
    final res = await http
        .get(
          Uri.parse('${AppConfig.apiBase}$endpoint'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(_timeout);
    return _parse(res);
  }

  List<Wallpaper> _wallpapers(List<Map<String, dynamic>> raw) => raw
      .map(Wallpaper.fromJson)
      .where((w) => w.imageUrl.isNotEmpty)
      .toList();

  Future<List<Wallpaper>> featured() async =>
      _wallpapers(await _get(AppConfig.featuredEndpoint));

  Future<List<Wallpaper>> trending() async =>
      _wallpapers(await _get(AppConfig.trendingEndpoint));

  Future<List<WallCategory>> categories() async {
    final raw = await _get(AppConfig.categoriesEndpoint);
    return raw.map(WallCategory.fromJson).where((c) => c.name.isNotEmpty).toList();
  }

  /// POST multipart/form-data  ->  category=<id>
  Future<List<Wallpaper>> byCategory(String categoryId) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBase}${AppConfig.wallpaperEndpoint}'),
    )
      ..headers['Accept'] = 'application/json'
      ..fields['category'] = categoryId;
    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed).timeout(_timeout);
    return _wallpapers(await _parse(res));
  }
}
