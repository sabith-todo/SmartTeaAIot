import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/services/image_picker_service.dart';

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

    test('DefaultImagePickerService detects Linux desktop camera unavailability', () {
      final service = DefaultImagePickerService();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
        expect(service.isCameraSupported, isFalse);
        expect(
          () => service.pickFromCamera(),
          throwsA(isA<ImagePickerException>().having(
            (e) => e.message,
            'message',
            contains('Camera capture is not supported on Linux desktop'),
          )),
        );
      }
    });
  });
}
