import 'package:flutter/widgets.dart';
import 'package:flutter_lite_camera/flutter_lite_camera.dart';

/// Represents a discovered Linux camera device with its zero-based index
/// and human-friendly display label.
class CameraDeviceDescriptor {
  final int index;
  final String rawName;
  final String label;

  const CameraDeviceDescriptor({
    required this.index,
    required this.rawName,
    required this.label,
  });

  /// Builds a list of [CameraDeviceDescriptor] from a list of raw device names.
  /// Deduplicates identical device names by appending an occurrence index,
  /// preserving vendor names without guessing unverified facing directions.
  static List<CameraDeviceDescriptor> fromDeviceList(List<String> rawDevices) {
    if (rawDevices.isEmpty) return const [];

    final nameCounts = <String, int>{};
    for (final name in rawDevices) {
      final trimmed = name.trim().isEmpty ? 'Camera' : name.trim();
      nameCounts[trimmed] = (nameCounts[trimmed] ?? 0) + 1;
    }

    final nameIndexTracker = <String, int>{};
    final descriptors = <CameraDeviceDescriptor>[];

    for (int i = 0; i < rawDevices.length; i++) {
      final raw = rawDevices[i];
      final trimmed = raw.trim().isEmpty ? 'Camera' : raw.trim();
      final hasDuplicates = (nameCounts[trimmed] ?? 0) > 1;

      String label;
      if (hasDuplicates) {
        final occurrence = (nameIndexTracker[trimmed] ?? 0) + 1;
        nameIndexTracker[trimmed] = occurrence;
        label = '$trimmed ($occurrence)';
      } else {
        label = trimmed;
      }

      descriptors.add(
        CameraDeviceDescriptor(index: i, rawName: raw, label: label),
      );
    }

    return descriptors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraDeviceDescriptor &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          rawName == other.rawName &&
          label == other.label;

  @override
  int get hashCode => Object.hash(index, rawName, label);

  @override
  String toString() => 'CameraDeviceDescriptor(index: $index, label: $label)';
}

/// Abstraction for interacting with the Linux webcam.
/// Allows injecting mock camera implementations in unit/widget tests
/// without requiring physical webcam hardware.
abstract class LinuxCameraAdapter {
  Future<List<String>> getDeviceList();
  Future<bool> open(int index);
  Future<Map<String, dynamic>> captureFrame();
  Future<int> startPreview();
  Widget buildPreview(int textureId);
  Future<void> stopPreview();
  Future<void> release();

  /// Convenient helper to retrieve [CameraDeviceDescriptor] items for all available cameras.
  Future<List<CameraDeviceDescriptor>> getDevices() async {
    final names = await getDeviceList();
    return CameraDeviceDescriptor.fromDeviceList(names);
  }
}

/// Production Linux camera adapter delegating to [FlutterLiteCamera].
class DefaultLinuxCameraAdapter implements LinuxCameraAdapter {
  final FlutterLiteCamera _camera;

  DefaultLinuxCameraAdapter({FlutterLiteCamera? camera})
    : _camera = camera ?? FlutterLiteCamera();

  @override
  Future<List<String>> getDeviceList() => _camera.getDeviceList();

  @override
  Future<bool> open(int index) => _camera.open(index);

  @override
  Future<Map<String, dynamic>> captureFrame() => _camera.captureFrame();

  @override
  Future<int> startPreview() => _camera.startPreview();

  @override
  Widget buildPreview(int textureId) => _camera.buildPreview(textureId);

  @override
  Future<void> stopPreview() => _camera.stopPreview();

  @override
  Future<void> release() => _camera.release();

  @override
  Future<List<CameraDeviceDescriptor>> getDevices() async {
    final names = await getDeviceList();
    return CameraDeviceDescriptor.fromDeviceList(names);
  }
}
