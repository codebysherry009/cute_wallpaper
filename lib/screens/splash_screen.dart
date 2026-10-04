import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Splash screen: shows the app's cute background artwork full-screen and
/// waits for [ready] (home data + favorites) before handing off to [next].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.ready, required this.next});

  /// Resolves once initial data is loaded. The splash still shows for a
  /// minimum time so it never just flashes on a fast connection.
  final Future<void> ready;
  final Widget next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _goNext = false;

  @override
  void initState() {
    super.initState();
    _wait();
  }

  Future<void> _wait() async {
    await Future.wait([
      widget.ready,
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);
    if (mounted) setState(() => _goNext = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      child: _goNext ? widget.next : const _SplashBody(key: ValueKey('splash')),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pinkFaint,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/splash/splash_bg.jpg', fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: SafeArea(
              top: false,
              child: Column(
                children: const [
                  _BouncingDots(),
                  SizedBox(height: 14),
                  Text(
                    'Loading cute wallpapers...',
                    style: TextStyle(
                      color: AppColors.pinkDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three pink dots bouncing in sequence.
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_c.value - i * 0.2) % 1.0;
              final bounce = t < 0.5
                  ? Curves.easeOut.transform(t * 2)
                  : Curves.easeIn.transform(1 - (t - 0.5) * 2);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Transform.translate(
                  offset: Offset(0, -10 * bounce),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pink.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
