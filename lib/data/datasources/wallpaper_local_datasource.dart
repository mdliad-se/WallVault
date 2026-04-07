import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/wallpaper_model.dart';

abstract class WallpaperLocalDataSource {
  Future<List<WallpaperModel>> getWallpapers();
  Future<void> addWallpaper(WallpaperModel wallpaper);
  Future<void> updateWallpaper(WallpaperModel wallpaper);
  Future<void> updateWallpaperByOldPath(String oldPath, WallpaperModel wallpaper);
  Future<void> deleteWallpaper(String path);
  Future<void> deleteWallpapers(List<String> paths);
  Future<String> saveImage(File imageFile);
}

class WallpaperLocalDataSourceImpl implements WallpaperLocalDataSource {
  final String _wallpapersFile = 'wallpapers.json';

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getWallpapersFile() async {
    final path = await _getLocalPath();
    return File('$path/$_wallpapersFile');
  }

  @override
  Future<List<WallpaperModel>> getWallpapers() async {
    try {
      final file = await _getWallpapersFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => WallpaperModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addWallpaper(WallpaperModel wallpaper) async {
    final wallpapers = await getWallpapers();
    wallpapers.add(wallpaper);
    await _saveWallpapers(wallpapers);
  }

  @override
  Future<void> updateWallpaper(WallpaperModel wallpaper) async {
    final wallpapers = await getWallpapers();
    final index = wallpapers.indexWhere((w) => w.path == wallpaper.path || w.hash == wallpaper.hash);
    if (index != -1) {
      wallpapers[index] = wallpaper;
      await _saveWallpapers(wallpapers);
    }
  }

  @override
  Future<void> updateWallpaperByOldPath(String oldPath, WallpaperModel wallpaper) async {
    final wallpapers = await getWallpapers();
    final index = wallpapers.indexWhere((w) => w.path == oldPath);
    if (index != -1) {
      wallpapers[index] = wallpaper;
      await _saveWallpapers(wallpapers);
    }
  }

  @override
  Future<void> deleteWallpaper(String path) async {
    final wallpapers = await getWallpapers();
    wallpapers.removeWhere((w) => w.path == path);
    await _saveWallpapers(wallpapers);
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> deleteWallpapers(List<String> paths) async {
    final wallpapers = await getWallpapers();
    wallpapers.removeWhere((w) => paths.contains(w.path));
    await _saveWallpapers(wallpapers);
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _saveWallpapers(List<WallpaperModel> wallpapers) async {
    final file = await _getWallpapersFile();
    final jsonList = wallpapers.map((w) => w.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }
}