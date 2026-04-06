import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper/flutter_wallpaper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/wallpaper.dart' as entity;
import '../datasources/wallpaper_local_datasource.dart';
import '../models/wallpaper_model.dart';

abstract class WallpaperRepository {
  Future<List<entity.Wallpaper>> getWallpapers();
  Future<void> addWallpaperFromGallery({void Function(int imported, int total)? onProgress});
  Future<void> renameWallpaper(entity.Wallpaper wallpaper, String newName);
  Future<void> updateWallpaperAlbum(entity.Wallpaper wallpaper, String? albumName);
  Future<void> deleteWallpaper(entity.Wallpaper wallpaper);
  Future<void> deleteWallpapers(List<entity.Wallpaper> wallpapers);
  Future<bool> setWallpaper(entity.Wallpaper wallpaper, int location);
  Future<void> extractPalette(entity.Wallpaper wallpaper);
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
      final existingWallpapers = await localDataSource.getWallpapers();
      final existingHashes = existingWallpapers.map((w) => w.hash).toSet();

      for (final pickedFile in pickedFiles) {
        try {
          final imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            final bytes = await imageFile.readAsBytes();
            final fileHash = sha256.convert(bytes).toString();

            if (existingHashes.contains(fileHash)) {
              imported++;
              onProgress?.call(imported, total);
              continue;
            }

            final savedPath = await localDataSource.saveImage(imageFile);
            final wallpaper = WallpaperModel(
              path: savedPath,
              createdAt: DateTime.now(),
              hash: fileHash,
              name: 'Vault Image',
            );
            await localDataSource.addWallpaper(wallpaper);
            existingHashes.add(fileHash);
          }
        } catch (_) {
          // Skip this file if there's an error and continue with next
        } finally {
          if (!existingHashes.contains(pickedFile.name)) {
            imported++;
          }
          onProgress?.call(imported, total);
        }
      }
    }
  }

  @override
  Future<void> renameWallpaper(entity.Wallpaper wallpaper, String newName) async {
    final ext = p.extension(wallpaper.path);
    final dir = p.dirname(wallpaper.path);
    final newPath = p.join(dir, '$newName$ext');
    final oldFile = File(wallpaper.path);
    if (await oldFile.exists()) {
      await oldFile.rename(newPath);
    }
    final model = WallpaperModel.fromEntity(wallpaper);
    final updatedModel = WallpaperModel(
      path: newPath,
      createdAt: model.createdAt,
      hash: model.hash,
      name: newName,
      colorHex: model.colorHex,
      album: model.album,
    );
    await localDataSource.updateWallpaper(updatedModel);
  }

  @override
  Future<void> updateWallpaperAlbum(entity.Wallpaper wallpaper, String? albumName) async {
    final model = WallpaperModel.fromEntity(wallpaper);
    final updatedModel = WallpaperModel(
      path: model.path,
      createdAt: model.createdAt,
      hash: model.hash,
      name: model.name,
      colorHex: model.colorHex,
      album: albumName,
    );
    await localDataSource.updateWallpaper(updatedModel);
  }

  @override
  Future<void> extractPalette(entity.Wallpaper wallpaper) async {
    if (wallpaper.colorHex != null) return;
    try {
      final imageProvider = FileImage(File(wallpaper.path));
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
        region: const Rect.fromLTRB(0, 0, 200, 200),
        maximumColorCount: 4,
      );
      final color = paletteGenerator.dominantColor?.color ?? paletteGenerator.vibrantColor?.color ?? paletteGenerator.mutedColor?.color ?? Colors.grey[800]!;
      final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}'; 

      final model = WallpaperModel.fromEntity(wallpaper);
      final updatedModel = WallpaperModel(
        path: model.path,
        createdAt: model.createdAt,
        hash: model.hash,
        name: model.name,
        colorHex: colorHex,
        album: model.album,
      );
      await localDataSource.updateWallpaper(updatedModel);
    } catch (_) {}
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