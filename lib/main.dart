import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/wallpaper_local_datasource.dart';
import 'data/repositories/wallpaper_repository.dart';
import 'domain/usecases/add_wallpaper_from_gallery.dart';
import 'domain/usecases/delete_wallpaper.dart';
import 'domain/usecases/get_wallpapers.dart';
import 'domain/usecases/set_wallpaper.dart';
import 'presentation/providers/wallpaper_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WallpaperLocalDataSource>(
          create: (_) => WallpaperLocalDataSourceImpl(),
        ),
        Provider<WallpaperRepository>(
          create: (context) => WallpaperRepositoryImpl(
            Provider.of<WallpaperLocalDataSource>(context, listen: false),
          ),
        ),
        Provider<GetWallpapers>(
          create: (context) => GetWallpapers(
            Provider.of<WallpaperRepository>(context, listen: false),
          ),
        ),
        Provider<AddWallpaperFromGallery>(
          create: (context) => AddWallpaperFromGallery(
            Provider.of<WallpaperRepository>(context, listen: false),
          ),
        ),
        Provider<DeleteWallpaper>(
          create: (context) => DeleteWallpaper(
            Provider.of<WallpaperRepository>(context, listen: false),
          ),
        ),
        Provider<SetWallpaper>(
          create: (context) => SetWallpaper(
            Provider.of<WallpaperRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<WallpaperProvider>(
          create: (context) => WallpaperProvider(
            getWallpapers: Provider.of<GetWallpapers>(context, listen: false),
            addWallpaper: Provider.of<AddWallpaperFromGallery>(context, listen: false),
            deleteWallpaper: Provider.of<DeleteWallpaper>(context, listen: false),
            setWallpaper: Provider.of<SetWallpaper>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WallVault',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
