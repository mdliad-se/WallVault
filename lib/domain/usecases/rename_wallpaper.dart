import '../entities/wallpaper.dart';
import '../../data/repositories/wallpaper_repository.dart';

class RenameWallpaper {
  final WallpaperRepository repository;

  RenameWallpaper(this.repository);

  Future<void> execute(Wallpaper wallpaper, String newName) async {
    return await repository.renameWallpaper(wallpaper, newName);
  }
}
