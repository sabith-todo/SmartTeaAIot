import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final isTamil = langCtrl.currentLanguage == AppLanguage.ta;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.forestGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isTamil ? 'துளிர் பற்றி' : 'About Thulir',
          style: const TextStyle(
            color: AppTheme.forestGreen,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Thulir Emblem
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestGreen.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/thulir_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco,
                    size: 56,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Brand Wordmark
              const Text(
                'துளிர்',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.forestGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Tagline
              const Text(
                '— Smart Tea Farming —',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryLeafGreen,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              // Version pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.creamDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Capabilities Description Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.creamDark),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestGreen.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isTamil
                          ? 'துளிர் என்பது தேயிலை விவசாயிகளுக்கு இலை பகுப்பாய்வு, தாவர நோய் மற்றும் பூச்சி தகவல்கள், மற்றும் அறிவியல் சார்ந்த சிறந்த நடைமுறைகளுடன் வழிகாட்டும் ஸ்மார்ட் தேயிலை விவசாய உதவியாளர்.'
                          : 'Thulir is an AI-powered smart tea farming assistant designed to help tea farmers with leaf analysis, disease and pest information, and cultivation best practices for healthier and more productive tea crops.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.creamDark, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: AppTheme.secondaryLeafGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'உள்ளூர் தேயிலை நிபுணத்துவம்' : 'Engineered for Nilgiris & Regional Tea Estates',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Plantation Landscape Footer
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/about_landscape.png',
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
