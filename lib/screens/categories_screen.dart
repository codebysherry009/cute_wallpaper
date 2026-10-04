import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/shell_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import 'list_screens.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WallpaperProvider>();
    return PageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              title: 'Categories',
              onBack: () => context.read<ShellProvider>().setTab(0),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.pink,
                onRefresh: wp.loadCategories,
                child: AsyncView(
                  state: wp.categories,
                  onRetry: wp.loadCategories,
                  emptyText: 'No categories found',
                  loading: const LoadingGrid(columns: 2, ratio: 1.05),
                  builder: (cats) => GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (_, i) => CategoryCard(
                      category: cats[i],
                      large: true,
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
    );
  }
}
