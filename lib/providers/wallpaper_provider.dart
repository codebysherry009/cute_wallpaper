import 'package:flutter/foundation.dart';

import '../core/errors.dart';
import '../models/category.dart';
import '../models/wallpaper.dart';
import '../services/api_service.dart';

enum Status { idle, loading, ready, error }

class Async<T> {
  const Async(this.status, {this.data, this.error});
  final Status status;
  final T? data;
  final String? error;
}

class WallpaperProvider extends ChangeNotifier {
  final _api = ApiService();

  Async<List<Wallpaper>> featured = const Async(Status.idle);
  Async<List<Wallpaper>> trending = const Async(Status.idle);
  Async<List<WallCategory>> categories = const Async(Status.idle);
  final Map<String, Async<List<Wallpaper>>> _byCategory = {};

  Async<List<Wallpaper>> categoryState(String id) =>
      _byCategory[id] ?? const Async(Status.idle);

  Future<void> _load<T>(
    Async<T> Function() get,
    void Function(Async<T>) set,
    Future<T> Function() fetch,
  ) async {
    set(Async<T>(Status.loading, data: get().data));
    notifyListeners();
    try {
      set(Async<T>(Status.ready, data: await fetch()));
    } catch (e) {
      set(Async<T>(Status.error, data: get().data, error: friendlyError(e)));
    }
    notifyListeners();
  }

  Future<void> loadFeatured() => _load<List<Wallpaper>>(
      () => featured, (v) => featured = v, _api.featured);

  Future<void> loadTrending() => _load<List<Wallpaper>>(
      () => trending, (v) => trending = v, _api.trending);

  Future<void> loadCategories() => _load<List<WallCategory>>(
      () => categories, (v) => categories = v, _api.categories);

  Future<void> loadHome() async {
    await Future.wait([loadFeatured(), loadTrending(), loadCategories()]);
  }

  Future<void> loadCategory(String id, {bool force = false}) {
    final current = categoryState(id);
    if (!force && current.status == Status.ready) return Future.value();
    return _load<List<Wallpaper>>(
      () => categoryState(id),
      (v) => _byCategory[id] = v,
      () => _api.byCategory(id),
    );
  }
}
