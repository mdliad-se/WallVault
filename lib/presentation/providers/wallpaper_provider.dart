import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../domain/entities/wallpaper.dart' as entity;
import '../../domain/usecases/add_wallpaper_from_gallery.dart';
import '../../domain/usecases/delete_wallpaper.dart';
import '../../domain/usecases/get_wallpapers.dart';
import '../../domain/usecases/set_wallpaper.dart';
import '../../domain/usecases/extract_palette.dart';
import '../../domain/usecases/rename_wallpaper.dart';
import '../../domain/usecases/update_wallpaper_album.dart';

class WallpaperProvider with ChangeNotifier {
  final GetWallpapers getWallpapers;
  final AddWallpaperFromGallery addWallpaper;
  final DeleteWallpaper deleteWallpaper;
  final SetWallpaper setWallpaper;
  final ExtractPalette extractPalette;
  final RenameWallpaper renameWallpaper;
  final UpdateWallpaperAlbum updateWallpaperAlbum;

  bool _isExtractingPalettes = false;

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
    required this.extractPalette,
    required this.renameWallpaper,
    required this.updateWallpaperAlbum,
  }) {
    loadWallpapers();
  }

  Future<void> loadWallpapers() async {
    _isLoading = true;
    notifyListeners();
    _wallpapers = await getWallpapers.execute();
    _isLoading = false;
    notifyListeners();
    _startPaletteExtraction();
  }

  Future<void> _startPaletteExtraction() async {
    if (_isExtractingPalettes) return;
    _isExtractingPalettes = true;

    for (int i = 0; i < _wallpapers.length; i++) {
      if (_wallpapers[i].colorHex == null) {
        await extractPalette.execute(_wallpapers[i]);
        // Reload silently to avoid jank, but update list
        _wallpapers = await getWallpapers.execute();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    _isExtractingPalettes = false;
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

  Future<void> updateWallpaperName(entity.Wallpaper wallpaper, String newName) async {
    if (newName.isEmpty || newName == wallpaper.name) return;
    await renameWallpaper.execute(wallpaper, newName);
    await loadWallpapers();
  }

  Future<void> setWallpaperAlbum(entity.Wallpaper wallpaper, String? album) async {
    await updateWallpaperAlbum.execute(wallpaper, album);
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
    
    // Allow UI to draw bottom sheet close and progress indicator before heavy platform call stops main thread
    await Future.delayed(const Duration(milliseconds: 300));

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
}