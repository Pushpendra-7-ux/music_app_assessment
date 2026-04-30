import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/widgets/gradient_button.dart';
import 'package:music_app/data/mock_data.dart';
import 'package:music_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:music_app/features/auth/view/pages/login_page.dart';
import 'package:music_app/features/favorites/view/pages/favorites_page.dart';
import 'package:music_app/features/home/view/widgets/artist_card.dart';
import 'package:music_app/features/home/view/widgets/track_card.dart';
import 'package:music_app/features/home/viewmodel/home_viewmodel.dart';
import 'package:music_app/features/home/repositories/home_repository.dart';
import 'package:music_app/features/player/view/widgets/mini_player.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: const [
          _HomeFeedView(),
          FavoritesPage(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (i) => setState(() => _currentTab = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeedView extends ConsumerStatefulWidget {
  const _HomeFeedView();

  @override
  ConsumerState<_HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends ConsumerState<_HomeFeedView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

// Removed time-based greeting logic

  @override
  Widget build(BuildContext context) {
    final tracksState = ref.watch(homeViewmodelProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientStart.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                // App Branding / Header Title
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.headphones_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blosical',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 20),
                      ),
                      Text(
                        'Discover your music',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // logout
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textMuted, size: 20),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await ref
                          .read(authViewmodelProvider.notifier)
                          .logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search tracks, artists, albums...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        AppColors.gradientStart.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),

          // ── CONTENT ──
          Expanded(
            child: tracksState.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => _buildErrorState(err),
              data: (tracks) => _buildContent(tracks),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.error, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Something went wrong',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(err.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GradientButton(
              height: 42,
              borderRadius: 12,
              onPressed: () =>
                  ref.read(homeViewmodelProvider.notifier).refresh(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Try Again',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List tracks) {
    final filteredTracks = _searchQuery.isEmpty
        ? tracks
        : ref.read(homeRepositoryProvider).searchTracks(_searchQuery);

    if (_searchQuery.isNotEmpty && filteredTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 64),
            const SizedBox(height: 12),
            Text('No results for "$_searchQuery"',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Try a different search term',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(homeViewmodelProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          // ── ARTISTS SECTION ──
          if (_searchQuery.isEmpty) ...[
            _buildSectionHeader('Popular Artists', Icons.star_rounded),
            const SizedBox(height: 12),
            SizedBox(
              height: 162,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: MockData.artists.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ArtistCard(
                      artist: MockData.artists[index]);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── TRACKS SECTION ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Divider(
              color: AppColors.divider.withValues(alpha: 0.4),
              height: 1,
              thickness: 0.5,
            ),
          ),
          _buildSectionHeader(
            _searchQuery.isNotEmpty ? 'Search Results' : 'All Tracks',
            _searchQuery.isNotEmpty
                ? Icons.search
                : Icons.queue_music_rounded,
            trailing: Text(
              '${filteredTracks.length} songs',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),

          ...filteredTracks.map((track) => TrackCard(track: track)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.gradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
