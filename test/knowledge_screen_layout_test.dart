import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/localization/app_language.dart';
import 'package:smart_tea_aiot/core/localization/app_strings.dart';
import 'package:smart_tea_aiot/main.dart';

void main() {
  group('TeaKnowledgeScreen Mobile & Desktop Layout Tests', () {
    testWidgets(
      'Narrow mobile layout (360px) in Tamil with text scale 1.0 - no overflow on expansion',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 2,
          initialLanguage: AppLanguage.ta,
        ));
        await tester.pumpAndSettle();

        // Verify title & subtitle are rendered
        expect(find.text(AppStrings.teaKnowledgeTitle(AppLanguage.ta)), findsOneWidget);

        // Expand blister blight card
        final blisterTile = find.byKey(const Key('disease_tile_blister_blight'));
        expect(blisterTile, findsOneWidget);
        await tester.ensureVisible(blisterTile);
        await tester.tap(blisterTile);
        await tester.pumpAndSettle();

        // Verify Tamil labels are rendered
        expect(find.text(AppStrings.labelSymptoms(AppLanguage.ta)), findsOneWidget);
        expect(find.text(AppStrings.labelManagement(AppLanguage.ta)), findsOneWidget);
        expect(find.text(AppStrings.labelRiskFactors(AppLanguage.ta)), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Narrow mobile layout (360px) in Tamil with text scale 1.3 - no overflow on expansion',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 2,
          initialLanguage: AppLanguage.ta,
        ));
        await tester.pumpAndSettle();

        // Expand blister blight card with 1.3x text scale
        final blisterTile = find.byKey(const Key('disease_tile_blister_blight'));
        await tester.ensureVisible(blisterTile);
        await tester.tap(blisterTile);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Narrow mobile layout (360px) in English with text scale 1.3 - no overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 2,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.teaKnowledgeTitle(AppLanguage.en)), findsOneWidget);

        final blisterTile = find.byKey(const Key('disease_tile_blister_blight'));
        await tester.ensureVisible(blisterTile);
        await tester.tap(blisterTile);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.labelSymptoms(AppLanguage.en)), findsOneWidget);
        expect(find.text(AppStrings.labelManagement(AppLanguage.en)), findsOneWidget);
        expect(find.text(AppStrings.labelRiskFactors(AppLanguage.en)), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Search functionality: filtering, clear button, and empty state on mobile (360px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 2,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        final searchField = find.byKey(const Key('tea_knowledge_search_input'));
        expect(searchField, findsOneWidget);

        // Filter by 'Grey'
        await tester.enterText(searchField, 'Grey');
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('disease_tile_grey_blight')), findsOneWidget);
        expect(find.byKey(const Key('disease_tile_blister_blight')), findsNothing);

        // Clear button should be visible
        final clearBtn = find.byTooltip(AppStrings.searchKnowledgeClearTooltip(AppLanguage.en));
        expect(clearBtn, findsOneWidget);
        await tester.tap(clearBtn);
        await tester.pumpAndSettle();

        // All items restored
        expect(find.byKey(const Key('disease_tile_blister_blight')), findsOneWidget);
        expect(find.byKey(const Key('disease_tile_grey_blight')), findsOneWidget);

        // Enter unmatched query to test empty state
        await tester.enterText(searchField, 'NonExistentPestQuery');
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.noMatchingDiseasesTitle(AppLanguage.en)), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Wide screen / Desktop Linux layout (1024x768) maintains responsive presentation',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 2,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        // On desktop, navigation rail is present
        expect(find.byType(NavigationRail), findsOneWidget);

        // Content displays properly
        expect(find.text(AppStrings.teaKnowledgeTitle(AppLanguage.en)), findsOneWidget);
        expect(find.byKey(const Key('disease_tile_blister_blight')), findsOneWidget);

        // Expand blister blight
        final blisterTile = find.byKey(const Key('disease_tile_blister_blight'));
        await tester.ensureVisible(blisterTile);
        await tester.tap(blisterTile);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.labelSymptoms(AppLanguage.en)), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Bottom navigation bar uses single-line responsive labels on mobile (360px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 0,
          initialLanguage: AppLanguage.en,
        ));
        await tester.pumpAndSettle();

        // Verify single-word concise labels on narrow screens
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Analysis'), findsOneWidget);
        expect(find.text('Knowledge'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);

        // Tap Knowledge destination
        await tester.tap(find.byKey(const Key('nav_destination_knowledge')));
        await tester.pumpAndSettle();

        // Verify Tea Knowledge screen is displayed
        expect(find.text(AppStrings.teaKnowledgeTitle(AppLanguage.en)), findsOneWidget);
        expect(find.byKey(const Key('disease_tile_blister_blight')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Bottom navigation bar uses single-line responsive labels in Tamil on mobile (360px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const SmartTeaApp(
          initialTabIndex: 0,
          initialLanguage: AppLanguage.ta,
        ));
        await tester.pumpAndSettle();

        // Verify single-line Tamil labels
        expect(find.text('முகப்பு'), findsOneWidget);
        expect(find.text('ஆய்வு'), findsOneWidget);
        expect(find.text('அறிவு'), findsOneWidget);
        expect(find.text('வரலாறு'), findsOneWidget);
        expect(find.text('அமைப்புகள்'), findsOneWidget);

        // Tap Knowledge destination in Tamil
        await tester.tap(find.byKey(const Key('nav_destination_knowledge')));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.teaKnowledgeTitle(AppLanguage.ta)), findsOneWidget);
        expect(find.byKey(const Key('disease_tile_blister_blight')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
