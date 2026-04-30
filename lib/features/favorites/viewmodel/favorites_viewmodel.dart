import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the list of favorite track IDs.
/// Persists favorites to SharedPreferences so they survive app restarts.
class FavoritesViewmodel extends StateNotifier<Set<String>> {
  FavoritesViewmodel() : super({}) {
    _loadFavorites();
  }

  static const _favKey = 'favorite_track_ids';

  /// Load saved favorites from local storage
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_favKey) ?? [];
    state = savedIds.toSet();
  }

  /// Toggle a track's favorite status
  Future<void> toggleFavorite(String trackId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(trackId)) {
      updated.remove(trackId);
    } else {
      updated.add(trackId);
    }
    state = updated;
    await _saveFavorites();
  }

  /// Check if a track is favorited
  bool isFavorite(String trackId) => state.contains(trackId);

  /// Persist favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, state.toList());
  }
}

final favoritesViewmodelProvider =
    StateNotifierProvider<FavoritesViewmodel, Set<String>>((ref) {
  return FavoritesViewmodel();
});
