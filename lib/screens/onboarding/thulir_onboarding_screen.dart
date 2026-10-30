import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/theme/app_theme.dart';
import '../main_navigation_screen.dart';

/// Thulir (துளிர்) Onboarding experience for first-time tea growers and estate managers.
class ThulirOnboardingScreen extends StatefulWidget {
  final PreferencesService preferencesService;
  final ImagePickerService imagePickerService;
  final VoidCallback? onFinished;

  const ThulirOnboardingScreen({
    super.key,
    required this.preferencesService,
    required this.imagePickerService,
    this.onFinished,
  });

  @override
  State<ThulirOnboardingScreen> createState() => _ThulirOnboardingScreenState();
}

class _ThulirOnboardingScreenState extends State<ThulirOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.preferencesService.setOnboardingCompleted(true);
    if (!mounted) return;

    widget.onFinished?.call();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainNavigationScreen(imagePickerService: widget.imagePickerService),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final langController = LanguageProvider.of(context);
    final lang = langController.currentLanguage;

    final slides = [
      _OnboardingSlideData(
        icon: Icons.camera_alt_outlined,
        badgeText: 'Screening • பரிசோதனை',
        title: AppStrings.onboarding1Title(lang),
        description: AppStrings.onboarding1Desc(lang),
        accentColor: AppTheme.forestGreen,
      ),
      _OnboardingSlideData(
        icon: Icons.menu_book_outlined,
        badgeText: 'Agronomy • வழிகாட்டி',
        title: AppStrings.onboarding2Title(lang),
        description: AppStrings.onboarding2Desc(lang),
        accentColor: AppTheme.leafGreenDark,
      ),
      _OnboardingSlideData(
        icon: Icons.verified_user_outlined,
        badgeText: 'Transparency • நம்பகத்தன்மை',
        title: AppStrings.onboarding3Title(lang),
        description: AppStrings.onboarding3Desc(lang),
        accentColor: AppTheme.warningAmber,
      ),
    ];

    return Scaffold(
      key: const Key('thulir_onboarding_screen'),
      backgroundColor: AppTheme.creamLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 540),
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 16.0 : 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    // Top header: Thulir mini branding & language toggle
                    _buildTopBar(context, langController, lang),

                    const SizedBox(height: 12),

                    // PageView with onboarding cards
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: slides.length,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentPage = idx;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildSlideCard(slides[index], isNarrow);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom controls: Page indicators, Skip & Next / Get Started
                    _buildBottomControls(context, lang, isNarrow),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    LanguageController langController,
    AppLanguage lang,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand logo & title
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.forestGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.eco,
                color: AppTheme.creamLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.thulirBrand(lang),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.forestGreen,
              ),
            ),
          ],
        ),

        // Language toggle button (Tamil / English)
        OutlinedButton.icon(
          key: const Key('onboarding_language_toggle_button'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.forestGreen,
            side: const BorderSide(color: AppTheme.forestGreen, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(44, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.language, size: 16),
          label: Text(
            lang == AppLanguage.ta ? 'English' : 'தமிழ்',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          onPressed: () {
            langController.toggleLanguage();
          },
        ),
      ],
    );
  }

  Widget _buildSlideCard(_OnboardingSlideData data, bool isNarrow) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Hero Icon Container
          Container(
            width: isNarrow ? 120 : 140,
            height: isNarrow ? 120 : 140,
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              data.icon,
              size: isNarrow ? 60 : 70,
              color: data.accentColor,
            ),
          ),

          const SizedBox(height: 24),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: data.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isNarrow ? 20 : 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.forestGreen,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8.0 : 16.0),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isNarrow ? 13.5 : 14.5,
                color: AppTheme.textDark.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    AppLanguage lang,
    bool isNarrow,
  ) {
    final isLastPage = _currentPage == 2;

    return Column(
      children: [
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (idx) {
            final isSelected = idx == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.forestGreen : AppTheme.creamDark,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        // Bottom Action Buttons
        Row(
          children: [
            // Skip button
            if (!isLastPage)
              TextButton(
                key: const Key('onboarding_skip_button'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  minimumSize: const Size(64, 44),
                ),
                onPressed: _completeOnboarding,
                child: Text(
                  AppStrings.btnSkip(lang),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const SizedBox(width: 64),

            const Spacer(),

            // Next / Get Started button
            ElevatedButton(
              key: const Key('onboarding_get_started_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: AppTheme.creamLight,
                elevation: 2,
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 20 : 28,
                  vertical: 12,
                ),
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onNext,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastPage
                        ? AppStrings.btnGetStarted(lang)
                        : AppStrings.btnNext(lang),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnboardingSlideData {
  final IconData icon;
  final String badgeText;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardingSlideData({
    required this.icon,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
