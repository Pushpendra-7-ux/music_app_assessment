import 'package:music_app/core/models/track_model.dart';

/// Immutable state class for the music player.
///
/// Holds the current track, playback position, queue, and UI flags.
/// Used by [PlayerViewmodel] as the state type.
class PlayerState {
  final TrackModel? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffled;
  final List<TrackModel> queue;
  final int currentIndex;
  final bool isLoading;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffled = false,
    this.queue = const [],
    this.currentIndex = -1,
    this.isLoading = false,
  });

  PlayerState copyWith({
    TrackModel? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffled,
    List<TrackModel>? queue,
    int? currentIndex,
    bool? isLoading,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffled: isShuffled ?? this.isShuffled,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Whether there's a next track in the queue.
  bool get hasNext => currentIndex < queue.length - 1;

  /// Whether there's a previous track in the queue.
  bool get hasPrevious => currentIndex > 0;

  /// Playback progress as a 0.0 – 1.0 value.
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }
}
