import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/wallpaper.dart';
import '../providers/shell_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import 'list_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WallpaperProvider>();
    return PageScaffold(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.pink,
          onRefresh: wp.loadHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              const _Header(),
              const SizedBox(height: 18),
              AsyncView<Wallpaper>(
                state: wp.featured,
                onRetry: wp.loadFeatured,
                compact: true,
                loading: const SizedBox(height: 190, child: PlaceholderBox(radius: 22)),
                emptyText: 'No featured wallpapers',
                builder: (list) => _FeaturedCarousel(items: list.take(8).toList()),
              ),
              const SizedBox(height: 22),
              SectionHeader(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF6B3D),
                title: 'Trending',
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrendingScreen()),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 165,
                child: AsyncView<Wallpaper>(
                  state: wp.trending,
                  onRetry: wp.loadTrending,
                  compact: true,
                  emptyText: 'No trending wallpapers',
                  loading: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, __) => const SizedBox(width: 112, child: PlaceholderBox()),
                  ),
                  builder: (list) {
                    final items = list.take(10).toList();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => SizedBox(
                        width: 112,
                        child: WallpaperTile(
                          wallpaper: items[i],
                          onTap: () => openDetail(context, items, i),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              SectionHeader(
                icon: Icons.grid_view_rounded,
                iconColor: AppColors.ink,
                title: 'Categories',
                onSeeAll: () => context.read<ShellProvider>().setTab(1),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 118,
                child: AsyncView(
                  state: wp.categories,
                  onRetry: wp.loadCategories,
                  compact: true,
                  emptyText: 'No categories',
                  loading: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, __) => const SizedBox(width: 88, child: PlaceholderBox()),
                  ),
                  builder: (cats) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: 88,
                      child: CategoryCard(
                        category: cats[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryWallpapersScreen(category: cats[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Cute',
                style: TextStyle(
                    fontSize: 32, height: 1.05, fontWeight: FontWeight.w800, color: AppColors.pink)),
            SizedBox(width: 6),
            Icon(Icons.favorite_rounded, color: AppColors.pink, size: 18),
          ],
        ),
        const Text('Wallpapers',
            style: TextStyle(
                fontSize: 32, height: 1.05, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 6),
        const Text('Make your phone cute ✨',
            style: TextStyle(fontSize: 13.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.items});
  final List<Wallpaper> items;
  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => openDetail(context, items, i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(items[i].thumbUrl, cacheWidth: 900),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x99000000)],
                            stops: [0.45, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FeaturedScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.pink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Featured',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[i].displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(items[i].subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.pink : AppColors.pink.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
