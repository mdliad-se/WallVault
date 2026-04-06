import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import 'preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141417),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Wallpaper Vault', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70, size: 28),
                      const SizedBox(width: 16),
                      CircleAvatar(radius: 16, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, size: 20, color: Colors.white)),
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
                  Column(
                    children: [
                      const Text('Explore', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(width: 40, height: 3, decoration: BoxDecoration(color: const Color(0xFFE47C56), borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                  const Text('Collections', style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600)),
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
                      children: [
                        if (provider.isImporting) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: provider.importProgress,
                              minHeight: 4,
                              color: const Color(0xFFE47C56),
                              backgroundColor: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: provider.wallpapers.length,
                            itemBuilder: (context, index) {
                              final wallpaper = provider.wallpapers[index];
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
                                                    const Text(
                                                      'Vault Image',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      wallpaper.createdAt.toLocal().toString().split(' ').first,
                                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                    ),
                                                    const Spacer(),
                                                    const Text(
                                                      'Local Wallpaper',
                                                      style: TextStyle(color: Colors.white, fontSize: 13),
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
                        ),
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
        backgroundColor: const Color(0xFFE47C56),
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
}