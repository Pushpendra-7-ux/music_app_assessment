import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/models/artist_model.dart';
import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/data/mock_data.dart';

/// Provider for [ArtistRepository].
final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  return ArtistRepository();
});

/// Repository responsible for fetching artist and track data.
///
/// Abstracts the data source so views and viewmodels stay decoupled
/// from [MockData]. Swap this with a real API client without touching UI.
class ArtistRepository {
  /// Returns the [ArtistModel] for the given [artistId], or null if not found.
  ArtistModel? getArtistById(String artistId) {
    return MockData.getArtistById(artistId);
  }

  /// Returns all tracks belonging to the given [artistId].
  List<TrackModel> getTracksByArtist(String artistId) {
    return MockData.getTracksByArtist(artistId);
  }
}
