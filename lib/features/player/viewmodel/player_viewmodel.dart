import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/data/mock_data.dart';
import 'package:music_app/features/player/models/player_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:music_app/features/player/models/player_state.dart';

/// Manages audio playback, queue, and session persistence.
///
/// Uses [just_audio] for actual audio playback and [SharedPreferences]
/// to persist the last played track across app restarts.
class PlayerViewmodel extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer;
  final Random _random = Random();

  PlayerViewmodel()
      : _audioPlayer = AudioPlayer(),
        super(const PlayerState()) {
    _initListeners();
    _initQueue();
  }

  static const _lastTrackKey = 'last_track_id';

  // ── INITIALIZATION ──

  /// Load all tracks into the playback queue.
  void _initQueue() {
    state = state.copyWith(queue: List.from(MockData.tracks));
  }

  /// Restore a track to the player UI without playing it.
  /// Used on app startup to show the last played track in the mini player.
  void restoreTrack(TrackModel track) {
    final index = state.queue.indexWhere((t) => t.id == track.id);
    state = state.copyWith(
      currentTrack: track,
      position: Duration.zero,
      duration: track.duration,
      currentIndex: index >= 0 ? index : 0,
      isPlaying: false,
      isLoading: false,
    );
  }

  /// Subscribe to audio player streams for state synchronization.
  void _initListeners() {
    // player state (playing, completed, etc.)
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        if (state.hasNext) {
          skipNext();
        } else {
          state = state.copyWith(isPlaying: false, position: Duration.zero);
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      } else {
        state = state.copyWith(isPlaying: isPlaying, isLoading: false);
      }
    });

    // position updates
    _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // actual audio duration (may differ from mock metadata)
    _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    // buffering / loading indicators
    _audioPlayer.processingStateStream.listen((processingState) {
      final isBuffering = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;
      state = state.copyWith(isLoading: isBuffering);
    });
  }

  // ── PLAYBACK ──

  /// Play a track. If the same track is tapped, toggle play/pause instead.
  Future<void> playTrack(TrackModel track) async {
    try {
      if (state.currentTrack?.id == track.id) {
        await togglePlayPause();
        return;
      }

      final index = state.queue.indexWhere((t) => t.id == track.id);
      state = state.copyWith(
        currentTrack: track,
        position: Duration.zero,
        duration: Duration.zero,
        currentIndex: index >= 0 ? index : 0,
        isLoading: true,
      );

      // load audio from asset or URL
      if (track.audioUrl.startsWith('asset:')) {
        await _audioPlayer.setAsset(
          track.audioUrl.replaceFirst('asset:///', ''),
        );
      } else {
        await _audioPlayer.setUrl(track.audioUrl);
      }
      await _audioPlayer.play();
      _saveLastTrack(track.id);
    } catch (e) {
      debugPrint('Error playing track: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Toggle play/pause for the current track.
  Future<void> togglePlayPause() async {
    if (state.currentTrack == null) return;
    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  /// Skip to the next track in the queue.
  Future<void> skipNext() async {
    if (!state.hasNext) return;
    final nextIndex = state.currentIndex + 1;
    state = state.copyWith(currentIndex: nextIndex);
    await playTrack(state.queue[nextIndex]);
  }

  /// Go to the previous track, or restart the current track if >3s in.
  Future<void> skipPrevious() async {
    if (state.position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (!state.hasPrevious) return;
    final prevIndex = state.currentIndex - 1;
    state = state.copyWith(currentIndex: prevIndex);
    await playTrack(state.queue[prevIndex]);
  }

  /// Seek to a specific position in the current track.
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // ── QUEUE MANAGEMENT ──

  /// Toggle shuffle mode. Preserves the currently playing track's position.
  void toggleShuffle() {
    final isShuffled = !state.isShuffled;

    if (isShuffled) {
      final newQueue = List<TrackModel>.from(state.queue)..shuffle(_random);
      final currentTrack = state.currentTrack;
      if (currentTrack != null) {
        newQueue.remove(currentTrack);
        newQueue.insert(0, currentTrack);
      }
      state = state.copyWith(isShuffled: true, queue: newQueue, currentIndex: 0);
    } else {
      final newQueue = List<TrackModel>.from(MockData.tracks);
      final currentIndex = state.currentTrack != null
          ? newQueue.indexWhere((t) => t.id == state.currentTrack!.id)
          : 0;
      state = state.copyWith(
        isShuffled: false,
        queue: newQueue,
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
      );
    }
  }

  // ── SESSION PERSISTENCE ──

  Future<void> _saveLastTrack(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTrackKey, trackId);
  }

  /// Retrieve the last played track ID for session restoration.
  static Future<String?> getLastTrackId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastTrackKey);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Global provider for the player viewmodel.
final playerViewmodelProvider =
    StateNotifierProvider<PlayerViewmodel, PlayerState>((ref) {
  return PlayerViewmodel();
});
