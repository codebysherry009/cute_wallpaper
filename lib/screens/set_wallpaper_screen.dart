import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/errors.dart';
import '../core/theme.dart';
import '../models/wallpaper.dart';
import '../services/native_service.dart';
import '../widgets/common.dart';

class SetWallpaperScreen extends StatefulWidget {
  const SetWallpaperScreen({super.key, required this.wallpaper});
  final Wallpaper wallpaper;

  @override
  State<SetWallpaperScreen> createState() => _SetWallpaperScreenState();
}

class _SetWallpaperScreenState extends State<SetWallpaperScreen> {
  bool _busy = false;

  Future<void> _apply(WallpaperTarget target) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    String msg;
    var ok = false;
    try {
      final bytes = await ImageService.fetch(widget.wallpaper.imageUrl);
      await NativeService.setWallpaper(bytes, target);
      msg = 'Wallpaper set successfully 💖';
      ok = true;
    } catch (e) {
      msg = friendlyError(e);
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
    if (!mounted) return;
    if (ok) {
      nav.pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFF17151C),
        body: Stack(
          children: [
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                        const Expanded(
                          child: Text('Set Wallpaper',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(widget.wallpaper.imageUrl),
                      const ColoredBox(color: Color(0x99000000)),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set as',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 14),
                      _Option(
                          icon: Icons.home_outlined,
                          label: 'Home Screen',
                          onTap: () => _apply(WallpaperTarget.home)),
                      _Option(
                          icon: Icons.lock_outline_rounded,
                          label: 'Lock Screen',
                          onTap: () => _apply(WallpaperTarget.lock)),
                      _Option(
                          icon: Icons.smartphone_rounded,
                          label: 'Both',
                          onTap: () => _apply(WallpaperTarget.both)),
                      const SizedBox(height: 10),
                      _Option(
                          label: 'Cancel',
                          centered: true,
                          onTap: () => Navigator.of(context).pop()),
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

class _Option extends StatelessWidget {
  const _Option({this.icon, required this.label, required this.onTap, this.centered = false});
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: centered ? Alignment.center : Alignment.centerLeft,
            child: Row(
              mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.ink, size: 22),
                  const SizedBox(width: 16),
                ],
                Text(label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
