import '../entities/wallpaper.dart' as entity;
import '../../data/repositories/wallpaper_repository.dart';

class GetWallpapers {
  final WallpaperRepository repository;

  GetWallpapers(this.repository);

  Future<List<entity.Wallpaper>> execute() async {
    return await repository.getWallpapers();
  }
}