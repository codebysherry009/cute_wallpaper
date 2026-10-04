import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/errors.dart';
import '../core/theme.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../services/native_service.dart';
import '../widgets/common.dart';
import 'set_wallpaper_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.items, required this.index});
  final List<Wallpaper> items;
  final int index;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final PageController _pc = PageController(initialPage: widget.index);
  late int _i = widget.index;
  bool _busy = false;

  Wallpaper get _w => widget.items[_i];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final w = _w;
      final bytes = await ImageService.fetch(w.imageUrl);
      final ext = ImageService.extension(w.imageUrl);
      await NativeService.saveToGallery(
        bytes,
        'CuteWall_${DateTime.now().millisecondsSinceEpoch}.$ext',
        ImageService.mime(ext),
      );
      _toast('Saved to Pictures/CuteWall 💖');
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.select<FavoritesProvider, bool>((f) => f.isFav(_w));
    final favs = context.read<FavoritesProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pc,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) {
                final w = widget.items[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    NetImage(w.thumbUrl, cacheWidth: 500),
                    NetImage(w.imageUrl),
                  ],
                );
              },
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Color(0x00000000), Color(0x00000000), Color(0xCC000000)],
                    stops: [0, 0.2, 0.6, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => favs.toggle(_w),
                        icon: Icon(
                          fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: fav ? AppColors.pink : Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Action(
                            icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: AppColors.pink,
                            label: 'Favorite',
                            onTap: () => favs.toggle(_w),
                          ),
                          const SizedBox(width: 18),
                          _Action(
                            icon: Icons.download_rounded,
                            color: Colors.white,
                            label: 'Download',
                            onTap: _download,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SetWallpaperScreen(wallpaper: _w)),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.pink,
                                  shape: const StadiumBorder(),
                                ),
                                icon: const Icon(Icons.wallpaper_rounded, size: 20),
                                label: const Text('Set Wallpaper',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_busy)
              const ColoredBox(
                color: Color(0x88000000),
                child: Center(child: CircularProgressIndicator(color: AppColors.pink)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
