class TrackModel {
  final String id;
  final String title;
  final String artistName;
  final String artistId;
  final String albumArtUrl;
  final String audioUrl;
  final Duration duration;
  final String album;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistId,
    required this.albumArtUrl,
    required this.audioUrl,
    required this.duration,
    this.album = '',
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artist_name'] as String,
      artistId: json['artist_id'] as String,
      albumArtUrl: json['album_art_url'] as String,
      audioUrl: json['audio_url'] as String,
      duration: Duration(seconds: json['duration_seconds'] as int),
      album: json['album'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': artistName,
      'artist_id': artistId,
      'album_art_url': albumArtUrl,
      'audio_url': audioUrl,
      'duration_seconds': duration.inSeconds,
      'album': album,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
