import 'package:flutter/widgets.dart';
import 'package:flutter_lite_camera/flutter_lite_camera.dart';

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
}
