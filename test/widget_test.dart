import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/services/image_picker_service.dart';
import 'package:smart_tea_aiot/main.dart';
import 'package:smart_tea_aiot/screens/analysis/leaf_analysis_screen.dart';

// Minimal valid 1x1 PNG byte array for headless image decoding
final Uint8List kTransparent1x1Png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  group('SmartTea AIoT Foundation Widget Tests', () {
    testWidgets('Renders Farmer Dashboard with custom theme and initial overview',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp());
      await tester.pumpAndSettle();

      // Verify app branding & greeting
      expect(find.text('SmartTea AIoT'), findsOneWidget);
      expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      expect(find.text('Highland Tea Estate Overview'), findsOneWidget);

      // Verify Milestone 1 status badge
      expect(find.text('Milestone 1 • Foundation App Active'), findsOneWidget);

      // Verify quick action cards
      expect(find.text('Screen Leaf Disease'), findsOneWidget);
      expect(find.text('Disease & Pest Guide'), findsOneWidget);
      expect(find.text('Recent Scans'), findsOneWidget);

      // Verify telemetry disclaimer
      expect(
        find.text('Hardware Telemetry • Connected in Milestone 4'),
        findsOneWidget,
      );
    });

    testWidgets('Bottom navigation switches across all 5 destinations on mobile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp());
      await tester.pumpAndSettle();

      // 1. Navigate to Leaf Analysis via Bottom Navigation Destination
      await tester.tap(find.text('Leaf Analysis'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf Disease Screening'), findsOneWidget);
      expect(
        find.text('AI Model Status: Offline / Pending Integration'),
        findsOneWidget,
      );

      // 2. Navigate to Tea Knowledge
      await tester.tap(find.text('Tea Knowledge'));
      await tester.pumpAndSettle();
      expect(find.text('Tea Agronomy & Disease Guide'), findsOneWidget);
      expect(find.text('Blister Blight'), findsOneWidget);
      expect(find.text('Grey Blight'), findsOneWidget);

      // 3. Navigate to History
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Inspection History'), findsOneWidget);
      expect(find.text('Pending Model Integration (M3)'), findsWidgets);

      // 4. Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Application Settings'), findsOneWidget);
      expect(find.text('Language & Region'), findsOneWidget);
      expect(find.text('Forest Green'), findsOneWidget);
      expect(find.text('#193B2B'), findsOneWidget);

      // 5. Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Vanakkam, Planter!'), findsOneWidget);
    });

    testWidgets('Responsive NavigationRail functions on wide tablet/desktop screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp());
      await tester.pumpAndSettle();

      // In wide mode, NavigationRail should be rendered
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Tap Leaf Analysis rail destination text
      await tester.tap(find.text('Leaf Analysis'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf Disease Screening'), findsOneWidget);
    });

    testWidgets('Quick action card on Home navigates to Leaf Analysis tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp());
      await tester.pumpAndSettle();

      // Tap the quick action card for screening
      await tester.tap(find.text('Screen Leaf Disease'));
      await tester.pumpAndSettle();

      expect(find.text('Leaf Disease Screening'), findsOneWidget);
    });

    testWidgets('Functional Tamil/English language switching via Header Toggle',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp());
      await tester.pumpAndSettle();

      // Initial state is English
      expect(find.text('SmartTea AIoT'), findsOneWidget);
      expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      // Tap header language toggle (displays 'தமிழ்')
      await tester.tap(find.byKey(const Key('header_language_toggle_button')));
      await tester.pumpAndSettle();

      // UI switches to Tamil
      expect(find.text('ஸ்மார்ட் டீ AIoT'), findsOneWidget);
      expect(find.text('வணக்கம், விவசாயி!'), findsOneWidget);
      expect(find.text('முகப்பு'), findsOneWidget);
      expect(find.text('இலை ஆய்வு'), findsOneWidget);

      // Tap header toggle again (displays 'English') to switch back
      await tester.tap(find.byKey(const Key('header_language_toggle_button')));
      await tester.pumpAndSettle();

      // UI returns to English
      expect(find.text('SmartTea AIoT'), findsOneWidget);
      expect(find.text('Vanakkam, Planter!'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Language switching from Settings screen works reactively',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SmartTeaApp(initialTabIndex: 4));
      await tester.pumpAndSettle();

      expect(find.text('Application Settings'), findsOneWidget);

      // Tap Tamil option in Settings
      await tester.tap(find.byKey(const Key('lang_option_ta')));
      await tester.pumpAndSettle();

      expect(find.text('செயலி அமைப்புகள்'), findsOneWidget);
      expect(find.text('மொழி மற்றும் பிராந்தியம்'), findsOneWidget);

      // Tap English option in Settings
      await tester.tap(find.byKey(const Key('lang_option_en')));
      await tester.pumpAndSettle();

      expect(find.text('Application Settings'), findsOneWidget);
    });

    testWidgets('Leaf image selection, preview rendering, and removal flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleImage = PickedLeafImage(
        name: 'sample_blister_leaf.jpg',
        path: '/mock/path/sample_blister_leaf.jpg',
        bytes: kTransparent1x1Png,
        sizeInBytes: kTransparent1x1Png.length,
      );

      final mockPicker = MockImagePickerService(nextImageToReturn: sampleImage);

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: mockPicker,
        initialTabIndex: 1, // Start on Leaf Analysis
      ));
      await tester.pumpAndSettle();

      // Empty upload state
      expect(find.text('No leaf photo selected yet'), findsOneWidget);
      expect(find.byKey(const Key('gallery_pick_button')), findsOneWidget);

      // Pick from gallery
      await tester.tap(find.byKey(const Key('gallery_pick_button')));
      await tester.pumpAndSettle();

      // Dismiss any transient snackbar to clear hit-test targets
      ScaffoldMessenger.of(tester.element(find.byType(LeafAnalysisScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Verify preview is rendered
      expect(find.text('sample_blister_leaf.jpg'), findsOneWidget);
      expect(find.byKey(const Key('remove_image_button')), findsOneWidget);

      // Center remove button in viewport and remove the image
      await tester.ensureVisible(find.byKey(const Key('remove_image_button')));
      await tester.tap(find.byKey(const Key('remove_image_button')));
      await tester.pumpAndSettle();

      // Image is removed, returns to empty upload state
      expect(find.text('No leaf photo selected yet'), findsOneWidget);
    });

    testWidgets('Leaf image picker cancellation handling shows feedback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockPicker = MockImagePickerService(shouldCancel: true);

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: mockPicker,
        initialTabIndex: 1,
      ));
      await tester.pumpAndSettle();

      // Tap Camera button
      await tester.tap(find.byKey(const Key('camera_pick_button')));
      await tester.pump();

      // Verify cancellation notice is displayed and no crash occurs
      expect(find.text('Image selection was cancelled'), findsOneWidget);
      expect(find.text('No leaf photo selected yet'), findsOneWidget);

      // Clear snackbars before exiting test
      ScaffoldMessenger.of(tester.element(find.byType(LeafAnalysisScreen))).clearSnackBars();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Zero-Fake-AI Policy: Displays explicit disclaimer and dialog upon analysis tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleImage = PickedLeafImage(
        name: 'test_leaf.jpg',
        path: '/mock/path/test_leaf.jpg',
        bytes: kTransparent1x1Png,
        sizeInBytes: kTransparent1x1Png.length,
      );

      final mockPicker = MockImagePickerService(nextImageToReturn: sampleImage);

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: mockPicker,
        initialTabIndex: 1,
      ));
      await tester.pumpAndSettle();

      // Verify persistent disclaimer card
      expect(
        find.text('AI Model Status: Offline / Pending Integration'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Disease classification and AI inferences are currently UNAVAILABLE'),
        findsOneWidget,
      );

      // Select an image first
      await tester.tap(find.byKey(const Key('gallery_pick_button')));
      await tester.pumpAndSettle();

      // Dismiss any transient snackbar to clear hit-test targets
      ScaffoldMessenger.of(tester.element(find.byType(LeafAnalysisScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Scroll to center and tap 'Screen Leaf Health' button
      await tester.ensureVisible(find.byKey(const Key('screen_leaf_health_button')));
      await tester.tap(find.byKey(const Key('screen_leaf_health_button')));
      await tester.pumpAndSettle();

      // Verify dialog with zero-fake-AI confirmation
      expect(find.text('AI Prediction Unavailable'), findsOneWidget);
      expect(
        find.textContaining('No machine learning inference model is connected in Milestone 1'),
        findsOneWidget,
      );

      // Dismiss dialog
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      expect(find.text('AI Prediction Unavailable'), findsNothing);
    });

    testWidgets('Responsive narrow-window and large-text layout prevents RenderFlex overflow',
        (WidgetTester tester) async {
      // Test narrow screen (360x640) with 1.3x text scale factor
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final sampleImage = PickedLeafImage(
        name: 'sample_blister_leaf.jpg',
        path: '/mock/path/sample_blister_leaf.jpg',
        bytes: kTransparent1x1Png,
        sizeInBytes: kTransparent1x1Png.length,
      );

      final mockPicker = MockImagePickerService(nextImageToReturn: sampleImage);

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: mockPicker,
        initialTabIndex: 1, // Leaf Analysis
      ));
      await tester.pumpAndSettle();

      // Empty upload box: camera and gallery buttons must fit responsively
      expect(find.byKey(const Key('camera_pick_button')), findsOneWidget);
      expect(find.byKey(const Key('gallery_pick_button')), findsOneWidget);

      // Scroll gallery button into view and pick image to show preview box
      await tester.ensureVisible(find.byKey(const Key('gallery_pick_button')));
      await tester.tap(find.byKey(const Key('gallery_pick_button')));
      await tester.pumpAndSettle();

      // Verify preview box buttons fit responsively without overflow
      expect(find.byKey(const Key('remove_image_button')), findsOneWidget);
      expect(find.byKey(const Key('change_image_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Linux unsupported camera is disabled and displays clear explanatory notice',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Simulate Linux desktop where camera is unsupported
      final linuxPicker = MockImagePickerService(isCameraSupported: false);

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: linuxPicker,
        initialTabIndex: 1,
      ));
      await tester.pumpAndSettle();

      // Explanatory notice must be visible
      expect(
        find.textContaining('Camera capture is not supported on Linux desktop'),
        findsOneWidget,
      );

      // Gallery button is present and active
      expect(find.byKey(const Key('gallery_pick_button')), findsOneWidget);

      // Camera button is present and disabled (onPressed == null)
      final cameraBtn = tester.widget<ElevatedButton>(find.byKey(const Key('camera_pick_button')));
      expect(cameraBtn.onPressed, isNull);
    });

    testWidgets('Genuine image-picker failure displays useful error message',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(450, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final failingPicker = MockImagePickerService(
        errorToThrow: const ImagePickerException('Permission denied by security policy'),
      );

      await tester.pumpWidget(SmartTeaApp(
        imagePickerService: failingPicker,
        initialTabIndex: 1,
      ));
      await tester.pumpAndSettle();

      // Tap gallery button which throws
      await tester.tap(find.byKey(const Key('gallery_pick_button')));
      await tester.pumpAndSettle();

      // Useful error message is shown in SnackBar
      expect(find.text('Permission denied by security policy'), findsOneWidget);
    });
  });
}