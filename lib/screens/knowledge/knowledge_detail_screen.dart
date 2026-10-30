import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'tea_knowledge_screen.dart';

/// Screen 8: Knowledge Detail Screen matching Thulir design board.
class KnowledgeDetailScreen extends StatelessWidget {
  final TeaDiseaseItem disease;

  const KnowledgeDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;
    final isTa = lang == AppLanguage.ta;

    final name = isTa ? disease.taName : disease.enName;
    final category = isTa ? disease.taCategory : disease.enCategory;
    final symptoms = isTa ? disease.taSymptoms : disease.enSymptoms;
    final management = isTa ? disease.taManagement : disease.enManagement;
    final riskFactors = isTa ? disease.taRiskFactors : disease.enRiskFactors;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.forestGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isTa ? 'அறிவு விவரம்' : 'Knowledge Detail',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.forestGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Feature Image Card
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppTheme.creamDark, width: 1.5),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/leaf_sample.png',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: AppTheme.forestGreen.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.eco,
                          size: 64,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Header Title & Category Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.forestGreen,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        disease.scientificName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.leafGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.leafGreenDark.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section 1: Overview
            _buildSectionCard(
              title: isTa ? 'மேலோட்டம்' : 'Overview',
              icon: Icons.info_outline,
              content: isTa
                  ? '${disease.taName} என்பது தேயிலைத் தோட்டங்களில் பரவலாகக் காணப்படும் ஒரு பாதிப்பாகும். முறையான கள மேலாண்மை மற்றும் பாதுகாப்பு நடவடிக்கைகள் மூலம் பயிர் சேதத்தைத் தடுக்கலாம்.'
                  : '${disease.enName} is a significant tea agronomic concern affecting bushes in highland estates. Timely cultural intervention protects young plucking shoots and bush vigor.',
            ),

            const SizedBox(height: 16),

            // Section 2: Symptoms
            _buildSectionCard(
              title: AppStrings.labelSymptoms(lang),
              icon: Icons.visibility_outlined,
              content: symptoms,
              iconColor: AppTheme.warningAmber,
            ),

            const SizedBox(height: 16),

            // Section 3: Cultural & Organic Management
            _buildSectionCard(
              title: AppStrings.labelManagement(lang),
              icon: Icons.spa_outlined,
              content: management,
              iconColor: AppTheme.secondaryLeafGreen,
            ),

            const SizedBox(height: 16),

            // Section 4: Favorable Conditions / Risk Factors
            _buildSectionCard(
              title: AppStrings.labelRiskFactors(lang),
              icon: Icons.thermostat_outlined,
              content: riskFactors,
              iconColor: AppTheme.forestGreenLight,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    Color iconColor = AppTheme.forestGreen,
  }) {
    return Card(
      color: AppTheme.creamLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.creamDark, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
