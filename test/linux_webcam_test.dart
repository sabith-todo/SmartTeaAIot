import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/localization/app_language.dart';
import 'package:smart_tea_aiot/core/localization/app_strings.dart';
import 'package:smart_tea_aiot/core/services/image_picker_service.dart';
import 'package:smart_tea_aiot/core/services/linux_camera_adapter.dart';
import 'package:smart_tea_aiot/core/services/linux_webcam_dialog.dart';

class TestMockLinuxCameraAdapter implements LinuxCameraAdapter {
  final List<String> devices;
  final bool openSuccess;
  final Map<String, dynamic>? frameToReturn;
  final Object? errorToThrow;
  final bool Function(int index)? onOpen;
  int? lastOpenedIndex;
  List<int> openedIndices = [];
  int releaseCount = 0;
  int stopPreviewCount = 0;
  bool isOpened = false;
  bool isPreviewRunning = false;
  bool isReleased = false;

  TestMockLinuxCameraAdapter({
    this.devices = const ['/dev/video0 (HP Wide Vision HD Camera)'],
    this.openSuccess = true,
    this.frameToReturn,
    this.errorToThrow,
    this.onOpen,
  });

  @override
  Future<List<String>> getDeviceList() async {
    if (errorToThrow != null) throw errorToThrow!;
    return devices;
  }

  @override
  Future<bool> open(int index) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastOpenedIndex = index;
    openedIndices.add(index);
    if (onOpen != null) {
      final res = onOpen!(index);
      isOpened = res;
      return res;
    }
    isOpened = openSuccess;
    return openSuccess;
  }

  @override
  Future<Map<String, dynamic>> captureFrame() async {
    if (errorToThrow != null) throw errorToThrow!;
    if (frameToReturn != null) return frameToReturn!;
    // 2x2 synthetic RGB frame
    final syntheticRgb = Uint8List.fromList([
      20, 150, 40,   20, 150, 40,
      10, 100, 30,   10, 100, 30,
    ]);
    return {
      'width': 2,
      'height': 2,
      'data': syntheticRgb,
    };
  }

  @override
  Future<int> startPreview() async {
    if (errorToThrow != null) throw errorToThrow!;
    isPreviewRunning = true;
    return 200 + (lastOpenedIndex ?? 0);
  }

  @override
  Widget buildPreview(int textureId) => Container(
        key: const Key('mock_viewfinder_texture'),
        color: Colors.black,
        child: Text('Texture: $textureId'),
      );

  @override
  Future<void> stopPreview() async {
    stopPreviewCount++;
    isPreviewRunning = false;
  }

  @override
  Future<void> release() async {
    releaseCount++;
    isReleased = true;
  }

  @override
  Future<List<CameraDeviceDescriptor>> getDevices() async {
    final names = await getDeviceList();
    return CameraDeviceDescriptor.fromDeviceList(names);
  }
}

Widget buildTestWebcamApp({
  required LinuxCameraAdapter adapter,
  AppLanguage initialLanguage = AppLanguage.en,
  int initialDeviceIndex = 0,
  void Function(PickedLeafImage?)? onResult,
}) {
  final controller = LanguageController();
  controller.setLanguage(initialLanguage);

  return LanguageProvider(
    controller: controller,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await showDialog<PickedLeafImage?>(
                  context: context,
                  builder: (ctx) => LinuxWebcamDialog(
                    cameraAdapter: adapter,
                    initialDeviceIndex: initialDeviceIndex,
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('LinuxWebcamDialog Widget Tests', () {
    testWidgets('Renders viewfinder and starts preview on successful initialization',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter();

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title and viewfinder elements
      expect(find.text(AppStrings.cameraDialogTitle(AppLanguage.en)), findsOneWidget);
      expect(find.byKey(const Key('mock_viewfinder_texture')), findsOneWidget);
      expect(find.byKey(const Key('capture_webcam_frame_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_webcam_dialog_button')), findsOneWidget);
      expect(adapter.isOpened, isTrue);
      expect(adapter.isPreviewRunning, isTrue);

      // Cancel and verify cleanup
      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LinuxWebcamDialog), findsNothing);
      expect(adapter.isReleased, isTrue);
    });

    testWidgets('Displays error notice when no camera devices are available',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(devices: const []);

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noCameraFoundMsg(AppLanguage.en)), findsOneWidget);
      expect(find.byKey(const Key('capture_webcam_frame_button')), findsNothing);
      expect(find.byKey(const Key('cancel_webcam_dialog_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Displays error notice when webcam open fails',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(openSuccess: false);

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cameraPermissionErrorMsg(AppLanguage.en)), findsOneWidget);
      expect(find.byKey(const Key('capture_webcam_frame_button')), findsNothing);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Full capture flow: captures frame, retakes, and confirms photo',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter();
      PickedLeafImage? capturedResult;

      await tester.pumpWidget(buildTestWebcamApp(
        adapter: adapter,
        onResult: (res) => capturedResult = res,
      ));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // 1. Capture frame
      await tester.tap(find.byKey(const Key('capture_webcam_frame_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify review buttons appear
      expect(find.byKey(const Key('retake_webcam_frame_button')), findsOneWidget);
      expect(find.byKey(const Key('confirm_webcam_frame_button')), findsOneWidget);

      // 2. Test Retake
      await tester.tap(find.byKey(const Key('retake_webcam_frame_button')));
      await tester.pumpAndSettle();

      // Back to viewfinder
      expect(find.byKey(const Key('capture_webcam_frame_button')), findsOneWidget);

      // 3. Capture again and Confirm
      await tester.tap(find.byKey(const Key('capture_webcam_frame_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('confirm_webcam_frame_button')));
      await tester.tap(find.byKey(const Key('confirm_webcam_frame_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Dialog should be dismissed with valid result
      expect(find.byType(LinuxWebcamDialog), findsNothing);
      expect(capturedResult, isNotNull);
      expect(capturedResult!.bytes.isNotEmpty, isTrue);
      expect(capturedResult!.name, startsWith('leaf_webcam_'));
    });

    testWidgets('Renders Tamil localized strings properly in webcam dialog',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter();

      await tester.pumpWidget(buildTestWebcamApp(
        adapter: adapter,
        initialLanguage: AppLanguage.ta,
      ));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify Tamil title and buttons
      expect(find.text(AppStrings.cameraDialogTitle(AppLanguage.ta)), findsOneWidget);
      expect(find.text(AppStrings.btnCapturePhoto(AppLanguage.ta)), findsOneWidget);
      expect(find.text(AppStrings.btnCancel(AppLanguage.ta)), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Single camera: does not render camera selector dropdown',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(
        devices: const ['/dev/video0 (Single Camera)'],
      );

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Selector dropdown should NOT be displayed when only 1 device is detected
      expect(find.byKey(const Key('camera_device_dropdown')), findsNothing);
      expect(adapter.lastOpenedIndex, equals(0));

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Multiple cameras: renders selector dropdown with deduplicated names',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(
        devices: const [
          'HP Wide Vision HD Camera',
          'HP Wide Vision HD Camera',
          'External USB Microscope',
        ],
      );

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Selector dropdown should be displayed
      expect(find.byKey(const Key('camera_device_dropdown')), findsOneWidget);
      expect(find.text('Camera Device'), findsOneWidget);
      expect(find.text('HP Wide Vision HD Camera (1)'), findsWidgets);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Switches camera safely: stops preview, releases previous camera, opens new',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(
        devices: const [
          'Integrated Webcam',
          'External Macro Lens',
        ],
      );

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(adapter.lastOpenedIndex, equals(0));
      expect(find.text('Texture: 200'), findsOneWidget);

      // Open dropdown and switch to External Macro Lens (index 1)
      await tester.tap(find.byKey(const Key('camera_device_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('camera_device_item_1')).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify lifecycle: stopPreview and release called, then new camera opened
      expect(adapter.stopPreviewCount, greaterThanOrEqualTo(1));
      expect(adapter.releaseCount, greaterThanOrEqualTo(1));
      expect(adapter.openedIndices, equals([0, 1]));
      expect(adapter.lastOpenedIndex, equals(1));
      expect(find.text('Texture: 201'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Camera switching failure: displays error message gracefully and keeps dialog usable',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(
        devices: const [
          'Integrated Webcam',
          'Broken External Camera',
        ],
        onOpen: (idx) => idx == 0, // only camera 0 succeeds, camera 1 fails
      );

      await tester.pumpWidget(buildTestWebcamApp(adapter: adapter));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(adapter.lastOpenedIndex, equals(0));

      // Attempt to switch to failing camera (index 1)
      await tester.tap(find.byKey(const Key('camera_device_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('camera_device_item_1')).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Switching error should be displayed
      expect(find.text(AppStrings.cameraSwitchErrorMsg(AppLanguage.en)), findsOneWidget);

      // Dialog should still be usable to close or retry
      expect(find.byKey(const Key('cancel_webcam_dialog_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LinuxWebcamDialog), findsNothing);
    });

    testWidgets('Initial device index is respected when specified',
        (WidgetTester tester) async {
      final adapter = TestMockLinuxCameraAdapter(
        devices: const [
          'Camera 0',
          'Camera 1',
        ],
      );

      await tester.pumpWidget(buildTestWebcamApp(
        adapter: adapter,
        initialDeviceIndex: 1,
      ));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(adapter.lastOpenedIndex, equals(1));
      expect(find.text('Texture: 201'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_webcam_dialog_button')));
      await tester.pumpAndSettle();
    });
  });
}
