import '../../domain/entities/wallpaper.dart';

class WallpaperModel {
  final String path;
  final DateTime createdAt;
  final String? colorHex;
  final String hash;
  final String name;
  final String? album;

  WallpaperModel({
    required this.path,
    required this.createdAt,
    required this.hash,
    required this.name,
    this.colorHex,
    this.album,
  });

  Wallpaper toEntity() => Wallpaper(
        path: path,
        createdAt: createdAt,
        hash: hash,
        name: name,
        colorHex: colorHex,
        album: album,
      );

  factory WallpaperModel.fromEntity(Wallpaper wallpaper) => WallpaperModel(
        path: wallpaper.path,
        createdAt: wallpaper.createdAt,
        hash: wallpaper.hash,
        name: wallpaper.name,
        colorHex: wallpaper.colorHex,
        album: wallpaper.album,
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'createdAt': createdAt.toIso8601String(),
        'hash': hash,
        'name': name,
        'colorHex': colorHex,
        'album': album,
      };

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => WallpaperModel(
        path: json['path'],
        createdAt: DateTime.parse(json['createdAt']),
        hash: json['hash'] ?? '',
        name: json['name'] ?? 'Vault Image',
        colorHex: json['colorHex'] as String?,
        album: json['album'] as String?,
      );
}