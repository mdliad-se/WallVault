import '../entities/wallpaper.dart';
import '../../data/repositories/wallpaper_repository.dart';

class UpdateWallpaperAlbum {
  final WallpaperRepository repository;

  UpdateWallpaperAlbum(this.repository);

  Future<void> execute(Wallpaper wallpaper, String? album) async {
    return await repository.updateWallpaperAlbum(wallpaper, album);
  }
}
