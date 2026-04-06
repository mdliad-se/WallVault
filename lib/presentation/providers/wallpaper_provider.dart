import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../domain/entities/wallpaper.dart' as entity;
import '../../domain/usecases/add_wallpaper_from_gallery.dart';
import '../../domain/usecases/delete_wallpaper.dart';
import '../../domain/usecases/get_wallpapers.dart';
import '../../domain/usecases/set_wallpaper.dart';

class WallpaperProvider with ChangeNotifier {
  final GetWallpapers getWallpapers;
  final AddWallpaperFromGallery addWallpaper;
  final DeleteWallpaper deleteWallpaper;
  final SetWallpaper setWallpaper;

  List<entity.Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  bool _isImporting = false;
  double _importProgress = 0.0;
  bool _isSettingWallpaper = false;
  double _settingProgress = 0.0;
  final Map<String, Color> _colorCache = {};

  List<entity.Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  double get importProgress => _importProgress;
  bool get isSettingWallpaper => _isSettingWallpaper;
  double get settingProgress => _settingProgress;

  WallpaperProvider({
    required this.getWallpapers,
    required this.addWallpaper,
    required this.deleteWallpaper,
    required this.setWallpaper,
  }) {
    loadWallpapers();
  }

  Future<void> loadWallpapers() async {
    _isLoading = true;
    notifyListeners();
    _wallpapers = await getWallpapers.execute();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWallpaperFromGallery() async {
    _isImporting = true;
    _importProgress = 0.0;
    notifyListeners();

    await addWallpaper.execute(onProgress: (imported, total) {
      _importProgress = total > 0 ? imported / total : 0.0;
      notifyListeners();
    });

    _isImporting = false;
    _importProgress = 0.0;
    notifyListeners();

    await loadWallpapers();
  }

  Future<void> removeWallpaper(entity.Wallpaper wallpaper) async {
    await deleteWallpaper.execute(wallpaper);
    await loadWallpapers();
  }

  Future<bool> setAsWallpaper(entity.Wallpaper wallpaper, int location) async {
    _isSettingWallpaper = true;
    _settingProgress = 0.0;
    notifyListeners();

    Timer? progressTimer;
    var completed = false;

    progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (completed) return;
      if (_settingProgress < 0.95) {
        _settingProgress = (_settingProgress + 0.05).clamp(0.0, 0.95);
        notifyListeners();
      }
    });

    try {
      final result = await setWallpaper.execute(wallpaper, location);
      completed = true;
      progressTimer.cancel();
      _settingProgress = 1.0;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 250));
      return result;
    } catch (_) {
      completed = true;
      progressTimer.cancel();
      return false;
    } finally {
      progressTimer.cancel();
      _isSettingWallpaper = false;
      _settingProgress = 0.0;
      notifyListeners();
    }
  }

  Future<Color> getDominantColor(String path) async {
    if (_colorCache.containsKey(path)) {
      return _colorCache[path]!;
    }
    try {
      final imageProvider = FileImage(File(path));
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
        region: const Rect.fromLTRB(0, 0, 200, 200),
        maximumColorCount: 4,
      );
      final color = paletteGenerator.dominantColor?.color ?? paletteGenerator.vibrantColor?.color ?? paletteGenerator.mutedColor?.color ?? Colors.grey[800]!;
      _colorCache[path] = color;
      return color;
    } catch (_) {
      return Colors.grey[800]!;
    }
  }
}