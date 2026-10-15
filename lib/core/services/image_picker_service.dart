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

/// Abstract interface for picking leaf images
abstract class ImagePickerService {
  Future<PickedLeafImage?> pickFromCamera();
  Future<PickedLeafImage?> pickFromGallery();
}

/// Production implementation utilizing package:image_picker
class DefaultImagePickerService implements ImagePickerService {
  final ImagePicker _picker;

  DefaultImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<PickedLeafImage?> pickFromCamera() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (xFile == null) return null;
      final bytes = await xFile.readAsBytes();
      return PickedLeafImage(
        name: xFile.name.isNotEmpty ? xFile.name : 'leaf_camera.jpg',
        path: xFile.path,
        bytes: bytes,
        sizeInBytes: bytes.length,
      );
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
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
      if (xFile == null) return null;
      final bytes = await xFile.readAsBytes();
      return PickedLeafImage(
        name: xFile.name.isNotEmpty ? xFile.name : 'leaf_gallery.jpg',
        path: xFile.path,
        bytes: bytes,
        sizeInBytes: bytes.length,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
}

/// Mock implementation for headless widget testing without physical cameras
class MockImagePickerService implements ImagePickerService {
  PickedLeafImage? nextImageToReturn;
  bool shouldCancel = false;

  MockImagePickerService({this.nextImageToReturn, this.shouldCancel = false});

  @override
  Future<PickedLeafImage?> pickFromCamera() async {
    if (shouldCancel) return null;
    return nextImageToReturn;
  }

  @override
  Future<PickedLeafImage?> pickFromGallery() async {
    if (shouldCancel) return null;
    return nextImageToReturn;
  }
}
