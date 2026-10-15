import 'package:flutter/material.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/services/image_picker_service.dart';
import '../core/theme/app_theme.dart';
import 'analysis/leaf_analysis_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'knowledge/tea_knowledge_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ImagePickerService imagePickerService;
  final int initialTabIndex;

  const MainNavigationScreen({
    super.key,
    required this.imagePickerService,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    final screens = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      LeafAnalysisScreen(
        imagePickerService: widget.imagePickerService,
        onNavigateToKnowledge: () => _onTabSelected(2),
      ),
      const TeaKnowledgeScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 640;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.leafGreen.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco, color: AppTheme.leafGreen, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.appTitle(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // Instant Language Switcher Pill Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: InkWell(
                  key: const Key('header_language_toggle_button'),
                  onTap: () => langCtrl.toggleLanguage(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.leafGreenDark.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language, size: 16, color: AppTheme.leafGreen),
                        const SizedBox(width: 6),
                        Text(
                          lang == AppLanguage.en ? 'தமிழ்' : 'English',
                          style: const TextStyle(
                            color: AppTheme.creamLight,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: isWideScreen
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onTabSelected,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          icon: const Icon(Icons.home_outlined),
                          selectedIcon: const Icon(Icons.home),
                          label: Text(AppStrings.navHome(lang)),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.camera_alt_outlined),
                          selectedIcon: const Icon(Icons.camera_alt),
                          label: Text(AppStrings.navAnalysis(lang)),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.menu_book_outlined),
                          selectedIcon: const Icon(Icons.menu_book),
                          label: Text(AppStrings.navKnowledge(lang)),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.history_outlined),
                          selectedIcon: const Icon(Icons.history),
                          label: Text(AppStrings.navHistory(lang)),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.settings_outlined),
                          selectedIcon: const Icon(Icons.settings),
                          label: Text(AppStrings.navSettings(lang)),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1, color: AppTheme.creamDark),
                    Expanded(child: screens[_currentIndex]),
                  ],
                )
              : screens[_currentIndex],
          bottomNavigationBar: isWideScreen
              ? null
              : NavigationBar(
                  key: const Key('main_bottom_navigation_bar'),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabSelected,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: AppStrings.navHome(lang),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.camera_alt_outlined),
                      selectedIcon: const Icon(Icons.camera_alt),
                      label: AppStrings.navAnalysis(lang),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu_book_outlined),
                      selectedIcon: const Icon(Icons.menu_book),
                      label: AppStrings.navKnowledge(lang),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.history_outlined),
                      selectedIcon: const Icon(Icons.history),
                      label: AppStrings.navHistory(lang),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: AppStrings.navSettings(lang),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
