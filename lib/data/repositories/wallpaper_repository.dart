import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wallpaper/flutter_wallpaper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../domain/entities/wallpaper.dart' as entity;
import '../datasources/wallpaper_local_datasource.dart';
import '../models/wallpaper_model.dart';

abstract class WallpaperRepository {
  Future<List<entity.Wallpaper>> getWallpapers();
  Future<void> addWallpaperFromGallery({void Function(int imported, int total)? onProgress});
  Future<void> deleteWallpaper(entity.Wallpaper wallpaper);
  Future<void> deleteWallpapers(List<entity.Wallpaper> wallpapers);
  Future<bool> setWallpaper(entity.Wallpaper wallpaper, int location);
}

class WallpaperRepositoryImpl implements WallpaperRepository {
  final WallpaperLocalDataSource localDataSource;

  WallpaperRepositoryImpl(this.localDataSource);

  @override
  Future<List<entity.Wallpaper>> getWallpapers() async {
    final models = await localDataSource.getWallpapers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addWallpaperFromGallery({void Function(int imported, int total)? onProgress}) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final total = pickedFiles.length;
      var imported = 0;

      for (final pickedFile in pickedFiles) {
        try {
          final imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            final savedPath = await localDataSource.saveImage(imageFile);
            
            String? colorHex;
            try {
              final imageProvider = FileImage(File(savedPath));
              final paletteGenerator = await PaletteGenerator.fromImageProvider(
                imageProvider,
                size: const Size(200, 200),
                region: const Rect.fromLTRB(0, 0, 200, 200),
                maximumColorCount: 4,
              );
              final color = paletteGenerator.dominantColor?.color ?? paletteGenerator.vibrantColor?.color ?? paletteGenerator.mutedColor?.color ?? Colors.grey[800]!;
              colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}'; 
            } catch (_) {}

            final wallpaper = WallpaperModel(path: savedPath, createdAt: DateTime.now(), colorHex: colorHex);
            await localDataSource.addWallpaper(wallpaper);
          }
        } catch (_) {
          // Skip this file if there's an error and continue with next
        } finally {
          imported++;
          onProgress?.call(imported, total);
        }
      }
    }
  }

  @override
  Future<void> deleteWallpaper(entity.Wallpaper wallpaper) async {
    await localDataSource.deleteWallpaper(wallpaper.path);
  }

  @override
  Future<void> deleteWallpapers(List<entity.Wallpaper> wallpapers) async {
    final paths = wallpapers.map((w) => w.path).toList();
    await localDataSource.deleteWallpapers(paths);
  }

  @override
  Future<bool> setWallpaper(entity.Wallpaper wallpaper, int location) async {
    try {
      return await WallpaperManager.setWallpaperFromFile(wallpaper.path, location);
    } catch (_) {
      return false;
    }
  }
}