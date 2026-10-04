import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallpaper.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _prefKey = 'favorites_v1';
  final List<Wallpaper> _items = [];

  List<Wallpaper> get items => List.unmodifiable(_items);
  bool isFav(Wallpaper w) => _items.any((e) => e.key == w.key);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _items
        ..clear()
        ..addAll(list
            .whereType<Map>()
            .map((m) => Wallpaper.fromJson(Map<String, dynamic>.from(m))));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> toggle(Wallpaper w) async {
    final i = _items.indexWhere((e) => e.key == w.key);
    if (i >= 0) {
      _items.removeAt(i);
    } else {
      _items.insert(0, w);
    }
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _save();
  }
}
