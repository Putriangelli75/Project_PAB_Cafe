import 'package:aplikasi_cafe/models/cafe.dart';

class FavoriteManager {
  static final List<Cafe> _favoriteCafes = [];

  static List<Cafe> get favoriteCafes => List.from(_favoriteCafes);

  static void toggleFavorite(Cafe cafe) {
    if (isFavorite(cafe)) {
      _favoriteCafes.removeWhere((c) => c.name == cafe.name);
    } else {
      _favoriteCafes.add(cafe);
    }
  }

  static bool isFavorite(Cafe cafe) {
    return _favoriteCafes.any((c) => c.name == cafe.name);
  }

  static void addToFavorites(Cafe cafe) {
    if (!isFavorite(cafe)) {
      _favoriteCafes.add(cafe);
    }
  }

  static void removeFromFavorites(Cafe cafe) {
    _favoriteCafes.removeWhere((c) => c.name == cafe.name);
  }
}