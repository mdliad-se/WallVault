import '../entities/wallpaper.dart' as entity;
import '../../data/repositories/wallpaper_repository.dart';

class SetWallpaper {
  final WallpaperRepository repository;

  SetWallpaper(this.repository);

  Future<bool> execute(entity.Wallpaper wallpaper, int location) async {
    return await repository.setWallpaper(wallpaper, location);
  }
}