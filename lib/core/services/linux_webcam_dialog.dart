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

  const LinuxWebcamDialog({
    super.key,
    required this.cameraAdapter,
  });

  @override
  State<LinuxWebcamDialog> createState() => _LinuxWebcamDialogState();
}

class _LinuxWebcamDialogState extends State<LinuxWebcamDialog> {
  bool _isInitializing = true;
  bool _isCapturing = false;
  int? _textureId;
  String? _errorMessage;
  Uint8List? _capturedImageBytes;
  int? _capturedWidth;
  int? _capturedHeight;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final devices = await widget.cameraAdapter.getDeviceList();
      if (!mounted) return;

      if (devices.isEmpty) {
        final lang = LanguageProvider.of(context).currentLanguage;
        setState(() {
          _errorMessage = AppStrings.noCameraFoundMsg(lang);
          _isInitializing = false;
        });
        return;
      }

      final opened = await widget.cameraAdapter.open(0);
      if (!mounted) return;

      if (!opened) {
        final lang = LanguageProvider.of(context).currentLanguage;
        setState(() {
          _errorMessage = AppStrings.cameraPermissionErrorMsg(lang);
          _isInitializing = false;
        });
        return;
      }

      try {
        final texture = await widget.cameraAdapter.startPreview();
        if (mounted) {
          setState(() {
            _textureId = texture;
            _isInitializing = false;
          });
        }
      } catch (e) {
        // Preview streaming error fallback: allow direct capture without live preview
        if (mounted) {
          setState(() {
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
          _capturedWidth = width;
          _capturedHeight = height;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ImagePickerException
                ? e.message
                : AppStrings.cameraCaptureErrorMsg(lang)),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    }
  }

  void _retake() {
    setState(() {
      _capturedImageBytes = null;
      _capturedWidth = null;
      _capturedHeight = null;
    });
  }

  Future<void> _confirmImage() async {
    if (_capturedImageBytes == null) return;

    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/leaf_webcam_$timestamp.png');
    await file.writeAsBytes(_capturedImageBytes!, flush: true);

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

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context).currentLanguage;

    return Dialog(
      backgroundColor: AppTheme.creamLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
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
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.cameraDialogSubtitle(lang),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('webcam_dialog_close_button'),
                    icon: const Icon(Icons.close, size: 20),
                    color: AppTheme.textMuted,
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.creamDark),

            // Viewfinder / Captured image / Error container
            Padding(
              padding: const EdgeInsets.all(18),
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

            // Dialog Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: _buildActionButtons(lang),
            ),
          ],
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
      return Image.memory(
        _capturedImageBytes!,
        fit: BoxFit.contain,
      );
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
          const Icon(
            Icons.videocam,
            size: 48,
            color: AppTheme.leafGreen,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.btnCapturePhoto(lang),
            style: const TextStyle(
              color: AppTheme.creamLight,
              fontSize: 13,
            ),
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
          key: const Key('webcam_dialog_error_close_button'),
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
            key: const Key('webcam_retake_button'),
            onPressed: _retake,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppStrings.btnRetakePhoto(lang)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            key: const Key('webcam_confirm_button'),
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
          key: const Key('webcam_dialog_cancel_button'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(AppStrings.btnCancel(lang)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          key: const Key('webcam_capture_button'),
          onPressed: (_isInitializing || _isCapturing) ? null : _captureFrame,
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

/// Robust image encoder converting raw RGB888 buffer to standard PNG or BMP bytes.
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
    final uiImage = await completer.future;
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
  } catch (_) {
    // Fall back to BMP if dart:ui PNG encoding fails
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

  // Pixels in BGR order with 4-byte row padding
  int dstOffset = 54;
  int srcOffset = 0;
  final padding = rowBytes - (width * 3);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final r = rgbBytes[srcOffset++];
      final g = rgbBytes[srcOffset++];
      final b = rgbBytes[srcOffset++];
      buffer[dstOffset++] = b;
      buffer[dstOffset++] = g;
      buffer[dstOffset++] = r;
    }
    for (int p = 0; p < padding; p++) {
      buffer[dstOffset++] = 0;
    }
  }

  return buffer;
}
