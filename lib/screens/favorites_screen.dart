import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/favorites_provider.dart';
import '../providers/shell_provider.dart';
import '../widgets/common.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear favorites?'),
        content: const Text('All saved wallpapers will be removed from favorites.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.pink)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<FavoritesProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>().items;
    return PageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.pink, size: 24),
                  const SizedBox(width: 8),
                  const Text('Favorites',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const Spacer(),
                  if (favs.isNotEmpty)
                    IconButton(
                      onPressed: () => _confirmClear(context),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.ink),
                    ),
                ],
              ),
            ),
            Expanded(
              child: favs.isEmpty
                  ? const _EmptyFavorites()
                  : WallpaperGrid(items: favs),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 170,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, AppColors.pinkSoft],
                      ),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppColors.pink, size: 64),
                  ),
                  Positioned(
                    top: 4,
                    right: 14,
                    child: Icon(Icons.favorite_rounded, color: AppColors.pink.withValues(alpha: 0.45), size: 22),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 8,
                    child: Icon(Icons.favorite_rounded, color: AppColors.pink.withValues(alpha: 0.3), size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('No favorites yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 8),
            const Text('Save your favorite wallpapers\nand find them here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => context.read<ShellProvider>().setTab(0),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pink,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              ),
              child: const Text('Explore Wallpapers', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
