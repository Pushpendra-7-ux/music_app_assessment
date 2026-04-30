import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/utils/formatters.dart';
import 'package:music_app/core/widgets/gradient_button.dart';
import 'package:music_app/core/widgets/stat_chip.dart';
import 'package:music_app/features/artist/repositories/artist_repository.dart';
import 'package:music_app/features/home/view/widgets/track_card.dart';
import 'package:music_app/features/player/viewmodel/player_viewmodel.dart';

/// Displays the artist profile: header image, bio, stats, and discography.
class ArtistPage extends ConsumerWidget {
  final String artistId;

  const ArtistPage({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(artistRepositoryProvider);
    final artist = repo.getArtistById(artistId);
    final artistTracks = repo.getTracksByArtist(artistId);

    // ── NOT FOUND ──
    if (artist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artist')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_rounded,
                  color: AppColors.textMuted.withValues(alpha: 0.5), size: 64),
              const SizedBox(height: 16),
              Text('Artist not found',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    // ── MAIN VIEW ──
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── COLLAPSING HEADER ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                artist.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black87)],
                ),
              ),
              background: _ArtistHeaderBackground(imageUrl: artist.imageUrl),
            ),
          ),

          // ── STATS + BIO + DISCOGRAPHY HEADER ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // stats chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      StatChip(
                        icon: Icons.headphones_rounded,
                        label:
                            '${formatListeners(artist.monthlyListeners)} monthly listeners',
                      ),
                      StatChip(
                        icon: Icons.music_note_rounded,
                        label: '${artistTracks.length} tracks',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // bio
                  Text('About',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    artist.bio,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.6),
                  ),

                  const SizedBox(height: 28),

                  // discography header + play all
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discography',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (artistTracks.isNotEmpty)
                        GradientButton(
                          height: 36,
                          borderRadius: 20,
                          onPressed: () => ref
                              .read(playerViewmodelProvider.notifier)
                              .playTrack(artistTracks.first),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Play All',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── TRACK LIST ──
          if (artistTracks.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.music_off_rounded,
                          color: AppColors.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'No tracks available',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    TrackCard(track: artistTracks[index]),
                childCount: artistTracks.length,
              ),
            ),

          // bottom padding so last track clears nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Private sub-widgets (artist_page scoped)
// ─────────────────────────────────────────────

/// Back button with a frosted dark container for visibility over images.
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

/// Collapsible sliver header background: artist image + gradient overlay.
class _ArtistHeaderBackground extends StatelessWidget {
  final String imageUrl;

  const _ArtistHeaderBackground({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.cardDark),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.cardDark,
            child: const Icon(Icons.person_rounded,
                color: AppColors.textMuted, size: 80),
          ),
        ),
        // gradient fade to background at bottom
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.gradientStart.withValues(alpha: 0.15),
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.75),
                AppColors.background,
              ],
              stops: const [0.0, 0.35, 0.75, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
