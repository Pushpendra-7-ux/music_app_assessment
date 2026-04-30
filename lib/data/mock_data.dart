import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/core/models/artist_model.dart';

/// Static mock data simulating a remote API response.
///
/// In a production app, this would be replaced by actual API calls.
/// Tracks reference locally bundled audio assets for reliable playback.
class MockData {
  MockData._(); // prevent instantiation

  // ── ARTISTS ──

  static const List<ArtistModel> artists = [
    ArtistModel(
      id: 'artist_1',
      name: 'Luna Wave',
      bio:
          'Luna Wave is an electronic music producer known for blending ambient textures with driving beats. Based in Berlin, she has been crafting soundscapes since 2018 and has performed at festivals across Europe.',
      imageUrl: 'https://picsum.photos/seed/lunawave/400/400',
      monthlyListeners: 284500,
    ),
    ArtistModel(
      id: 'artist_2',
      name: 'The Midnight Sons',
      bio:
          'A four-piece indie rock band from Austin, Texas. Their sound combines classic rock energy with modern production. Known for their electrifying live performances and heartfelt lyrics.',
      imageUrl: 'https://picsum.photos/seed/midnightsons/400/400',
      monthlyListeners: 512300,
    ),
    ArtistModel(
      id: 'artist_3',
      name: 'Aria Chen',
      bio:
          'Singer-songwriter Aria Chen blends jazz influences with contemporary pop. A classically trained pianist, she brings a unique depth to her compositions that has earned her critical acclaim.',
      imageUrl: 'https://picsum.photos/seed/ariachen/400/400',
      monthlyListeners: 178900,
    ),
    ArtistModel(
      id: 'artist_4',
      name: 'Neon Pulse',
      bio:
          'Neon Pulse is a synthwave duo creating retro-futuristic music inspired by 80s cinema. Their tracks feature pulsing basslines, shimmering synths, and nostalgic melodies.',
      imageUrl: 'https://picsum.photos/seed/neonpulse/400/400',
      monthlyListeners: 395200,
    ),
  ];

  // ── TRACKS ──

  static const List<TrackModel> tracks = [
    TrackModel(
      id: 'track_1',
      title: 'Midnight Drive',
      artistName: 'Luna Wave',
      artistId: 'artist_1',
      albumArtUrl: 'https://picsum.photos/seed/albumart1/300/300',
      audioUrl: 'asset:///assets/audio/track_01.mp3',
      duration: Duration(minutes: 3, seconds: 42),
      album: 'Neon Horizons',
    ),
    TrackModel(
      id: 'track_2',
      title: 'Electric Sunset',
      artistName: 'Luna Wave',
      artistId: 'artist_1',
      albumArtUrl: 'https://picsum.photos/seed/albumart2/300/300',
      audioUrl: 'asset:///assets/audio/track_02.mp3',
      duration: Duration(minutes: 4, seconds: 15),
      album: 'Neon Horizons',
    ),
    TrackModel(
      id: 'track_3',
      title: 'Broken Highway',
      artistName: 'The Midnight Sons',
      artistId: 'artist_2',
      albumArtUrl: 'https://picsum.photos/seed/albumart3/300/300',
      audioUrl: 'asset:///assets/audio/track_03.mp3',
      duration: Duration(minutes: 3, seconds: 58),
      album: 'Road Less Taken',
    ),
    TrackModel(
      id: 'track_4',
      title: 'City Lights',
      artistName: 'The Midnight Sons',
      artistId: 'artist_2',
      albumArtUrl: 'https://picsum.photos/seed/albumart4/300/300',
      audioUrl: 'asset:///assets/audio/track_04.mp3',
      duration: Duration(minutes: 4, seconds: 30),
      album: 'Road Less Taken',
    ),
    TrackModel(
      id: 'track_5',
      title: 'Velvet Dreams',
      artistName: 'Aria Chen',
      artistId: 'artist_3',
      albumArtUrl: 'https://picsum.photos/seed/albumart5/300/300',
      audioUrl: 'asset:///assets/audio/track_05.mp3',
      duration: Duration(minutes: 3, seconds: 20),
      album: 'Quiet Storms',
    ),
    TrackModel(
      id: 'track_6',
      title: 'Rainy Café',
      artistName: 'Aria Chen',
      artistId: 'artist_3',
      albumArtUrl: 'https://picsum.photos/seed/albumart6/300/300',
      audioUrl: 'asset:///assets/audio/track_06.mp3',
      duration: Duration(minutes: 5, seconds: 10),
      album: 'Quiet Storms',
    ),
    TrackModel(
      id: 'track_7',
      title: 'Neon Skyline',
      artistName: 'Neon Pulse',
      artistId: 'artist_4',
      albumArtUrl: 'https://picsum.photos/seed/albumart7/300/300',
      audioUrl: 'asset:///assets/audio/track_07.mp3',
      duration: Duration(minutes: 4, seconds: 45),
      album: 'Retro Future',
    ),
    TrackModel(
      id: 'track_8',
      title: 'Chrome Hearts',
      artistName: 'Neon Pulse',
      artistId: 'artist_4',
      albumArtUrl: 'https://picsum.photos/seed/albumart8/300/300',
      audioUrl: 'asset:///assets/audio/track_08.mp3',
      duration: Duration(minutes: 3, seconds: 55),
      album: 'Retro Future',
    ),
    TrackModel(
      id: 'track_9',
      title: 'Fading Echoes',
      artistName: 'The Midnight Sons',
      artistId: 'artist_2',
      albumArtUrl: 'https://picsum.photos/seed/albumart9/300/300',
      audioUrl: 'asset:///assets/audio/track_09.mp3',
      duration: Duration(minutes: 4, seconds: 8),
      album: 'Afterglow',
    ),
    TrackModel(
      id: 'track_10',
      title: 'Digital Rain',
      artistName: 'Luna Wave',
      artistId: 'artist_1',
      albumArtUrl: 'https://picsum.photos/seed/albumart10/300/300',
      audioUrl: 'asset:///assets/audio/track_10.mp3',
      duration: Duration(minutes: 5, seconds: 32),
      album: 'After Dark',
    ),
  ];

  // ── QUERIES ──

  /// Returns the artist model for a given artist ID, or null if not found.
  static ArtistModel? getArtistById(String artistId) {
    try {
      return artists.firstWhere((a) => a.id == artistId);
    } catch (_) {
      return null;
    }
  }

  /// Returns all tracks belonging to a specific artist.
  static List<TrackModel> getTracksByArtist(String artistId) {
    return tracks.where((t) => t.artistId == artistId).toList();
  }
}
