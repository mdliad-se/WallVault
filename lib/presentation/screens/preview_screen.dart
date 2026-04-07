import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/wallpaper.dart' as entity;
import '../providers/wallpaper_provider.dart';
import '../widgets/wavy_progress_bar.dart';

class PreviewScreen extends StatelessWidget {
  final entity.Wallpaper wallpaper;

  const PreviewScreen({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    final hex = wallpaper.colorHex ?? '#E47C56';
    final domColor = Color(int.parse(hex.replaceFirst('#', '0xFF')));
    final isDark = domColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFF141417),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 20, 
              left: 20,
              right: 20,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Floating Curved Image
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: domColor.withAlpha(30), blurRadius: 40, offset: const Offset(0, 10))
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.file(
                      File(wallpaper.path),
                      height: MediaQuery.of(context).size.height * 0.45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        color: Colors.grey[900],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title Banner Row
                GestureDetector(
                  onTap: () => _renameWallpaper(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: domColor, width: 4),
                          boxShadow: [
                            BoxShadow(color: domColor.withAlpha(100), blurRadius: 10, spreadRadius: 2)
                          ]
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        wallpaper.name,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, color: Colors.white54, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Action Buttons (Asymmetrical Pills) -> Now Three Buttons
                Row(
                  children: [
                    // SET Button
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: domColor,
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFF1E1E22),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                            builder: (context) => _buildSetOptions(context, domColor, textColor),
                          );
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('SET', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ALBUM Button
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _setAlbum(context),
                        icon: const Icon(Icons.folder, size: 18),
                        label: const Text('ALBUM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // DELETE Button
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: domColor,
                          side: BorderSide(color: domColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _deleteWallpaper(context, wallpaper),
                        icon: Icon(Icons.delete, color: domColor, size: 18),
                        label: Text('DEL', style: TextStyle(color: domColor, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Bottom Statistics Block
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: FutureBuilder<double>(
                    future: File(wallpaper.path).length().then((v) => v / (1024 * 1024)),
                    builder: (context, sizeSnapshot) {
                      final sizeMB = sizeSnapshot.data?.toStringAsFixed(1) ?? '-.-';
                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.insert_drive_file, color: Colors.white54, size: 24),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('File Size:', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('$sizeMB MB', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: Colors.white24),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white54, size: 24),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date Added:', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      wallpaper.createdAt.toLocal().toString().split(' ').first,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          Consumer<WallpaperProvider>(
            builder: (context, provider, _) {
              if (provider.isSettingWallpaper) {
                return _WallpaperProgressDialog(progress: provider.settingProgress);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetOptions(BuildContext context, Color domColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          _ActionButton(label: 'Set Home Screen', icon: Icons.home, onTap: () { Navigator.pop(context); _setWallpaper(context, wallpaper, 1, 'home'); }, style: FilledButton.styleFrom(backgroundColor: domColor, foregroundColor: textColor, minimumSize: const Size(double.infinity, 56))),
          const SizedBox(height: 12),
          _ActionButton(label: 'Set Lock Screen', icon: Icons.lock, onTap: () { Navigator.pop(context); _setWallpaper(context, wallpaper, 2, 'lock'); }, style: FilledButton.styleFrom(backgroundColor: domColor, foregroundColor: textColor, minimumSize: const Size(double.infinity, 56))),
          const SizedBox(height: 12),
          _ActionButton(label: 'Set Both', icon: Icons.smartphone, onTap: () { Navigator.pop(context); _setWallpaper(context, wallpaper, 3, 'both'); }, style: FilledButton.styleFrom(backgroundColor: domColor, foregroundColor: textColor, minimumSize: const Size(double.infinity, 56))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Future<void> _setWallpaper(BuildContext context, entity.Wallpaper wallpaper, int location, String label) async {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    final success = await provider.setAsWallpaper(wallpaper, location);
    if (!context.mounted) return;
    final message = success ? 'Wallpaper set to $label.' : 'Failed to set $label wallpaper.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteWallpaper(BuildContext context, entity.Wallpaper wallpaper) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Delete Wallpaper', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to permanently delete this wallpaper?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirm == true) {
      await Provider.of<WallpaperProvider>(context, listen: false).removeWallpaper(wallpaper);
      if (!context.mounted) return;
      Navigator.pop(context); // Go back home
    }
  }

  Future<void> _renameWallpaper(BuildContext context) async {
    final controller = TextEditingController(text: wallpaper.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Rename Wallpaper', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save', style: TextStyle(color: Color(0xFFE47C56)))),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != wallpaper.name && context.mounted) {
      final provider = Provider.of<WallpaperProvider>(context, listen: false);
      await provider.updateWallpaperName(wallpaper, newName.trim());
      if (context.mounted) {
        Navigator.pop(context); // Refresh preview screen text by returning to home, or leave it (but provider update won't auto-refresh PreviewScreen if it's statelessly receiving 'wallpaper' param).
        // Actually since we don't automatically rebuild PreviewScreen with the new entity, popping is safer.
      }
    }
  }

  Future<void> _setAlbum(BuildContext context) async {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    final albums = provider.wallpapers.map((w) => w.album).where((a) => a != null).map((e) => e!).toSet().toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(horizontal: 140), decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Add to Album', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (albums.isNotEmpty) ...[
              const Text('Existing Albums', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: albums.map((album) => ActionChip(
                  label: Text(album, style: const TextStyle(color: Colors.white)),
                  backgroundColor: wallpaper.album == album ? const Color(0xFFE47C56) : Colors.white10,
                  onPressed: () async {
                    Navigator.pop(context);
                    await provider.setWallpaperAlbum(wallpaper, album);
                    if (context.mounted) Navigator.pop(context);
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE47C56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final controller = TextEditingController();
                final newAlbum = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1C1E),
                    title: const Text('New Album', style: TextStyle(color: Colors.white)),
                    content: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter album name',
                        hintStyle: TextStyle(color: Colors.white54),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE47C56))),
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                      TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create', style: TextStyle(color: Color(0xFFE47C56)))),
                    ],
                  ),
                );
                
                if (newAlbum != null && newAlbum.isNotEmpty && context.mounted) {
                  await provider.setWallpaperAlbum(wallpaper, newAlbum.trim());
                  if (context.mounted) Navigator.pop(context); // Refresh preview screen
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Album'),
            ),
            if (wallpaper.album != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await provider.setWallpaperAlbum(wallpaper, null);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                label: const Text('Remove from Album'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ButtonStyle? style;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: style,
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _WallpaperProgressDialog extends StatefulWidget {
  final double progress;

  const _WallpaperProgressDialog({required this.progress});

  @override
  State<_WallpaperProgressDialog> createState() => _WallpaperProgressDialogState();
}

class _WallpaperProgressDialogState extends State<_WallpaperProgressDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withAlpha(128),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  color: const Color(0xFF1E1E22),
                  elevation: 24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wallpaper,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Setting Wallpaper',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.progress),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          builder: (context, progress, child) {
                            return WavyProgressBar(
                              progress: progress,
                              height: 12,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${(widget.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}