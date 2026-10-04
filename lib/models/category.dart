import '../core/json_utils.dart';

class WallCategory {
  const WallCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  factory WallCategory.fromJson(Map<String, dynamic> json) {
    final j = lowerKeys(json);
    return WallCategory(
      id: pickStr(j, const [
        'id',
        'category_id',
        'cat_id',
        'cid',
        'categoryid',
      ]),
      name: pickStr(j, const [
        'name',
        'category_name',
        'categoryname',
        'cat_name',
        'catname',
        'title',
        'category_title',
        'category',
      ]),
      imageUrl: resolveUrl(pickStr(j, const [
        'image',
        'image_url',
        'imageurl',
        'category_image',
        'categoryimage',
        'cat_image',
        'catimage',
        'category_img',
        'image_file',
        'imagefile',
        'icon',
        'icon_url',
        'thumbnail',
        'thumbnail_url',
        'thumb',
        'img',
        'img_url',
        'photo',
        'cover',
        'cover_image',
      ])),
    );
  }
}
