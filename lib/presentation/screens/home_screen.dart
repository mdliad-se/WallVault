import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import '../search/wallpaper_search_delegate.dart';
import '../widgets/wavy_progress_bar.dart';
import 'preview_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  String? _selectedAlbum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141417),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wallpaper_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                      const SizedBox(width: 12),
                      const Text('WallStash', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white70, size: 28),
                        onPressed: () {
                          showSearch(context: context, delegate: WallpaperSearchDelegate());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() { _currentTab = 0; _selectedAlbum = null; }),
                    child: Column(
                      children: [
                        Text('Explore', style: TextStyle(color: _currentTab == 0 ? Colors.white : Colors.white54, fontSize: 16, fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.w600)),
                        const SizedBox(height: 6),
                        if (_currentTab == 0) Container(width: 40, height: 3, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2))),
                        if (_currentTab != 0) const SizedBox(height: 3),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() { _currentTab = 1; _selectedAlbum = null; }),
                    child: Column(
                      children: [
                        Text('Collections', style: TextStyle(color: _currentTab == 1 ? Colors.white : Colors.white54, fontSize: 16, fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.w600)),
                        const SizedBox(height: 6),
                        if (_currentTab == 1) Container(width: 40, height: 3, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2))),
                        if (_currentTab != 1) const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Grid
            Expanded(
              child: Consumer<WallpaperProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (provider.wallpapers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library, size: 84, color: Colors.grey[800]),
                          const SizedBox(height: 16),
                          const Text('Your vault is empty', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (provider.isImporting) ...[
                          WavyProgressBar(progress: provider.importProgress),
                          const SizedBox(height: 16),
                        ],
                        
                        if (_currentTab == 1 && _selectedAlbum != null) ...[
                           Row(
                             children: [
                               IconButton(
                                 icon: const Icon(Icons.arrow_back, color: Colors.white),
                                 onPressed: () => setState(() => _selectedAlbum = null),
                               ),
                               Text(_selectedAlbum!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                             ],
                           ),
                           const SizedBox(height: 8),
                        ],

                        if (_currentTab == 1 && _selectedAlbum == null)
                          Expanded(child: _buildAlbumsGrid(provider))
                        else
                          Expanded(child: _buildWallpapersGrid(provider)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final provider = Provider.of<WallpaperProvider>(context, listen: false);
          await provider.addWallpaperFromGallery();
          if (!context.mounted) return;
        },
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildAlbumsGrid(WallpaperProvider provider) {
    final albumsMap = <String, String>{}; // album name to cover image path
    for (var w in provider.wallpapers) {
      if (w.album != null && !albumsMap.containsKey(w.album)) {
        albumsMap[w.album!] = w.path;
      }
    }

    if (albumsMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 84, color: Colors.grey[800]),
            const SizedBox(height: 16),
            const Text('No collections yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
          ],
        ),
      );
    }

    final albums = albumsMap.keys.toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final coverPath = albumsMap[album]!;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedAlbum = album),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(coverPath), fit: BoxFit.cover, cacheHeight: 400),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      const Icon(Icons.folder, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        album,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWallpapersGrid(WallpaperProvider provider) {
    final displayWallpapers = _currentTab == 1 && _selectedAlbum != null
        ? provider.wallpapers.where((w) => w.album == _selectedAlbum).toList()
        : provider.wallpapers;

    if (displayWallpapers.isEmpty) {
      return Center(
        child: Text(
          _currentTab == 1 ? 'No wallpapers in this album' : 'Your vault is empty', 
          style: const TextStyle(color: Colors.white54, fontSize: 18)
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: displayWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = displayWallpapers[index];
        final hex = wallpaper.colorHex ?? '#2A2A2E';
        final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));

        return Material(
          elevation: 0,
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviewScreen(wallpaper: wallpaper),
                ),
              );
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
    );
  }
}