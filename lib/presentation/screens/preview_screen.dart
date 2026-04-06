import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/wallpaper.dart' as entity;
import '../providers/wallpaper_provider.dart';

class PreviewScreen extends StatelessWidget {
  final entity.Wallpaper wallpaper;

  const PreviewScreen({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Preview', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _ImageWithErrorHandling(wallpaperPath: wallpaper.path),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(166)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        border: Border.all(color: Colors.white30, width: 1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Wallpaper actions', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              _ActionButton(
                                label: 'Set Home',
                                icon: Icons.home,
                                onTap: () => _setWallpaper(context, wallpaper, 1, 'home'),
                              ),
                              _ActionButton(
                                label: 'Set Lock',
                                icon: Icons.lock,
                                onTap: () => _setWallpaper(context, wallpaper, 2, 'lock'),
                              ),
                              _ActionButton(
                                label: 'Set Both',
                                icon: Icons.smartphone,
                                onTap: () => _setWallpaper(context, wallpaper, 3, 'both'),
                              ),
                              _ActionButton(
                                label: 'Delete',
                                icon: Icons.delete,
                                onTap: () => _deleteWallpaper(context, wallpaper),
                                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
        title: const Text('Delete Wallpaper'),
        content: const Text('Are you sure you want to permanently delete this wallpaper?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirm == true) {
      await Provider.of<WallpaperProvider>(context, listen: false).removeWallpaper(wallpaper);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
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

class _ImageWithErrorHandling extends StatelessWidget {
  final String wallpaperPath;

  const _ImageWithErrorHandling({required this.wallpaperPath});

  @override
  Widget build(BuildContext context) {
    final file = File(wallpaperPath);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!) {
          return _buildError(context, 'Image not found', 'This wallpaper may have been deleted');
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildError(context, 'Failed to load image', error.toString());
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String title, String message) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        Text(
                          'Setting Wallpaper',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: widget.progress),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              builder: (context, progress, child) {
                                return LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${(widget.progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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