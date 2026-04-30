import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/data/mock_data.dart';

/// Provider for [HomeRepository].
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

/// Repository responsible for fetching and searching tracks.
///
/// Abstracts the data source (mock data here) so the viewmodel
/// stays decoupled from the data layer.
class HomeRepository {
  /// Simulates fetching tracks from an API.
  /// Adds a small delay to mimic network latency.
  Future<List<TrackModel>> fetchTracks() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.tracks;
  }

  /// Filter tracks by a search query across title, artist, and album.
  List<TrackModel> searchTracks(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return MockData.tracks;
    return MockData.tracks.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.artistName.toLowerCase().contains(q) ||
          t.album.toLowerCase().contains(q);
    }).toList();
  }
}
