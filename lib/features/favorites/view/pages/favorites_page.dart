import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/data/mock_data.dart';
import 'package:music_app/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:music_app/features/home/view/widgets/track_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesViewmodelProvider);

    final favoriteTracks = MockData.tracks
        .where((track) => favoriteIds.contains(track.id))
        .toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientEnd.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Favorites',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 20),
                      ),
                      Text(
                        '${favoriteTracks.length} liked songs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── CONTENT ──
          Expanded(
            child: favoriteTracks.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: favoriteTracks.length,
                    itemBuilder: (context, index) {
                      return TrackCard(track: favoriteTracks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // gradient heart icon in a circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.gradientEnd.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.gradient.createShader(bounds),
                child: const Icon(Icons.favorite_border,
                    color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text('No favorites yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any track\nto add it to your favorites',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
