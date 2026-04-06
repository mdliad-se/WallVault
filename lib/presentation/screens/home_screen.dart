import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import 'preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WallVault'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import one or more wallpapers from your gallery, preview them, and delete if needed.')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withAlpha(20), theme.colorScheme.secondary.withAlpha(20)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<WallpaperProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.wallpapers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library, size: 84, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('Your personal wallpaper vault is empty', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the add button to import wallpapers from your gallery.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${provider.wallpapers.length} wallpapers',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text('Offline', style: theme.textTheme.bodySmall),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  if (provider.isImporting) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: provider.importProgress,
                        minHeight: 6,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withAlpha(61),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Importing wallpapers ${ (provider.importProgress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.70, // Taller, Backdrop-like ratio
                      ),
                      itemCount: provider.wallpapers.length,
                      itemBuilder: (context, index) {
                        final wallpaper = provider.wallpapers[index];
                        return Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreviewScreen(wallpaper: wallpaper),
                                ),
                              );
                            },
                            child: FutureBuilder<Color>(
                              future: provider.getDominantColor(wallpaper.path),
                              builder: (context, snapshot) {
                                final color = snapshot.data ?? Theme.of(context).colorScheme.surfaceContainerHighest;
                                final isDarkColor = color.computeLuminance() < 0.5;
                                final textColor = isDarkColor ? Colors.white : Colors.black87;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Image.file(
                                        File(wallpaper.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        color: color,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Vault Image',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    wallpaper.createdAt.toLocal().toString().split(' ').first,
                                                    style: TextStyle(
                                                      color: textColor.withAlpha(200),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.open_in_full, size: 20, color: textColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = Provider.of<WallpaperProvider>(context, listen: false);
          await provider.addWallpaperFromGallery();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wallpapers imported successfully.')),
          );
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Wallpapers'),
      ),
    );
  }
}