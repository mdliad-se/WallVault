import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import '../screens/preview_screen.dart';

class WallpaperSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141417),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search wallpapers or albums...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final provider = Provider.of<WallpaperProvider>(context);
    final results = provider.wallpapers.where((w) {
      final nameMatches = w.name.toLowerCase().contains(query.toLowerCase());
      final albumMatches = w.album?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return nameMatches || albumMatches;
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: const Color(0xFF141417),
        child: const Center(
          child: Text('No wallpapers found', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      );
    }

    return Container(
      color: const Color(0xFF141417),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final wallpaper = results[index];
          final hex = wallpaper.colorHex ?? '#2A2A2E';
          final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));

          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(wallpaper: wallpaper)));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Image.file(
                        File(wallpaper.path),
                        fit: BoxFit.cover,
                        cacheHeight: 800,
                        errorBuilder: (context, error, stack) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: color,
                        padding: const EdgeInsets.all(12),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallpaper.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  wallpaper.createdAt.toLocal().toString().split(' ').first,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  wallpaper.album ?? 'Local Wallpaper',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(Icons.open_in_full, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
