import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/widgets/gradient_button.dart';
import 'package:music_app/core/widgets/custom_field.dart';
import 'package:music_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:music_app/features/home/view/pages/home_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  late final AnimationController _bgController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // slow rotating gradient background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // fade-in animation for the form
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final errorMsg = await ref.read(authViewmodelProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewmodelProvider);
    final isLoading = authState is AsyncLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── ANIMATED GRADIENT BACKGROUND ──
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      cos(_bgController.value * 2 * pi),
                      sin(_bgController.value * 2 * pi),
                    ),
                    end: Alignment(
                      -cos(_bgController.value * 2 * pi),
                      -sin(_bgController.value * 2 * pi),
                    ),
                    colors: [
                      AppColors.gradientStart.withValues(alpha: 0.2),
                      AppColors.background,
                      AppColors.background,
                      AppColors.gradientEnd.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── DECORATIVE BLURRED CIRCLES ──
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.2),
                    AppColors.gradientStart.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientEnd.withValues(alpha: 0.12),
                    AppColors.gradientEnd.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          // ── APP LOGO ──
                          _buildLogo(),

                          const SizedBox(height: 36),

                          // ── WELCOME TEXT ──
                          Text(
                            'Welcome to',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.gradient.createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Blosical',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontSize: 38,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1.0,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Where music meets your mood',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),

                          const Spacer(flex: 2),

                          // ── FORM CARD ──
                          _buildFormCard(isLoading),

                          const SizedBox(height: 20),

                          // ── DEMO HINT ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.gradientStart
                                        .withValues(alpha: 0.7),
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Use any email & password (min 4 chars)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(-4, 8),
          ),
          BoxShadow(
            color: AppColors.gradientEnd.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(4, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.headphones_rounded,
        color: Colors.white,
        size: 42,
      ),
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // email
          Text(
            'Email',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          CustomField(
            hintText: 'name@example.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: 18),

          // password
          Text(
            'Password',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          CustomField(
            hintText: 'Enter password',
            controller: _passwordController,
            isObscure: !_showPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _showPassword = !_showPassword),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 4) return 'At least 4 characters';
              return null;
            },
          ),

          const SizedBox(height: 24),

          // sign in button
          GradientButton(
            onPressed: isLoading ? null : _handleLogin,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
