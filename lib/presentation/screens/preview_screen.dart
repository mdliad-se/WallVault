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
    return Scaffold(
      backgroundColor: const Color(0xFF141417), // Rich dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<Color>(
        future: Provider.of<WallpaperProvider>(context, listen: false).getDominantColor(wallpaper.path),
        builder: (context, snapshot) {
          final domColor = snapshot.data ?? const Color(0xFFD89B9B); // Fallback pinkish color
          final isDark = domColor.computeLuminance() < 0.5;
          final textColor = isDark ? Colors.white : Colors.black87;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight, 
                  left: 20,
                  right: 20,
                  bottom: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Header
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        File(wallpaper.path),
                        height: MediaQuery.of(context).size.height * 0.48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: MediaQuery.of(context).size.height * 0.48,
                          color: Colors.grey[900],
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: domColor,
                             shape: BoxShape.circle,
                           ),
                           child: Icon(Icons.wallpaper, color: textColor, size: 24),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text(
                                 'Vault Image',
                                 style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                               ),
                               const SizedBox(height: 2),
                               Text(
                                 'Local Storage',
                                 style: TextStyle(color: domColor, fontSize: 13, fontWeight: FontWeight.w600),
                               ),
                             ],
                           ),
                         ),
                         Icon(Icons.verified, color: domColor, size: 20),
                         const SizedBox(width: 16),
                         const Icon(Icons.favorite_border, color: Colors.white, size: 26),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: domColor.withAlpha(200), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: () => _deleteWallpaper(context, wallpaper),
                            icon: Icon(Icons.delete_outline, color: domColor),
                            label: const Text('Delete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: domColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: const Color(0xFF1E1E22),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                                builder: (context) => _buildSetOptions(context, domColor, textColor),
                              );
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Set', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    
                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'A little bit of peace, a little bit of offline privacy. Store and set your wallpapers entirely separated from your main gallery.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Stats Grid
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: FutureBuilder<double>(
                        future: File(wallpaper.path).length().then((v) => v / (1024 * 1024)),
                        builder: (context, sizeSnapshot) {
                          final sizeMB = sizeSnapshot.data?.toStringAsFixed(2) ?? '-.--';
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: domColor, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Added: ${wallpaper.createdAt.toLocal().toString().split(' ').first}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                  Icon(Icons.folder, color: domColor, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('$sizeMB MB', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: domColor, size: 20),
                                  const SizedBox(width: 12),
                                  const Expanded(child: Text('All Rights Reserved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.underline))),
                                  Icon(Icons.error_outline, color: domColor, size: 20),
                                  const SizedBox(width: 12),
                                  const Expanded(child: Text('Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.underline))),
                                ],
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
          );
        },
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