# 📄 Product Requirements Document (PRD)

## 🧩 Product Name

**WallVault**

------------------------------------------------------------------------

## 🎯 Product Overview

WallVault is a fully offline Flutter Android app for managing a personal
wallpaper collection separate from the system gallery.

------------------------------------------------------------------------

## 🔑 Core Features

-   Import wallpapers from gallery
-   View wallpapers in clean grid
-   Fullscreen preview
-   Set wallpaper (Home / Lock / Both)
-   Delete (single & bulk)

------------------------------------------------------------------------

## 🏗️ App Architecture

### Architecture Pattern

Clean Architecture (recommended)

### Folder Structure

    lib/
     ├── core/
     │    ├── utils/
     │    ├── constants/
     │
     ├── data/
     │    ├── models/
     │    ├── repositories/
     │    ├── datasources/
     │
     ├── domain/
     │    ├── entities/
     │    ├── usecases/
     │
     ├── presentation/
     │    ├── screens/
     │    ├── widgets/
     │    ├── providers/
     │
     ├── main.dart

------------------------------------------------------------------------

### Example Code Snippet

#### Model

``` dart
class WallpaperModel {
  final String path;
  final DateTime createdAt;

  WallpaperModel({
    required this.path,
    required this.createdAt,
  });
}
```

#### Provider (State Management)

``` dart
class WallpaperProvider with ChangeNotifier {
  List<WallpaperModel> _wallpapers = [];

  List<WallpaperModel> get wallpapers => _wallpapers;

  void addWallpaper(WallpaperModel wallpaper) {
    _wallpapers.add(wallpaper);
    notifyListeners();
  }
}
```

------------------------------------------------------------------------

## 🎨 UI/UX (Material 3)

### Home Screen

-   Grid view of wallpapers
-   Floating Action Button (Add)

### Preview Screen

-   Fullscreen image
-   Buttons:
    -   Set Wallpaper
    -   Delete

------------------------------------------------------------------------

## 🖼️ UI Mockups (Text Wireframes)

### Home Screen

    --------------------------------
    | WallVault            ⋮       |
    --------------------------------
    |  🖼️   🖼️   🖼️   🖼️          |
    |  🖼️   🖼️   🖼️   🖼️          |
    |                              |
    |                      ➕       |
    --------------------------------

### Preview Screen

    --------------------------------
    |                              |
    |        (Wallpaper)           |
    |                              |
    --------------------------------
    | [Set]   [Delete]   [More]    |
    --------------------------------

------------------------------------------------------------------------

## ⚙️ Technical Stack

-   Flutter
-   Dart
-   Material 3
-   Provider / Riverpod

------------------------------------------------------------------------

## 📦 MVP Scope

-   Import wallpapers
-   View gallery
-   Preview
-   Set wallpaper
-   Delete

------------------------------------------------------------------------

## 🚀 Future Enhancements

-   Folders
-   Favorites
-   Auto wallpaper changer
-   Editing tools
