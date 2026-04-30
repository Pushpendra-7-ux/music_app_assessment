import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/models/track_model.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/utils/formatters.dart';
import 'package:music_app/features/artist/view/pages/artist_page.dart';
import 'package:music_app/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:music_app/features/player/viewmodel/player_viewmodel.dart';

/// A list tile representing a single track.
///
/// Highlights when the track is currently playing (gradient border + title).
/// The artist name is tappable and navigates to [ArtistPage].
class TrackCard extends ConsumerWidget {
  final TrackModel track;

  const TrackCard({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(playerViewmodelProvider).currentTrack;
    final isPlaying = currentTrack?.id == track.id;
    final isFav = ref.watch(favoritesViewmodelProvider).contains(track.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        // gradient tint when playing, plain dark card otherwise
        gradient: isPlaying
            ? LinearGradient(
                colors: [
                  AppColors.gradientStart.withValues(alpha: 0.15),
                  AppColors.gradientEnd.withValues(alpha: 0.08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isPlaying ? null : AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(
                color: AppColors.gradientStart.withValues(alpha: 0.4),
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            ref.read(playerViewmodelProvider.notifier).playTrack(track),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _AlbumArt(url: track.albumArtUrl),
              const SizedBox(width: 12),
              Expanded(
                child: _TrackInfo(
                  track: track,
                  isPlaying: isPlaying,
                ),
              ),
              _FavoriteButton(
                isFav: isFav,
                onTap: () => ref
                    .read(favoritesViewmodelProvider.notifier)
                    .toggleFavorite(track.id),
              ),
              const SizedBox(width: 4),
              _PlayIcon(isPlaying: isPlaying),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Private sub-widgets (TrackCard scoped)
// ─────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  final String url;
  const _AlbumArt({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        color: AppColors.surface,
        child: const Icon(Icons.music_note, color: AppColors.textMuted),
      );
}

class _TrackInfo extends StatelessWidget {
  final TrackModel track;
  final bool isPlaying;

  const _TrackInfo({required this.track, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TITLE ──
        Row(
          children: [
            if (isPlaying) ...[
              ShaderMask(
                shaderCallback: (b) => AppColors.gradient.createShader(b),
                child: const Icon(Icons.equalizer,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: isPlaying
                  ? ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.gradient.createShader(b),
                      child: Text(
                        track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
                      track.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        // ── ARTIST + DURATION ──
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ArtistPage(artistId: track.artistId),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.textMuted, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    track.artistName,
                    style: TextStyle(
                      color: isPlaying
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          AppColors.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '  •  ${formatDuration(track.duration)}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppColors.favorite : AppColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}

class _PlayIcon extends StatelessWidget {
  final bool isPlaying;
  const _PlayIcon({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? ShaderMask(
            shaderCallback: (b) => AppColors.gradient.createShader(b),
            child: const Icon(Icons.pause_circle_filled,
                color: Colors.white, size: 28),
          )
        : const Icon(Icons.play_circle_filled,
            color: AppColors.textSecondary, size: 28);
  }
}
