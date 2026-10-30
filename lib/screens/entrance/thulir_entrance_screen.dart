import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/theme/app_theme.dart';
import '../main_navigation_screen.dart';
import '../onboarding/thulir_onboarding_screen.dart';

/// Full-screen Thulir (துளிர்) entrance and splash screen.
/// Implements the authentic Thulir brand identity with the warm cream background,
/// tea-leaf emblem, Tamil brand name "துளிர்", "Smart Tea Farming" tagline,
/// and misty sunrise tea estate landscape.
class ThulirEntranceScreen extends StatefulWidget {
  final PreferencesService preferencesService;
  final ImagePickerService imagePickerService;
  final bool skipEntranceDelay;
  final VoidCallback? onEntranceCompleted;

  const ThulirEntranceScreen({
    super.key,
    required this.preferencesService,
    required this.imagePickerService,
    this.skipEntranceDelay = false,
    this.onEntranceCompleted,
  });

  @override
  State<ThulirEntranceScreen> createState() => _ThulirEntranceScreenState();
}

class _ThulirEntranceScreenState extends State<ThulirEntranceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _hasNavigated = false;

  /// Signature warm cream color matching the reference artwork background.
  static const Color thulirCream = Color(0xFFFDF4DD);
  static const Color thulirDeepGreen = Color(0xFF13361E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    if (widget.skipEntranceDelay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _proceed());
    } else {
      _timer = Timer(const Duration(seconds: 5), _proceed);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final isOnboardingDone = await widget.preferencesService
        .isOnboardingCompleted();

    if (!mounted) return;

    widget.onEntranceCompleted?.call();

    final nextScreen = isOnboardingDone
        ? MainNavigationScreen(imagePickerService: widget.imagePickerService)
        : ThulirOnboardingScreen(
            preferencesService: widget.preferencesService,
            imagePickerService: widget.imagePickerService,
          );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context).currentLanguage;

    return Scaffold(
      key: const Key('thulir_entrance_screen'),
      backgroundColor: thulirCream,
      body: GestureDetector(
        key: const Key('thulir_entrance_tap_area'),
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;

            if (isDesktop) {
              return _buildDesktopLayout(context, lang, constraints);
            }
            return _buildMobileLayout(context, lang, constraints);
          },
        ),
      ),
    );
  }

  /// Full-screen mobile layout preserving the reference artwork proportions.
  Widget _buildMobileLayout(
    BuildContext context,
    AppLanguage lang,
    BoxConstraints constraints,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background foundation: warm cream at top blending to lush tea green at bottom
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 0.75, 1.0],
                  colors: [
                    thulirCream,
                    thulirCream,
                    Color(0xFF5B8749),
                    thulirDeepGreen,
                  ],
                ),
              ),
            ),
          ),

          // High-fidelity Thulir entrance artwork asset
          Positioned.fill(
            child: SafeArea(
              child: Image.asset(
                'assets/images/thulir_splash.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackBranding(context, lang);
                },
              ),
            ),
          ),

          // Accessible semantic overlay providing screen-reader labels and test keys
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Opacity(
                opacity: 0.0,
                child: Semantics(
                  label: AppStrings.thulirFullBrand(lang),
                  child: Column(
                    children: [
                      Text(AppStrings.thulirBrand(lang)),
                      Text(AppStrings.thulirTagline(lang)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Wide tablet and Linux desktop presentation.
  /// Centers the vertical artwork in an elegant framed composition surrounded by
  /// an estate botanical background, preventing distortive wide stretching.
  Widget _buildDesktopLayout(
    BuildContext context,
    AppLanguage lang,
    BoxConstraints constraints,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: thulirCream,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 760),
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: thulirCream,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.forestGreen.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/thulir_splash.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackBranding(context, lang);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Graceful botanical fallback if assets are loading or missing
  Widget _buildFallbackBranding(BuildContext context, AppLanguage lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.leafGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: AppTheme.forestGreen, size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.thulirBrand(lang),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppTheme.forestGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.thulirTagline(lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.forestGreenDark,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
