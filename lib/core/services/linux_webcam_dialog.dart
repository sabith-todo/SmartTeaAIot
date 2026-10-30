import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'image_picker_service.dart';
import 'linux_camera_adapter.dart';

/// Modal dialog for live webcam viewfinder and capture on Linux desktop.
class LinuxWebcamDialog extends StatefulWidget {
  final LinuxCameraAdapter cameraAdapter;
  final int initialDeviceIndex;

  const LinuxWebcamDialog({
    super.key,
    required this.cameraAdapter,
    this.initialDeviceIndex = 0,
  });

  @override
  State<LinuxWebcamDialog> createState() => _LinuxWebcamDialogState();
}

class _LinuxWebcamDialogState extends State<LinuxWebcamDialog> {
  bool _isInitializing = true;
  bool _isSwitching = false;
  bool _isCapturing = false;
  int? _textureId;
  String? _errorMessage;
  Uint8List? _capturedImageBytes;
  List<CameraDeviceDescriptor> _devices = [];
  int _selectedDeviceIndex = 0;

  @override
  void initState() {
    super.initState();
    _startCamera(widget.initialDeviceIndex);
  }

  Future<void> _startCamera([int initialIndex = 0]) async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final deviceNames = await widget.cameraAdapter.getDeviceList();
      if (!mounted) return;

      if (deviceNames.isEmpty) {
        final lang = LanguageProvider.of(context).currentLanguage;
        setState(() {
          _errorMessage = AppStrings.noCameraFoundMsg(lang);
          _isInitializing = false;
          _devices = [];
        });
        return;
      }

      final descriptors = CameraDeviceDescriptor.fromDeviceList(deviceNames);
      final targetIndex =
          (initialIndex >= 0 && initialIndex < descriptors.length)
          ? initialIndex
          : 0;

      final opened = await widget.cameraAdapter.open(targetIndex);
      if (!mounted) return;

      if (!opened) {
        final lang = LanguageProvider.of(context).currentLanguage;
        setState(() {
          _devices = descriptors;
          _selectedDeviceIndex = targetIndex;
          _errorMessage = AppStrings.cameraPermissionErrorMsg(lang);
          _isInitializing = false;
        });
        return;
      }

      try {
        final texture = await widget.cameraAdapter.startPreview();
        if (mounted) {
          setState(() {
            _devices = descriptors;
            _selectedDeviceIndex = targetIndex;
            _textureId = texture;
            _isInitializing = false;
          });
        }
      } catch (e) {
        // Preview streaming error fallback: allow direct capture without live preview
        if (mounted) {
          setState(() {
            _devices = descriptors;
            _selectedDeviceIndex = targetIndex;
            _textureId = null;
            _isInitializing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final lang = LanguageProvider.of(context).currentLanguage;
        setState(() {
          _errorMessage = '${AppStrings.cameraPermissionErrorMsg(lang)} ($e)';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _switchCamera(int newIndex) async {
    if (newIndex == _selectedDeviceIndex && _errorMessage == null) return;

    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    final lang = LanguageProvider.of(context).currentLanguage;

    // 1. Safely stop and release previous camera
    try {
      await widget.cameraAdapter.stopPreview();
    } catch (_) {}
    try {
      await widget.cameraAdapter.release();
    } catch (_) {}

    // 2. Open new camera
    try {
      final opened = await widget.cameraAdapter.open(newIndex);
      if (!mounted) return;

      if (!opened) {
        setState(() {
          _selectedDeviceIndex = newIndex;
          _textureId = null;
          _errorMessage = AppStrings.cameraSwitchErrorMsg(lang);
          _isSwitching = false;
        });
        return;
      }

      // 3. Start preview on the newly opened camera
      try {
        final textureId = await widget.cameraAdapter.startPreview();
        if (!mounted) return;

        setState(() {
          _selectedDeviceIndex = newIndex;
          _textureId = textureId;
          _errorMessage = null;
          _isSwitching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _selectedDeviceIndex = newIndex;
          _textureId = null;
          _errorMessage = null;
          _isSwitching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedDeviceIndex = newIndex;
        _textureId = null;
        _errorMessage = e is ImagePickerException
            ? e.message
            : AppStrings.cameraSwitchErrorMsg(lang);
        _isSwitching = false;
      });
    }
  }

  Future<void> _captureFrame() async {
    setState(() => _isCapturing = true);
    final lang = LanguageProvider.of(context).currentLanguage;

    try {
      final frame = await widget.cameraAdapter.captureFrame();
      final width = frame['width'] as int?;
      final height = frame['height'] as int?;
      final data = frame['data'] as Uint8List?;

      if (width == null || height == null || data == null || data.isEmpty) {
        throw ImagePickerException(AppStrings.cameraCaptureErrorMsg(lang));
      }

      final encodedBytes = await encodeRgbToImageBytes(data, width, height);

      if (mounted) {
        setState(() {
          _capturedImageBytes = encodedBytes;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ImagePickerException
                  ? e.message
                  : AppStrings.cameraCaptureErrorMsg(lang),
            ),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    }
  }

  void _retake() {
    setState(() {
      _capturedImageBytes = null;
    });
  }

  Future<void> _confirmImage() async {
    if (_capturedImageBytes == null) return;

    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/leaf_webcam_$timestamp.png');
    file.writeAsBytesSync(_capturedImageBytes!, flush: true);

    final picked = PickedLeafImage(
      name: file.uri.pathSegments.last,
      path: file.path,
      bytes: _capturedImageBytes!,
      sizeInBytes: _capturedImageBytes!.length,
    );

    if (mounted) {
      Navigator.of(context).pop(picked);
    }
  }

  @override
  void dispose() {
    widget.cameraAdapter.stopPreview().catchError((_) {});
    widget.cameraAdapter.release().catchError((_) {});
    super.dispose();
  }

  Widget _buildCameraSelector(AppLanguage lang) {
    if (_devices.length <= 1) return const SizedBox.shrink();

    final selectedIndex = _devices.any((d) => d.index == _selectedDeviceIndex)
        ? _selectedDeviceIndex
        : (_devices.isNotEmpty ? _devices.first.index : 0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.creamDark),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videocam_outlined,
            size: 18,
            color: AppTheme.forestGreen,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.cameraSelectorLabel(lang),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const Key('camera_device_dropdown'),
                value: selectedIndex,
                isExpanded: true,
                isDense: true,
                icon: _isSwitching
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.forestGreen,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.forestGreen,
                      ),
                items: _devices.map((device) {
                  return DropdownMenuItem<int>(
                    key: Key('camera_device_item_${device.index}'),
                    value: device.index,
                    child: Text(
                      device.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                  );
                }).toList(),
                onChanged:
                    (_isSwitching ||
                        _isInitializing ||
                        _isCapturing ||
                        _capturedImageBytes != null)
                    ? null
                    : (newIndex) {
                        if (newIndex != null &&
                            newIndex != _selectedDeviceIndex) {
                          _switchCamera(newIndex);
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context).currentLanguage;

    return Dialog(
      backgroundColor: AppTheme.creamLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.forestGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.cameraDialogTitle(lang),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.cameraDialogSubtitle(lang),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('close_webcam_dialog_icon_button'),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppTheme.textMuted,
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.creamDark),

              // Camera Selector (shown only when multiple cameras are available)
              if (_devices.length > 1) _buildCameraSelector(lang),

              // Viewfinder / Captured image / Error container
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.creamDark),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildCameraBody(lang),
                      ),
                    ),
                  ),
                ),
              ),

              // Dialog Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildActionButtons(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBody(AppLanguage lang) {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.leafGreen),
            const SizedBox(height: 14),
            Text(
              AppStrings.cameraInitializing(lang),
              style: const TextStyle(
                color: AppTheme.creamLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSwitching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.leafGreen),
            const SizedBox(height: 14),
            Text(
              AppStrings.cameraSwitching(lang),
              style: const TextStyle(
                color: AppTheme.creamLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.warningAmber,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.creamLight,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_capturedImageBytes != null) {
      return Image.memory(_capturedImageBytes!, fit: BoxFit.contain);
    }

    if (_isCapturing) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.leafGreen),
      );
    }

    if (_textureId != null) {
      return widget.cameraAdapter.buildPreview(_textureId!);
    }

    // Direct capture ready state (when texture preview is unsupported)
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam, size: 48, color: AppTheme.leafGreen),
          const SizedBox(height: 10),
          Text(
            AppStrings.btnCapturePhoto(lang),
            style: const TextStyle(color: AppTheme.creamLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLanguage lang) {
    if (_errorMessage != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          key: const Key('cancel_webcam_dialog_button'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(AppStrings.btnCancel(lang)),
        ),
      );
    }

    if (_capturedImageBytes != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            key: const Key('retake_webcam_frame_button'),
            onPressed: _retake,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppStrings.btnRetakePhoto(lang)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            key: const Key('confirm_webcam_frame_button'),
            onPressed: _confirmImage,
            icon: const Icon(Icons.check, size: 18),
            label: Text(AppStrings.btnUsePhoto(lang)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: AppTheme.creamLight,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          key: const Key('cancel_webcam_dialog_button'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(AppStrings.btnCancel(lang)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          key: const Key('capture_webcam_frame_button'),
          onPressed: (_isInitializing || _isCapturing || _isSwitching)
              ? null
              : _captureFrame,
          icon: const Icon(Icons.camera_alt, size: 18),
          label: Text(AppStrings.btnCapturePhoto(lang)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.forestGreen,
            foregroundColor: AppTheme.creamLight,
          ),
        ),
      ],
    );
  }
}

/// Helper to decode RGB raw pixel data into either PNG or BMP bytes.
Future<Uint8List> encodeRgbToImageBytes(
  Uint8List rgbBytes,
  int width,
  int height,
) async {
  try {
    final rgba = Uint8List(width * height * 4);
    int src = 0;
    int dst = 0;
    final totalPixels = width * height;
    for (int i = 0; i < totalPixels; i++) {
      rgba[dst] = rgbBytes[src];
      rgba[dst + 1] = rgbBytes[src + 1];
      rgba[dst + 2] = rgbBytes[src + 2];
      rgba[dst + 3] = 255;
      src += 3;
      dst += 4;
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final uiImage = await completer.future.timeout(
      const Duration(milliseconds: 300),
    );
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
  } catch (_) {
    // Fall back to pure-Dart BMP if dart:ui PNG encoding fails or times out
  }

  return encodeRgbToBmp(rgbBytes, width, height);
}

/// Synchronous pure-Dart 24-bit top-down BMP encoder.
Uint8List encodeRgbToBmp(Uint8List rgbBytes, int width, int height) {
  final rowBytes = (width * 3 + 3) & ~3;
  final imageSize = rowBytes * height;
  final fileSize = 54 + imageSize;

  final buffer = Uint8List(fileSize);
  final byteData = ByteData.view(buffer.buffer);

  // Bitmap File Header (14 bytes)
  buffer[0] = 0x42; // 'B'
  buffer[1] = 0x4D; // 'M'
  byteData.setUint32(2, fileSize, Endian.little);
  byteData.setUint16(6, 0, Endian.little);
  byteData.setUint16(8, 0, Endian.little);
  byteData.setUint32(10, 54, Endian.little);

  // DIB Header (BITMAPINFOHEADER - 40 bytes)
  byteData.setUint32(14, 40, Endian.little);
  byteData.setInt32(18, width, Endian.little);
  byteData.setInt32(22, -height, Endian.little); // negative = top-down
  byteData.setUint16(26, 1, Endian.little);
  byteData.setUint16(28, 24, Endian.little);
  byteData.setUint32(30, 0, Endian.little); // BI_RGB
  byteData.setUint32(34, imageSize, Endian.little);
  byteData.setInt32(38, 2835, Endian.little);
  byteData.setInt32(42, 2835, Endian.little);
  byteData.setUint32(46, 0, Endian.little);
  byteData.setUint32(50, 0, Endian.little);

  int src = 0;
  int dst = 54;
  final padding = rowBytes - (width * 3);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final r = rgbBytes[src];
      final g = rgbBytes[src + 1];
      final b = rgbBytes[src + 2];
      buffer[dst] = b;
      buffer[dst + 1] = g;
      buffer[dst + 2] = r;
      src += 3;
      dst += 3;
    }
    for (int p = 0; p < padding; p++) {
      buffer[dst++] = 0;
    }
  }

  return buffer;
}
