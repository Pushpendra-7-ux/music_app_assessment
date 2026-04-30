import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/features/player/view/pages/player_page.dart';
import 'package:music_app/features/player/viewmodel/player_viewmodel.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerViewmodelProvider);
    final track = playerState.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlayerPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // gradient progress bar
            Container(
              height: 2,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: playerState.progress,
                child: Container(
                  decoration: const BoxDecoration(gradient: AppColors.gradient),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  // album art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: track.albumArtUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 42, height: 42,
                        color: AppColors.cardDark,
                        child: const Icon(Icons.music_note,
                            color: AppColors.textMuted, size: 16),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 42, height: 42,
                        color: AppColors.cardDark,
                        child: const Icon(Icons.music_note,
                            color: AppColors.textMuted, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(track.title,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(track.artistName,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),

                  // previous
                  if (playerState.hasPrevious)
                    GestureDetector(
                      onTap: () => ref
                          .read(playerViewmodelProvider.notifier)
                          .skipPrevious(),
                      child: const Icon(Icons.skip_previous_rounded,
                          color: AppColors.textSecondary, size: 24),
                    ),

                  const SizedBox(width: 4),

                  // gradient play/pause
                  GestureDetector(
                    onTap: () => ref
                        .read(playerViewmodelProvider.notifier)
                        .togglePlayPause(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: AppColors.gradient,
                        shape: BoxShape.circle,
                      ),
                      child: playerState.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(
                              playerState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // next
                  if (playerState.hasNext)
                    GestureDetector(
                      onTap: () => ref
                          .read(playerViewmodelProvider.notifier)
                          .skipNext(),
                      child: const Icon(Icons.skip_next_rounded,
                          color: AppColors.textSecondary, size: 24),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
