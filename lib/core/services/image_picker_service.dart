import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'linux_camera_adapter.dart';
import 'linux_webcam_dialog.dart';

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
  Future<PickedLeafImage?> pickFromCamera([
    BuildContext? context,
    CameraDevice? preferredCameraDevice,
    int? preferredLinuxCameraIndex,
  ]);
  Future<PickedLeafImage?> pickFromGallery();
}

/// Production implementation utilizing package:image_picker on mobile/web
/// and native V4L2 webcam capture on Linux desktop.
class DefaultImagePickerService implements ImagePickerService {
  final ImagePicker _picker;
  final LinuxCameraAdapter _linuxCameraAdapter;
  final bool? _isCameraSupportedOverride;
  final CameraDevice defaultPreferredCameraDevice;
  final int defaultLinuxCameraIndex;

  DefaultImagePickerService({
    ImagePicker? picker,
    LinuxCameraAdapter? linuxCameraAdapter,
    bool? isCameraSupported,
    this.defaultPreferredCameraDevice = CameraDevice.rear,
    this.defaultLinuxCameraIndex = 0,
  })  : _picker = picker ?? ImagePicker(),
        _linuxCameraAdapter = linuxCameraAdapter ?? DefaultLinuxCameraAdapter(),
        _isCameraSupportedOverride = isCameraSupported;

  @override
  bool get isCameraSupported {
    if (_isCameraSupportedOverride != null) {
      return _isCameraSupportedOverride;
    }
    // Fully supported on Android, iOS, Web, and Linux desktop
    return true;
  }

  @override
  Future<PickedLeafImage?> pickFromCamera([
    BuildContext? context,
    CameraDevice? preferredCameraDevice,
    int? preferredLinuxCameraIndex,
  ]) async {
    if (!isCameraSupported) {
      throw const ImagePickerException(
        'Camera capture is not supported on this device. Please select a leaf photograph using the file picker.',
      );
    }

    final targetLinuxIndex = preferredLinuxCameraIndex ?? defaultLinuxCameraIndex;
    final targetCameraDevice = preferredCameraDevice ?? defaultPreferredCameraDevice;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      return _pickFromLinuxCamera(context, targetLinuxIndex);
    }

    // Android, iOS, and Web fallback
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: targetCameraDevice,
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

  Future<PickedLeafImage?> _pickFromLinuxCamera(
    BuildContext? context,
    int initialIndex,
  ) async {
    if (context != null && context.mounted) {
      return showDialog<PickedLeafImage?>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => LinuxWebcamDialog(
          cameraAdapter: _linuxCameraAdapter,
          initialDeviceIndex: initialIndex,
        ),
      );
    }

    // Direct headless capture (used when context is omitted, e.g. in test suites)
    return _captureDirectFromLinuxCamera(initialIndex);
  }

  Future<PickedLeafImage?> _captureDirectFromLinuxCamera(int deviceIndex) async {
    final devices = await _linuxCameraAdapter.getDeviceList();
    if (devices.isEmpty) {
      throw const ImagePickerException(
        'No camera device detected on this system. Please connect a webcam or use the file picker.',
      );
    }

    final targetIndex = (deviceIndex >= 0 && deviceIndex < devices.length)
        ? deviceIndex
        : 0;

    final opened = await _linuxCameraAdapter.open(targetIndex);
    if (!opened) {
      throw const ImagePickerException(
        'Failed to access webcam device. It may be in use by another application or permissions may be restricted.',
      );
    }

    try {
      final frame = await _linuxCameraAdapter.captureFrame();
      final width = frame['width'] as int?;
      final height = frame['height'] as int?;
      final data = frame['data'] as Uint8List?;

      if (width == null || height == null || data == null || data.isEmpty) {
        throw const ImagePickerException('Failed to capture frame from webcam.');
      }

      final imageBytes = await encodeRgbToImageBytes(data, width, height);
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/leaf_webcam_$timestamp.png');
      file.writeAsBytesSync(imageBytes, flush: true);

      return PickedLeafImage(
        name: file.uri.pathSegments.last,
        path: file.path,
        bytes: imageBytes,
        sizeInBytes: imageBytes.length,
      );
    } finally {
      await _linuxCameraAdapter.release();
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
  CameraDevice? lastRequestedCameraDevice;
  int? lastRequestedLinuxIndex;
  @override
  final bool isCameraSupported;

  MockImagePickerService({
    this.nextImageToReturn,
    this.shouldCancel = false,
    this.errorToThrow,
    this.isCameraSupported = true,
  });

  @override
  Future<PickedLeafImage?> pickFromCamera([
    BuildContext? context,
    CameraDevice? preferredCameraDevice,
    int? preferredLinuxCameraIndex,
  ]) async {
    lastRequestedCameraDevice = preferredCameraDevice;
    lastRequestedLinuxIndex = preferredLinuxCameraIndex;
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
