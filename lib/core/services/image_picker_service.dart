import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Represents a selected leaf image with metadata and raw byte content
/// for cross-platform rendering (Android, Linux, Web, and Widget Tests).
class PickedLeafImage {
  final String name;
  final String path;
  final Uint8List bytes;
  final int sizeInBytes;
  final DateTime pickedAt;

  PickedLeafImage({
    required this.name,
    required this.path,
    required this.bytes,
    required this.sizeInBytes,
    DateTime? pickedAt,
  }) : pickedAt = pickedAt ?? DateTime.now();

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Exception thrown when image picking fails genuinely
class ImagePickerException implements Exception {
  final String message;
  const ImagePickerException(this.message);

  @override
  String toString() => message;
}

/// Abstract interface for picking leaf images
abstract class ImagePickerService {
  bool get isCameraSupported;
  Future<PickedLeafImage?> pickFromCamera();
  Future<PickedLeafImage?> pickFromGallery();
}

/// Production implementation utilizing package:image_picker
class DefaultImagePickerService implements ImagePickerService {
  final ImagePicker _picker;

  DefaultImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  bool get isCameraSupported {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return false;
    }
    return true;
  }

  @override
  Future<PickedLeafImage?> pickFromCamera() async {
    if (!isCameraSupported) {
      throw const ImagePickerException(
        'Camera capture is not supported on Linux desktop. Please select a leaf photograph using the file picker.',
      );
    }
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (xFile == null) return null; // Graceful cancellation
      final bytes = await xFile.readAsBytes();
      return PickedLeafImage(
        name: xFile.name.isNotEmpty ? xFile.name : 'leaf_camera.jpg',
        path: xFile.path,
        bytes: bytes,
        sizeInBytes: bytes.length,
      );
    } catch (e) {
      if (e is ImagePickerException) rethrow;
      throw ImagePickerException('Failed to capture photo from camera: $e');
    }
  }

  @override
  Future<PickedLeafImage?> pickFromGallery() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (xFile == null) return null; // Graceful cancellation
      final bytes = await xFile.readAsBytes();
      return PickedLeafImage(
        name: xFile.name.isNotEmpty ? xFile.name : 'leaf_gallery.jpg',
        path: xFile.path,
        bytes: bytes,
        sizeInBytes: bytes.length,
      );
    } catch (e) {
      if (e is ImagePickerException) rethrow;
      throw ImagePickerException('Failed to select photo: $e');
    }
  }
}

/// Mock implementation for headless widget testing without physical cameras
class MockImagePickerService implements ImagePickerService {
  PickedLeafImage? nextImageToReturn;
  bool shouldCancel;
  Exception? errorToThrow;
  @override
  final bool isCameraSupported;

  MockImagePickerService({
    this.nextImageToReturn,
    this.shouldCancel = false,
    this.errorToThrow,
    this.isCameraSupported = true,
  });

  @override
  Future<PickedLeafImage?> pickFromCamera() async {
    if (errorToThrow != null) throw errorToThrow!;
    if (shouldCancel) return null;
    return nextImageToReturn;
  }

  @override
  Future<PickedLeafImage?> pickFromGallery() async {
    if (errorToThrow != null) throw errorToThrow!;
    if (shouldCancel) return null;
    return nextImageToReturn;
  }
}
