import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_theme.dart';

/// The animated splash screen shown while the app checks auth state.
///
/// Features:
/// - Floating radial glow orbs with scale animation
/// - The Blosical logo icon pulses in with a bounce curve
/// - "Blosical" brand name is revealed letter-by-letter via a scale + fade
/// - A slim gradient progress bar sweeps across the bottom
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // logo bounce-in
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // brand name fade + slide up
  late final AnimationController _nameController;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;

  // tagline fade
  late final AnimationController _taglineController;
  late final Animation<double> _taglineFade;

  // rotating orb decoration
  late final AnimationController _orbController;

  // pulsing glow on logo
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  // bottom progress bar
  late final AnimationController _progressController;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // ── ORB ROTATION (infinite) ──
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // ── LOGO BOUNCE IN ──
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // ── LOGO PULSE (infinite, subtle) ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── BRAND NAME SLIDE UP + FADE ──
    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _nameFade = CurvedAnimation(
      parent: _nameController,
      curve: Curves.easeOut,
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.easeOutCubic),
    );

    // ── TAGLINE FADE ──
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    // ── PROGRESS BAR ──
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressValue = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // ── SEQUENCE ──
    _logoController.forward().then((_) {
      _nameController.forward().then((_) {
        _taglineController.forward();
        _progressController.forward();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _orbController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── BACKGROUND GRADIENT ──
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  AppColors.gradientStart.withValues(alpha: 0.12),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // ── ROTATING ORB — top right ──
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final angle = _orbController.value * 2 * pi;
              return Positioned(
                right: size.width * 0.1 + cos(angle) * 20,
                top: size.height * 0.08 + sin(angle) * 20,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gradientStart.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── ROTATING ORB — bottom left ──
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final angle = _orbController.value * 2 * pi;
              return Positioned(
                left: size.width * 0.05 + sin(angle) * 16,
                bottom: size.height * 0.18 + cos(angle) * 16,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gradientEnd.withValues(alpha: 0.13),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── MAIN CONTENT ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── LOGO with pulse + bounce ──
                ScaleTransition(
                  scale: _pulse,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: _BlosicalLogo(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── BRAND NAME ──
                SlideTransition(
                  position: _nameSlide,
                  child: FadeTransition(
                    opacity: _nameFade,
                    child: const _BrandName(),
                  ),
                ),

                const SizedBox(height: 10),

                // ── TAGLINE ──
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'Your personal music experience',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 0.4,
                        ),
                  ),
                ),

                const SizedBox(height: 56),

                // ── PROGRESS BAR ──
                FadeTransition(
                  opacity: _taglineFade,
                  child: _ProgressBar(progress: _progressValue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets (kept in same file since splash-only)
// ─────────────────────────────────────────────

class _BlosicalLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.45),
            blurRadius: 36,
            offset: const Offset(-4, 10),
          ),
          BoxShadow(
            color: AppColors.gradientEnd.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(4, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}

class _BrandName extends StatelessWidget {
  const _BrandName();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'Blosical',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 42,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
              height: 1.0,
            ),
      ),
    );
  }
}

class _ProgressBar extends AnimatedWidget {
  const _ProgressBar({required Animation<double> progress})
      : super(listenable: progress);

  Animation<double> get progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 3,
              child: Stack(
                children: [
                  // track
                  Container(color: AppColors.divider),
                  // fill
                  FractionallySizedBox(
                    widthFactor: progress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
