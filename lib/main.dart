import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/widgets/splash_screen.dart';
import 'package:music_app/data/mock_data.dart';
import 'package:music_app/features/auth/view/pages/login_page.dart';
import 'package:music_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:music_app/features/home/view/pages/home_page.dart';
import 'package:music_app/features/player/viewmodel/player_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BlosicalApp()));
}

class BlosicalApp extends ConsumerStatefulWidget {
  const BlosicalApp({super.key});

  @override
  ConsumerState<BlosicalApp> createState() => _BlosicalAppState();
}

class _BlosicalAppState extends ConsumerState<BlosicalApp> {
  @override
  void initState() {
    super.initState();
    // check login status and restore previous session
    Future.microtask(() async {
      await ref.read(authViewmodelProvider.notifier).checkLoginStatus();
      _restoreLastSession();
    });
  }

  /// Restore the last played track into UI without auto-playing.
  Future<void> _restoreLastSession() async {
    final lastTrackId = await PlayerViewmodel.getLastTrackId();
    if (lastTrackId != null) {
      final match = MockData.tracks
          .where((t) => t.id == lastTrackId)
          .firstOrNull;
      if (match != null) {
        ref.read(playerViewmodelProvider.notifier).restoreTrack(match);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewmodelProvider);

    return MaterialApp(
      title: 'Blosical',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        loading: () => const SplashScreen(),
        error: (_, __) => const LoginPage(),
        data: (isLoggedIn) =>
            isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
