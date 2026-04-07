import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF141417),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Appearance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Accent Color', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: ThemeProvider.themeColors.map((color) {
              final isSelected = themeProvider.accentColor.value == color.value;
              return GestureDetector(
                onTap: () => themeProvider.setAccentColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.transparent),
                    boxShadow: isSelected ? [BoxShadow(color: color.withAlpha(150), blurRadius: 10, spreadRadius: 2)] : [],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          const Text('About', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: Colors.white70),
            title: Text('WallStash', style: TextStyle(color: Colors.white)),
            subtitle: Text('Offline wallpaper manager', style: TextStyle(color: Colors.white54)),
            trailing: Text('v1.0.0', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
