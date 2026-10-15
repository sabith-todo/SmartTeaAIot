import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.settingsTitle(lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 18),

          // Language Selector Card
          _buildLanguageCard(context, langCtrl, lang),

          const SizedBox(height: 20),

          // Palette / Theme card
          _buildThemePaletteCard(context, lang),

          const SizedBox(height: 20),

          // Incremental Project Roadmap card
          _buildRoadmapCard(context, lang),

          const SizedBox(height: 20),

          // Scientific Integrity & Policy
          _buildPolicyCard(context, lang),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    LanguageController langCtrl,
    AppLanguage lang,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate, color: AppTheme.forestGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.sectionLanguage(lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.languageSelection(lang),
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _LanguageOptionTile(
                    title: 'English',
                    isSelected: lang == AppLanguage.en,
                    onTap: () => langCtrl.setLanguage(AppLanguage.en),
                    key: const Key('lang_option_en'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LanguageOptionTile(
                    title: 'தமிழ் (Tamil)',
                    isSelected: lang == AppLanguage.ta,
                    onTap: () => langCtrl.setLanguage(AppLanguage.ta),
                    key: const Key('lang_option_ta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePaletteCard(BuildContext context, AppLanguage lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, color: AppTheme.forestGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.sectionTheme(lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildColorSwatch(
                    name: 'Forest Green',
                    hex: '#193B2B',
                    color: AppTheme.forestGreen,
                    textColor: AppTheme.creamLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorSwatch(
                    name: 'Cream',
                    hex: '#F3EEDC',
                    color: AppTheme.cream,
                    textColor: AppTheme.forestGreen,
                    hasBorder: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorSwatch(
                    name: 'Leaf Green',
                    hex: '#B5C99B',
                    color: AppTheme.leafGreen,
                    textColor: AppTheme.forestGreenDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch({
    required String name,
    required String hex,
    required Color color,
    required Color textColor,
    bool hasBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: AppTheme.creamDark, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hex,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context, AppLanguage lang) {
    final stages = [
      _RoadmapItem(
        title: 'Milestone 1: Flutter Foundation',
        desc: 'Responsive farmer UI, bilingual support, photo capture/preview/cancel, no-fake-AI baseline.',
        isDone: true,
      ),
      _RoadmapItem(
        title: 'Milestone 2: Backend & Sync',
        desc: 'Python REST API service, authenticated inspection log syncing, telemetry ingest.',
        isDone: false,
      ),
      _RoadmapItem(
        title: 'Milestone 3: AI/ML Leaf Model',
        desc: 'Computer Vision deep learning inference for tea disease classification.',
        isDone: false,
      ),
      _RoadmapItem(
        title: 'Milestone 4: IoT Hardware Telemetry',
        desc: 'Soil moisture, canopy temperature, and humidity ESP32 field telemetry nodes.',
        isDone: false,
      ),
      _RoadmapItem(
        title: 'Milestone 5: Research & RAG',
        desc: 'Agronomic RAG knowledge retrieval and public research project portal.',
        isDone: false,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: AppTheme.forestGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.sectionRoadmap(lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...stages.map((s) => _buildRoadmapRow(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapRow(_RoadmapItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.isDone ? AppTheme.forestGreen : AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: item.isDone ? AppTheme.forestGreen : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppTheme.forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.sectionAbout(lang),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.aboutDescription(lang),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.forestGreen, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.strictAiPolicy(lang),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.forestGreen : AppTheme.creamLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.forestGreen : AppTheme.creamDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isSelected ? AppTheme.leafGreen : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.creamLight : AppTheme.forestGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapItem {
  final String title;
  final String desc;
  final bool isDone;

  _RoadmapItem({
    required this.title,
    required this.desc,
    required this.isDone,
  });
}
