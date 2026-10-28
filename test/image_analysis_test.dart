import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_tea_aiot/core/services/image_picker_service.dart';
import 'package:smart_tea_aiot/core/services/linux_camera_adapter.dart';
import 'package:smart_tea_aiot/core/services/linux_webcam_dialog.dart';

class MockLinuxCameraAdapter implements LinuxCameraAdapter {
  final List<String> devices;
  final bool openSuccess;
  final Map<String, dynamic>? frameToReturn;
  final Object? errorToThrow;
  int? lastOpenedIndex;
  List<int> openedIndices = [];
  bool isOpened = false;
  bool isPreviewRunning = false;
  bool isReleased = false;

  MockLinuxCameraAdapter({
    this.devices = const ['/dev/video0 (HP Wide Vision HD Camera)'],
    this.openSuccess = true,
    this.frameToReturn,
    this.errorToThrow,
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
    isOpened = openSuccess;
    return openSuccess;
  }

  @override
  Future<Map<String, dynamic>> captureFrame() async {
    if (errorToThrow != null) throw errorToThrow!;
    if (frameToReturn != null) return frameToReturn!;
    // Default 2x2 RGB frame (12 bytes)
    final syntheticRgb = Uint8List.fromList([
      255, 0, 0,   0, 255, 0,
      0, 0, 255,   255, 255, 255,
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
    return 101;
  }

  @override
  Widget buildPreview(int textureId) => const SizedBox(key: Key('mock_preview'));

  @override
  Future<void> stopPreview() async {
    isPreviewRunning = false;
  }

  @override
  Future<void> release() async {
    isReleased = true;
  }

  @override
  Future<List<CameraDeviceDescriptor>> getDevices() async {
    final names = await getDeviceList();
    return CameraDeviceDescriptor.fromDeviceList(names);
  }
}

class FakeImagePicker extends ImagePicker {
  CameraDevice? lastPreferredCameraDevice;
  ImageSource? lastImageSource;
  XFile? fileToReturn;

  FakeImagePicker({this.fileToReturn});

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastImageSource = source;
    lastPreferredCameraDevice = preferredCameraDevice;
    return fileToReturn;
  }
}

void main() {
  group('ImagePickerService and PickedLeafImage Tests', () {
    test('PickedLeafImage correctly formats byte size', () {
      final imgBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final small = PickedLeafImage(
        name: 'tiny.jpg',
        path: '/tmp/tiny.jpg',
        bytes: imgBytes,
        sizeInBytes: 500,
      );
      expect(small.formattedSize, '500 B');

      final medium = PickedLeafImage(
        name: 'med.jpg',
        path: '/tmp/med.jpg',
        bytes: imgBytes,
        sizeInBytes: 2048,
      );
      expect(medium.formattedSize, '2.0 KB');

      final large = PickedLeafImage(
        name: 'large.jpg',
        path: '/tmp/large.jpg',
        bytes: imgBytes,
        sizeInBytes: 2 * 1024 * 1024,
      );
      expect(large.formattedSize, '2.00 MB');
    });

    test('MockImagePickerService returns simulated image', () async {
      final sampleBytes = Uint8List.fromList([10, 20, 30]);
      final mockImage = PickedLeafImage(
        name: 'sample_tea_leaf.jpg',
        path: '/mock/path/sample_tea_leaf.jpg',
        bytes: sampleBytes,
        sizeInBytes: sampleBytes.length,
      );

      final service = MockImagePickerService(nextImageToReturn: mockImage);
      final cameraResult = await service.pickFromCamera();
      expect(cameraResult?.name, 'sample_tea_leaf.jpg');

      final galleryResult = await service.pickFromGallery();
      expect(galleryResult?.name, 'sample_tea_leaf.jpg');
    });

    test('MockImagePickerService handles cancellation', () async {
      final service = MockImagePickerService(shouldCancel: true);
      final cameraResult = await service.pickFromCamera();
      expect(cameraResult, isNull);

      final galleryResult = await service.pickFromGallery();
      expect(galleryResult, isNull);
    });

    test('MockImagePickerService propagates genuine error', () async {
      final service = MockImagePickerService(
        errorToThrow: const ImagePickerException('Hardware sensor failure'),
      );
      expect(() => service.pickFromCamera(), throwsA(isA<ImagePickerException>()));
      expect(() => service.pickFromGallery(), throwsA(isA<ImagePickerException>()));
    });

    test('DefaultImagePickerService reports camera supported by default on all platforms', () {
      final service = DefaultImagePickerService();
      expect(service.isCameraSupported, isTrue);
    });

    test('DefaultImagePickerService respects isCameraSupported override when false', () async {
      final service = DefaultImagePickerService(isCameraSupported: false);
      expect(service.isCameraSupported, isFalse);
      await expectLater(
        service.pickFromCamera(),
        throwsA(isA<ImagePickerException>().having(
          (e) => e.message,
          'message',
          contains('Camera capture is not supported on this device'),
        )),
      );
    });

    test('DefaultImagePickerService performs Linux webcam headless capture successfully', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter();
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        final result = await service.pickFromCamera();
        expect(result, isNotNull);
        expect(result!.name, startsWith('leaf_webcam_'));
        expect(result.bytes.isNotEmpty, isTrue);
        expect(result.sizeInBytes, equals(result.bytes.length));
        expect(mockAdapter.isOpened, isTrue);
        expect(mockAdapter.isReleased, isTrue);

        // Verify the temporary file was written
        final file = File(result.path);
        expect(await file.exists(), isTrue);
        await file.delete();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService throws when no Linux webcam devices are detected', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter(devices: const []);
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        await expectLater(
          service.pickFromCamera(),
          throwsA(isA<ImagePickerException>().having(
            (e) => e.message,
            'message',
            contains('No camera device detected on this system'),
          )),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService throws when Linux webcam open fails', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter(openSuccess: false);
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        await expectLater(
          service.pickFromCamera(),
          throwsA(isA<ImagePickerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to access webcam device'),
          )),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService throws and releases when frame capture fails', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter(
          frameToReturn: {'width': 0, 'height': 0, 'data': Uint8List(0)},
        );
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        await expectLater(
          service.pickFromCamera(),
          throwsA(isA<ImagePickerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to capture frame from webcam'),
          )),
        );
        expect(mockAdapter.isReleased, isTrue);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService defaults to rear camera on Android/mobile', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final fakePicker = FakeImagePicker();
        final service = DefaultImagePickerService(picker: fakePicker);

        await service.pickFromCamera();
        expect(fakePicker.lastImageSource, ImageSource.camera);
        expect(fakePicker.lastPreferredCameraDevice, CameraDevice.rear);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService respects custom preferredCameraDevice', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final fakePicker = FakeImagePicker();
        final service = DefaultImagePickerService(picker: fakePicker);

        await service.pickFromCamera(null, CameraDevice.front);
        expect(fakePicker.lastPreferredCameraDevice, CameraDevice.front);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService respects preferredLinuxCameraIndex', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter(
          devices: const [
            '/dev/video0 (HP Wide Vision HD Camera)',
            '/dev/video1 (External Leaf Microscope)',
          ],
        );
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        final result = await service.pickFromCamera(null, null, 1);
        expect(result, isNotNull);
        expect(mockAdapter.lastOpenedIndex, equals(1));
        expect(mockAdapter.isReleased, isTrue);

        final file = File(result!.path);
        if (await file.exists()) {
          await file.delete();
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('DefaultImagePickerService falls back to index 0 when preferredLinuxCameraIndex is out of range', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        final mockAdapter = MockLinuxCameraAdapter(
          devices: const ['/dev/video0 (Single Camera)'],
        );
        final service = DefaultImagePickerService(
          linuxCameraAdapter: mockAdapter,
        );

        final result = await service.pickFromCamera(null, null, 99);
        expect(result, isNotNull);
        expect(mockAdapter.lastOpenedIndex, equals(0));

        final file = File(result!.path);
        if (await file.exists()) {
          await file.delete();
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('MockImagePickerService tracks lastRequestedCameraDevice and lastRequestedLinuxIndex', () async {
      final mock = MockImagePickerService();
      await mock.pickFromCamera(null, CameraDevice.front, 2);
      expect(mock.lastRequestedCameraDevice, equals(CameraDevice.front));
      expect(mock.lastRequestedLinuxIndex, equals(2));
    });

    test('encodeRgbToBmp produces valid 24-bit BMP image structure', () {
      final rgb = Uint8List.fromList([
        255, 0, 0,   0, 255, 0,
        0, 0, 255,   255, 255, 255,
      ]);
      final bmp = encodeRgbToBmp(rgb, 2, 2);

      // Verify BMP magic header
      expect(bmp[0], 0x42); // 'B'
      expect(bmp[1], 0x4D); // 'M'

      final byteData = ByteData.view(bmp.buffer);
      // File size in header matches actual bytes length
      expect(byteData.getUint32(2, Endian.little), equals(bmp.length));
      // Pixel offset is 54
      expect(byteData.getUint32(10, Endian.little), 54);
      // DIB header size is 40
      expect(byteData.getUint32(14, Endian.little), 40);
      // Width is 2
      expect(byteData.getInt32(18, Endian.little), 2);
      // Height is -2 (top-down)
      expect(byteData.getInt32(22, Endian.little), -2);
      // Color planes is 1
      expect(byteData.getUint16(26, Endian.little), 1);
      // Bit count is 24
      expect(byteData.getUint16(28, Endian.little), 24);
    });
  });

  group('CameraDeviceDescriptor Tests', () {
    test('fromDeviceList handles empty list', () {
      final list = CameraDeviceDescriptor.fromDeviceList(const []);
      expect(list, isEmpty);
    });

    test('fromDeviceList preserves single unique device name without suffix', () {
      final list = CameraDeviceDescriptor.fromDeviceList(
        const ['HP Wide Vision HD Camera'],
      );
      expect(list.length, equals(1));
      expect(list[0].index, equals(0));
      expect(list[0].rawName, equals('HP Wide Vision HD Camera'));
      expect(list[0].label, equals('HP Wide Vision HD Camera'));
    });

    test('fromDeviceList preserves distinct device names without guessing front/rear', () {
      final list = CameraDeviceDescriptor.fromDeviceList(const [
        'HP Wide Vision HD Camera',
        'USB 2.0 Leaf Microscope',
      ]);
      expect(list.length, equals(2));
      expect(list[0].index, equals(0));
      expect(list[0].label, equals('HP Wide Vision HD Camera'));
      expect(list[1].index, equals(1));
      expect(list[1].label, equals('USB 2.0 Leaf Microscope'));
    });

    test('fromDeviceList disambiguates duplicate device names with occurrence indices', () {
      final list = CameraDeviceDescriptor.fromDeviceList(const [
        'HP Wide Vision HD Camera',
        'HP Wide Vision HD Camera',
      ]);
      expect(list.length, equals(2));
      expect(list[0].index, equals(0));
      expect(list[0].label, equals('HP Wide Vision HD Camera (1)'));
      expect(list[1].index, equals(1));
      expect(list[1].label, equals('HP Wide Vision HD Camera (2)'));
    });

    test('fromDeviceList trims whitespace and replaces empty strings with fallback', () {
      final list = CameraDeviceDescriptor.fromDeviceList(const [
        '   ',
        '  External Webcam  ',
      ]);
      expect(list.length, equals(2));
      expect(list[0].label, equals('Camera'));
      expect(list[1].label, equals('External Webcam'));
    });

    test('CameraDeviceDescriptor equality and hashCode', () {
      const desc1 = CameraDeviceDescriptor(index: 0, rawName: 'Dev0', label: 'Dev0');
      const desc2 = CameraDeviceDescriptor(index: 0, rawName: 'Dev0', label: 'Dev0');
      const desc3 = CameraDeviceDescriptor(index: 1, rawName: 'Dev1', label: 'Dev1');

      expect(desc1, equals(desc2));
      expect(desc1.hashCode, equals(desc2.hashCode));
      expect(desc1, isNot(equals(desc3)));
      expect(desc1.toString(), contains('index: 0'));
    });
  });
}
