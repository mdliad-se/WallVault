import '../../domain/entities/wallpaper.dart';

class WallpaperModel {
  final String path;
  final DateTime createdAt;
  final String? colorHex;

  WallpaperModel({
    required this.path,
    required this.createdAt,
    this.colorHex,
  });

  Wallpaper toEntity() => Wallpaper(path: path, createdAt: createdAt, colorHex: colorHex);

  factory WallpaperModel.fromEntity(Wallpaper wallpaper) => WallpaperModel(
        path: wallpaper.path,
        createdAt: wallpaper.createdAt,
        colorHex: wallpaper.colorHex,
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'createdAt': createdAt.toIso8601String(),
        'colorHex': colorHex,
      };

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => WallpaperModel(
        path: json['path'],
        createdAt: DateTime.parse(json['createdAt']),
        colorHex: json['colorHex'] as String?,
      );
}