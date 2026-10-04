import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/category.dart';
import 'common.dart';

/// Category card: image + name, both coming from the API.
///
/// [large] is used for the 2-column Categories grid (bigger image + label);
/// the compact (default) style is used for the horizontal row on Home.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.large = false,
  });
  final WallCategory category;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(large ? 8 : 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(large ? 20 : 18),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(large ? 15 : 13),
                child: NetImage(category.imageUrl, cacheWidth: large ? 400 : 300),
              ),
            ),
            SizedBox(height: large ? 8 : 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: large ? 14 : 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: large ? 4 : 2),
          ],
        ),
      ),
    );
  }
}
