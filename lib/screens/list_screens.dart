import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/category.dart';
import '../models/wallpaper.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/common.dart';

class _GridPage extends StatelessWidget {
  const _GridPage({
    required this.title,
    required this.state,
    required this.onRefresh,
  });
  final String title;
  final Async<List<Wallpaper>> state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(title: title, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.pink,
                onRefresh: onRefresh,
                child: AsyncView<Wallpaper>(
                  state: state,
                  onRetry: onRefresh,
                  emptyText: 'No wallpapers found',
                  loading: const LoadingGrid(),
                  builder: (list) => WallpaperGrid(items: list),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WallpaperProvider>();
    return _GridPage(title: 'Featured', state: wp.featured, onRefresh: wp.loadFeatured);
  }
}

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WallpaperProvider>();
    return _GridPage(title: 'Trending', state: wp.trending, onRefresh: wp.loadTrending);
  }
}

class CategoryWallpapersScreen extends StatefulWidget {
  const CategoryWallpapersScreen({super.key, required this.category});
  final WallCategory category;
  @override
  State<CategoryWallpapersScreen> createState() => _CategoryWallpapersScreenState();
}

class _CategoryWallpapersScreenState extends State<CategoryWallpapersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WallpaperProvider>().loadCategory(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WallpaperProvider>();
    final id = widget.category.id;
    return _GridPage(
      title: widget.category.name,
      state: wp.categoryState(id),
      onRefresh: () => wp.loadCategory(id, force: true),
    );
  }
}
