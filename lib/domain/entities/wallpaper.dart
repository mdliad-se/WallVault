class Wallpaper {
  final String path;
  final DateTime createdAt;
  final String? colorHex;
  final String hash;
  final String name;
  final String? album;

  Wallpaper({
    required this.path,
    required this.createdAt,
    required this.hash,
    required this.name,
    this.colorHex,
    this.album,
  });
}