import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/features/home/repositories/home_repository.dart';

final homeViewmodelProvider =
    StateNotifierProvider<HomeViewmodel, AsyncValue<List<TrackModel>>>((ref) {
  return HomeViewmodel(ref.read(homeRepositoryProvider));
});

class HomeViewmodel extends StateNotifier<AsyncValue<List<TrackModel>>> {
  final HomeRepository _repository;

  HomeViewmodel(this._repository) : super(const AsyncValue.loading()) {
    loadTracks();
  }

  Future<void> loadTracks() async {
    state = const AsyncValue.loading();
    try {
      final tracks = await _repository.fetchTracks();
      state = AsyncValue.data(tracks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh the track list (e.g. pull-to-refresh)
  Future<void> refresh() async {
    await loadTracks();
  }
}
