import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/favorites_provider.dart';
import 'providers/shell_provider.dart';
import 'providers/wallpaper_provider.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const CuteWallApp());
}

class CuteWallApp extends StatefulWidget {
  const CuteWallApp({super.key});

  @override
  State<CuteWallApp> createState() => _CuteWallAppState();
}

class _CuteWallAppState extends State<CuteWallApp> {
  final _wallpapers = WallpaperProvider();
  final _favorites = FavoritesProvider();
  late final Future<void> _ready =
      Future.wait([_wallpapers.loadHome(), _favorites.load()]);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _wallpapers),
        ChangeNotifierProvider.value(value: _favorites),
        ChangeNotifierProvider(create: (_) => ShellProvider()),
      ],
      child: MaterialApp(
        title: 'CuteWall',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: SplashScreen(ready: _ready, next: const MainShell()),
      ),
    );
  }
}
