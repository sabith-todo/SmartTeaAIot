import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Farmer Welcome Hero Banner
          _buildHeroBanner(context, lang),

          const SizedBox(height: 18),

          // Milestone Status Badge Card
          _buildMilestoneBanner(context, lang),

          const SizedBox(height: 22),

          // Quick Action Cards
          Text(
            AppStrings.quickActionsTitle(lang),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCards(context, lang),

          const SizedBox(height: 24),

          // Microclimate / Sensor Telemetry Placeholder Card
          _buildMicroclimateSection(context, lang),

          const SizedBox(height: 24),

          // Agronomic Advisory Card
          _buildAdvisoryCard(context, lang),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, AppLanguage lang) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.forestGreen, AppTheme.forestGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestGreenDark.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.leafGreen.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  color: AppTheme.leafGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.farmerGreeting(lang),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.creamLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.estateOverview(lang),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.leafGreenLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.appSubtitle(lang),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.cream,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBanner(BuildContext context, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.leafGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.leafGreenDark.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified,
            color: AppTheme.forestGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.foundationBadge(lang),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context, AppLanguage lang) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;
        final cards = [
          _ActionCardItem(
            title: AppStrings.actionScanLeaf(lang),
            subtitle: AppStrings.actionScanLeafDesc(lang),
            icon: Icons.camera_alt_outlined,
            accentColor: AppTheme.forestGreen,
            onTap: () => onNavigateToTab(1), // Leaf Analysis
          ),
          _ActionCardItem(
            title: AppStrings.actionDiseaseGuide(lang),
            subtitle: AppStrings.actionDiseaseGuideDesc(lang),
            icon: Icons.menu_book_outlined,
            accentColor: AppTheme.forestGreenLight,
            onTap: () => onNavigateToTab(2), // Tea Knowledge
          ),
          _ActionCardItem(
            title: AppStrings.actionInspectionLogs(lang),
            subtitle: AppStrings.actionInspectionLogsDesc(lang),
            icon: Icons.history_edu_outlined,
            accentColor: AppTheme.leafGreenDark,
            onTap: () => onNavigateToTab(3), // History
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards.map((c) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildActionCard(c),
            ))).toList(),
          );
        }

        return Column(
          children: cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildActionCard(c),
          )).toList(),
        );
      },
    );
  }

  Widget _buildActionCard(_ActionCardItem item) {
    return Card(
      elevation: 1.5,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicroclimateSection(BuildContext context, AppLanguage lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.microclimateTitle(lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.sensors,
                  color: AppTheme.forestGreenLight,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.creamDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppStrings.telemetryNotice(lang),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: AppStrings.soilMoisture(lang),
                    value: '68%',
                    icon: Icons.water_drop_outlined,
                    color: AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: AppStrings.canopyTemp(lang),
                    value: '21.4°C',
                    icon: Icons.thermostat_outlined,
                    color: AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: AppStrings.relativeHumidity(lang),
                    value: '84%',
                    icon: Icons.cloud_outlined,
                    color: AppTheme.forestGreenLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.creamDark),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard(BuildContext context, AppLanguage lang) {
    return Card(
      color: AppTheme.creamLight,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.warningAmber,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.dailyAdvisoryTitle(lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.dailyAdvisoryBody(lang),
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  _ActionCardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });
}
