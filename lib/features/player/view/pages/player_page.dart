import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/utils/formatters.dart';
import 'package:music_app/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:music_app/features/player/viewmodel/player_viewmodel.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // start spinning if already playing
    final state = ref.read(playerViewmodelProvider);
    if (state.isPlaying) _discController.repeat();
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewmodelProvider);
    final track = playerState.currentTrack;

    // sync disc rotation with play state
    if (playerState.isPlaying) {
      if (!_discController.isAnimating) _discController.repeat();
    } else {
      if (_discController.isAnimating) _discController.stop();
    }

    if (track == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_off_rounded,
                  color: AppColors.textMuted.withValues(alpha: 0.5), size: 80),
              const SizedBox(height: 16),
              Text('No track selected',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Pick a song from the home feed',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final isFav = ref.watch(favoritesViewmodelProvider).contains(track.id);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart.withValues(alpha: 0.3),
              AppColors.gradientEnd.withValues(alpha: 0.12),
              AppColors.background,
              AppColors.background,
            ],
            stops: const [0.0, 0.25, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ── TOP BAR ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _topBarButton(Icons.keyboard_arrow_down,
                        () => Navigator.pop(context)),
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.gradient.createShader(bounds),
                          child: Text(
                            'NOW PLAYING',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  letterSpacing: 2,
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (track.album.isNotEmpty)
                          Text(track.album,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                      ],
                    ),
                    _topBarButton(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      () => ref
                          .read(favoritesViewmodelProvider.notifier)
                          .toggleFavorite(track.id),
                      color: isFav ? AppColors.favorite : null,
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // ── VINYL DISC + ALBUM ART ──
                _buildDiscArt(track.albumArtUrl, playerState.isLoading),

                const Spacer(flex: 2),

                // ── TRACK INFO ──
                Text(track.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(track.artistName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textSecondary)),

                const SizedBox(height: 28),

                // ── PROGRESS BAR ──
                _buildProgressBar(playerState),

                // duration labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(playerState.position),
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(formatDuration(playerState.duration),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── CONTROLS ──
                _buildControls(playerState, ref),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBarButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildDiscArt(String imageUrl, bool isLoading) {
    return AnimatedBuilder(
      animation: _discController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _discController.value * 6.283,
          child: child,
        );
      },
      child: Container(
        width: 270,
        height: 270,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStart.withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(-6, 12),
            ),
            BoxShadow(
              color: AppColors.gradientEnd.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(6, 12),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // outer ring
            Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.6),
                    AppColors.cardDark,
                    AppColors.gradientEnd.withValues(alpha: 0.6),
                    AppColors.cardDark,
                    AppColors.gradientStart.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // album art circle
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 200,
                  height: 200,
                  color: AppColors.cardDark,
                  child: const Icon(Icons.music_note,
                      color: AppColors.textMuted, size: 48),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 200,
                  height: 200,
                  color: AppColors.cardDark,
                  child: const Icon(Icons.music_note,
                      color: AppColors.textMuted, size: 48),
                ),
              ),
            ),
            // center hole
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.gradientStart.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
            // loading overlay
            if (isLoading)
              Container(
                width: 270,
                height: 270,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(PlayerState playerState) {
    final max = playerState.duration.inMilliseconds > 0
        ? playerState.duration.inMilliseconds.toDouble()
        : 1.0;
    final value =
        playerState.position.inMilliseconds.toDouble().clamp(0.0, max);

    return SizedBox(
      height: 28,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          thumbColor: AppColors.gradientEnd,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.2),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        ),
        child: Slider(
          value: value,
          max: max,
          onChanged: (v) => ref
              .read(playerViewmodelProvider.notifier)
              .seekTo(Duration(milliseconds: v.toInt())),
        ),
      ),
    );
  }

  Widget _buildControls(PlayerState playerState, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // shuffle
        _controlButton(
          Icons.shuffle_rounded,
          playerState.isShuffled ? AppColors.primary : AppColors.textMuted,
          24,
          () => ref.read(playerViewmodelProvider.notifier).toggleShuffle(),
        ),

        // previous
        _controlButton(
          Icons.skip_previous_rounded,
          playerState.hasPrevious
              ? AppColors.textPrimary
              : AppColors.textMuted,
          36,
          playerState.hasPrevious || playerState.position.inSeconds > 3
              ? () =>
                  ref.read(playerViewmodelProvider.notifier).skipPrevious()
              : null,
        ),

        // play/pause — gradient
        GestureDetector(
          onTap: () =>
              ref.read(playerViewmodelProvider.notifier).togglePlayPause(),
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientStart.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: playerState.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Icon(
                    playerState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38),
          ),
        ),

        // next
        _controlButton(
          Icons.skip_next_rounded,
          playerState.hasNext ? AppColors.textPrimary : AppColors.textMuted,
          36,
          playerState.hasNext
              ? () => ref.read(playerViewmodelProvider.notifier).skipNext()
              : null,
        ),

        // rewind
        _controlButton(
          Icons.replay_10_rounded,
          AppColors.textMuted,
          24,
          () {
            final newPos =
                playerState.position - const Duration(seconds: 10);
            ref.read(playerViewmodelProvider.notifier).seekTo(
                newPos < Duration.zero ? Duration.zero : newPos);
          },
        ),
      ],
    );
  }

  Widget _controlButton(
      IconData icon, Color color, double size, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
