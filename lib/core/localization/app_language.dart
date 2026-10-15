import 'package:flutter/material.dart';

enum AppLanguage {
  en,
  ta;

  String get displayName {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ta:
        return 'தமிழ் (Tamil)';
    }
  }

  String get shortCode {
    switch (this) {
      case AppLanguage.en:
        return 'EN';
      case AppLanguage.ta:
        return 'தமிழ்';
    }
  }
}

/// A ChangeNotifier that manages the current language selection
/// across the entire widget tree.
class LanguageController extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  bool get isTamil => _currentLanguage == AppLanguage.ta;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(_currentLanguage == AppLanguage.en ? AppLanguage.ta : AppLanguage.en);
  }
}

/// InheritedWidget for fast, clean access to the LanguageController.
class LanguageProvider extends InheritedNotifier<LanguageController> {
  const LanguageProvider({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
    assert(provider != null, 'No LanguageProvider found in context');
    return provider!.notifier!;
  }
}
