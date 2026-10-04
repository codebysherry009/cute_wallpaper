class AppConfig {
  /// Server host (used when an API returns a path starting with "/").
  static const String host = 'https://arbaglobal.pro';

  /// API folder (used when an API returns a relative path like "uploads/a.jpg").
  static const String apiBase = 'https://arbaglobal.pro/apps/cuteWallp/';

  static const String featuredEndpoint = 'featured.php';
  static const String trendingEndpoint = 'trending.php';
  static const String categoriesEndpoint = 'categories.php';
  static const String wallpaperEndpoint = 'wallpaper.php';

  static const String fallbackSubtitle = 'Cute • Kawaii • Adorable';
}
