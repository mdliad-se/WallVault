import '../../data/repositories/wallpaper_repository.dart';

class AddWallpaperFromGallery {
  final WallpaperRepository repository;

  AddWallpaperFromGallery(this.repository);

  Future<void> execute({void Function(int imported, int total)? onProgress}) async {
    return await repository.addWallpaperFromGallery(onProgress: onProgress);
  }
}