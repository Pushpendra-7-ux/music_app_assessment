import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/models/artist_model.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/utils/formatters.dart';
import 'package:music_app/features/artist/view/pages/artist_page.dart';

/// A vertically stacked card showing an artist's gradient-bordered avatar,
/// name, and monthly listener count. Tapping navigates to [ArtistPage].
class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArtistPage(artistId: artist.id),
        ),
      ),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            // ── GRADIENT-BORDERED CIRCULAR AVATAR ──
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradient,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: artist.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _AvatarPlaceholder(),
                    errorWidget: (_, __, ___) => _AvatarPlaceholder(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── ARTIST NAME ──
            Text(
              artist.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // ── LISTENER COUNT ──
            Text(
              '${formatListeners(artist.monthlyListeners)} listeners',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Private sub-widget
// ─────────────────────────────────────────────

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardDark,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.textMuted,
        size: 36,
      ),
    );
  }
}
