import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/localization/app_language.dart';
import 'package:smart_tea_aiot/core/localization/app_strings.dart';

void main() {
  group('Localization & LanguageController Tests', () {
    test('Default language is English', () {
      final controller = LanguageController();
      expect(controller.currentLanguage, AppLanguage.en);
      expect(controller.isTamil, isFalse);
    });

    test('Toggling language switches between English and Tamil', () {
      final controller = LanguageController();
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.toggleLanguage();
      expect(controller.currentLanguage, AppLanguage.ta);
      expect(controller.isTamil, isTrue);
      expect(notified, isTrue);

      notified = false;
      controller.toggleLanguage();
      expect(controller.currentLanguage, AppLanguage.en);
      expect(controller.isTamil, isFalse);
      expect(notified, isTrue);
    });

    test('Bilingual strings return correct text for English and Tamil', () {
      // Titles
      expect(AppStrings.appTitle(AppLanguage.en), 'SmartTea AIoT');
      expect(AppStrings.appTitle(AppLanguage.ta), 'ஸ்மார்ட் டீ AIoT');

      // Navigation
      expect(AppStrings.navHome(AppLanguage.en), 'Home');
      expect(AppStrings.navHome(AppLanguage.ta), 'முகப்பு');
      expect(AppStrings.navAnalysis(AppLanguage.en), 'Leaf Analysis');
      expect(AppStrings.navAnalysis(AppLanguage.ta), 'இலை ஆய்வு');

      // Farmer Greeting
      expect(AppStrings.farmerGreeting(AppLanguage.en), 'Vanakkam, Planter!');
      expect(AppStrings.farmerGreeting(AppLanguage.ta), 'வணக்கம், விவசாயி!');

      // Critical Disclaimer
      expect(AppStrings.aiModelOfflineTitle(AppLanguage.en), contains('AI Model Status'));
      expect(AppStrings.aiModelOfflineDisclaimer(AppLanguage.en), contains('UNAVAILABLE'));
      expect(AppStrings.aiModelOfflineDisclaimer(AppLanguage.ta), contains('கிடைக்கவில்லை'));
    });
  });
}
