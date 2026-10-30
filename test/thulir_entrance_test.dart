import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/localization/app_language.dart';
import 'package:smart_tea_aiot/core/services/preferences_service.dart';
import 'package:smart_tea_aiot/main.dart';
import 'package:smart_tea_aiot/screens/entrance/thulir_entrance_screen.dart';
import 'package:smart_tea_aiot/screens/onboarding/thulir_onboarding_screen.dart';

void main() {
  group('Thulir (துளிர்) Entrance & Onboarding Tests', () {
    testWidgets(
      'Entrance screen renders on narrow mobile display (360px) without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockPrefs = InMemoryPreferencesService(initialOnboardingCompleted: false);

        await tester.pumpWidget(SmartTeaApp(
          showEntrance: true,
          skipEntranceDelay: false,
          preferencesService: mockPrefs,
          initialLanguage: AppLanguage.ta,
        ));

        // Initial frame: entrance screen is displayed
        await tester.pump();
        expect(find.byType(ThulirEntranceScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Tap screen to proceed immediately
        await tester.tap(find.byKey(const Key('thulir_entrance_tap_area')));
        await tester.pumpAndSettle();

        // Navigates to Onboarding because it is a first-time launch
        expect(find.byType(ThulirOnboardingScreen), findsOneWidget);
        expect(find.text('துளிர்'), findsOneWidget);
      },
    );

    testWidgets(
      'Entrance screen renders on wide Linux desktop display (1024x768)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockPrefs = InMemoryPreferencesService(initialOnboardingCompleted: true);

        await tester.pumpWidget(SmartTeaApp(
          showEntrance: true,
          skipEntranceDelay: false,
          preferencesService: mockPrefs,
          initialLanguage: AppLanguage.en,
        ));

        await tester.pump();
        expect(find.byType(ThulirEntranceScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Tap to proceed
        await tester.tap(find.byKey(const Key('thulir_entrance_tap_area')));
        await tester.pumpAndSettle();

        // Returning user proceeds directly to Home
        expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      },
    );

    testWidgets(
      'First-launch full flow: Entrance -> Onboarding -> Next slides -> Get Started -> Home',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockPrefs = InMemoryPreferencesService(initialOnboardingCompleted: false);

        await tester.pumpWidget(SmartTeaApp(
          showEntrance: true,
          skipEntranceDelay: true,
          preferencesService: mockPrefs,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        // Land on Onboarding screen
        expect(find.byType(ThulirOnboardingScreen), findsOneWidget);
        expect(find.text('Early Foliar Screening'), findsOneWidget);
        expect(find.byKey(const Key('onboarding_get_started_button')), findsOneWidget);

        // Advance to slide 2
        await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
        await tester.pumpAndSettle();
        expect(find.text('Agronomy & Cultural Guide'), findsOneWidget);

        // Advance to slide 3
        await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
        await tester.pumpAndSettle();
        expect(find.text('Empowered Planter Decisions'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);

        // Tap Get Started
        await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
        await tester.pumpAndSettle();

        // Verify preferences were updated
        expect(await mockPrefs.isOnboardingCompleted(), isTrue);

        // Verify arrived at Home screen
        expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      },
    );

    testWidgets(
      'Onboarding language toggle switches text reactively between Tamil and English',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockPrefs = InMemoryPreferencesService(initialOnboardingCompleted: false);

        await tester.pumpWidget(SmartTeaApp(
          showEntrance: true,
          skipEntranceDelay: true,
          preferencesService: mockPrefs,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        // English text is shown
        expect(find.text('Early Foliar Screening'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Tap language toggle button
        await tester.tap(find.byKey(const Key('onboarding_language_toggle_button')));
        await tester.pumpAndSettle();

        // Switches to Tamil
        expect(find.text('இலை நோய் பரிசோதனை'), findsOneWidget);
        expect(find.text('தவிர்'), findsOneWidget);

        // Tap Skip button in Tamil
        await tester.tap(find.byKey(const Key('onboarding_skip_button')));
        await tester.pumpAndSettle();

        // Arrives at Tamil Home
        expect(find.text('வணக்கம், விவசாயி!'), findsOneWidget);
      },
    );

    testWidgets(
      'Returning launch bypasses onboarding and opens directly to Home',
      (WidgetTester tester) async {
        final mockPrefs = InMemoryPreferencesService(initialOnboardingCompleted: true);

        await tester.pumpWidget(SmartTeaApp(
          showEntrance: true,
          skipEntranceDelay: true,
          preferencesService: mockPrefs,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        // Direct navigation to Home
        expect(find.byType(ThulirOnboardingScreen), findsNothing);
        expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      },
    );
  });
}
