import '../entities/wallpaper.dart' as entity;
import '../../data/repositories/wallpaper_repository.dart';

class DeleteWallpaper {
  final WallpaperRepository repository;

  DeleteWallpaper(this.repository);

  Future<void> execute(entity.Wallpaper wallpaper) async {
    return await repository.deleteWallpaper(wallpaper);
  }
}