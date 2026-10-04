import '../core/config.dart';
import '../core/json_utils.dart';

class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.thumbUrl,
    required this.category,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String thumbUrl;
  final String category;

  String get key => imageUrl;
  String get displayTitle => title.isEmpty ? 'Cute Wallpaper' : title;
  String get subtitle =>
      category.isEmpty ? AppConfig.fallbackSubtitle : category;

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    final j = lowerKeys(json);

    var image = pickStr(j, const [
      'image_url',
      'imageurl',
      'image',
      'image_file',
      'imagefile',
      'wallpaper',
      'wallpaper_url',
      'wallpaperurl',
      'wallpaperimage',
      'wallpaper_image',
      'url',
      'file',
      'path',
      'img',
      'photo',
      'original',
      'full_image',
      'hd_image',
    ]);
    final thumb = pickStr(j, const [
      'thumbnail',
      'thumb',
      'thumb_url',
      'thumbnail_url',
      'thumbnailurl',
      'wallpaperthumbnail',
      'wallpaper_thumbnail',
      'image_thumb',
      'thumb_image',
    ]);
    if (image.isEmpty) image = thumb;

    var cat = pickStr(j, const [
      'category_name',
      'categoryname',
      'cat_name',
      'category',
      'tag',
    ]);
    if (int.tryParse(cat) != null) cat = '';

    final imageUrl = resolveUrl(image);
    final thumbUrl = thumb.isEmpty ? imageUrl : resolveUrl(thumb);

    return Wallpaper(
      id: pickStr(j, const ['id', 'wallpaper_id', 'wallpaperid', 'wid']),
      title: pickStr(j, const [
        'title',
        'name',
        'wallpaper_name',
        'wallpapername',
        'wallpaper_title',
        'wallpapertitle',
        'caption',
      ]),
      imageUrl: imageUrl,
      thumbUrl: thumbUrl,
      category: cat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'thumbnail': thumbUrl,
        'category_name': category,
      };
}
