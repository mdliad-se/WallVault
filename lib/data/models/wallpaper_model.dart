import '../../domain/entities/wallpaper.dart';

class WallpaperModel {
  final String path;
  final DateTime createdAt;

  WallpaperModel({
    required this.path,
    required this.createdAt,
  });

  Wallpaper toEntity() => Wallpaper(path: path, createdAt: createdAt);

  factory WallpaperModel.fromEntity(Wallpaper wallpaper) => WallpaperModel(
        path: wallpaper.path,
        createdAt: wallpaper.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => WallpaperModel(
        path: json['path'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}