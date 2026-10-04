import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../screens/detail_screen.dart';

class GradientBg extends StatelessWidget {
  const GradientBg({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GradientBg(
      child: Scaffold(backgroundColor: Colors.transparent, body: child),
    );
  }
}

class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover, this.cacheWidth});
  final String url;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImgFallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: cacheWidth,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => const ColoredBox(color: AppColors.pinkSoft),
      errorWidget: (_, __, ___) => const _ImgFallback(),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: AppColors.pinkSoft,
        child: Center(
          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
        ),
      );
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.onBack, this.trailing});
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.ink),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onSeeAll,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Text('See All',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}

class PlaceholderBox extends StatelessWidget {
  const PlaceholderBox({super.key, this.radius = 16});
  final double radius;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.pinkSoft.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const SizedBox.expand(),
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry, this.compact = false});
  final String message;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.pink, size: 34),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.pink,
            shape: const StadiumBorder(),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
    return compact
        ? Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: content))
        : Center(child: content);
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border_rounded, color: AppColors.pink, size: 40),
              const SizedBox(height: 10),
              Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

/// Shows data if we have it, else loading / error / empty.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.state,
    required this.builder,
    required this.onRetry,
    required this.loading,
    this.emptyText = 'Nothing here yet',
    this.compact = false,
  });
  final Async<List<T>> state;
  final Widget Function(List<T> data) builder;
  final VoidCallback onRetry;
  final Widget loading;
  final String emptyText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    if (d != null && d.isNotEmpty) return builder(d);
    if (state.status == Status.idle || state.status == Status.loading) return loading;
    if (state.status == Status.error) {
      return ErrorView(message: state.error ?? 'Something went wrong', onRetry: onRetry, compact: compact);
    }
    return compact
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(emptyText, style: const TextStyle(color: AppColors.muted))),
          )
        : EmptyView(text: emptyText);
  }
}

class WallpaperTile extends StatelessWidget {
  const WallpaperTile({super.key, required this.wallpaper, required this.onTap, this.radius = 16});
  final Wallpaper wallpaper;
  final VoidCallback onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fav = context.select<FavoritesProvider, bool>((f) => f.isFav(wallpaper));
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(wallpaper.thumbUrl, cacheWidth: 500),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<FavoritesProvider>().toggle(wallpaper),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20,
                    color: fav ? AppColors.pink : Colors.white,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openDetail(BuildContext context, List<Wallpaper> list, int index) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => DetailScreen(items: list, index: index)),
  );
}

class WallpaperGrid extends StatelessWidget {
  const WallpaperGrid({super.key, required this.items});
  final List<Wallpaper> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => WallpaperTile(
        wallpaper: items[i],
        onTap: () => openDetail(context, items, i),
      ),
    );
  }
}

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key, this.columns = 2, this.ratio = 0.68});
  final int columns;
  final double ratio;
  @override
  Widget build(BuildContext context) => GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: ratio,
        ),
        itemCount: columns * 4,
        itemBuilder: (_, __) => const PlaceholderBox(),
      );
}
