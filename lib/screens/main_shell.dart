import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/shell_provider.dart';
import '../widgets/bottom_nav.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _keys = List.generate(3, (_) => GlobalKey<NavigatorState>());
  final _roots = const <Widget>[HomeScreen(), CategoriesScreen(), FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _keys[shell.index].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (shell.index != 0) {
          shell.setTab(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: shell.index,
          children: [
            for (var i = 0; i < 3; i++)
              Navigator(
                key: _keys[i],
                onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _roots[i]),
              ),
          ],
        ),
        bottomNavigationBar: CuteNavBar(
          index: shell.index,
          onTap: (i) {
            if (i == shell.index) {
              _keys[i].currentState?.popUntil((r) => r.isFirst);
            } else {
              shell.setTab(i);
            }
          },
        ),
      ),
    );
  }
}
