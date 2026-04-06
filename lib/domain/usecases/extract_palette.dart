import '../entities/wallpaper.dart';
import '../../data/repositories/wallpaper_repository.dart';

class ExtractPalette {
  final WallpaperRepository repository;

  ExtractPalette(this.repository);

  Future<void> execute(Wallpaper wallpaper) async {
    return await repository.extractPalette(wallpaper);
  }
}
