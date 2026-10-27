import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/theme/app_theme.dart';

class LeafAnalysisScreen extends StatefulWidget {
  final ImagePickerService imagePickerService;
  final VoidCallback? onNavigateToKnowledge;

  const LeafAnalysisScreen({
    super.key,
    required this.imagePickerService,
    this.onNavigateToKnowledge,
  });

  @override
  State<LeafAnalysisScreen> createState() => _LeafAnalysisScreenState();
}

class _LeafAnalysisScreenState extends State<LeafAnalysisScreen> {
  PickedLeafImage? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickFromCamera() async {
    if (!widget.imagePickerService.isCameraSupported) {
      _showCameraUnavailableNotice();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final image = await widget.imagePickerService.pickFromCamera(context);
      _handlePickerResult(image);
    } on ImagePickerException catch (e) {
      _handlePickerError(e.message);
    } catch (e) {
      _handlePickerError(e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final image = await widget.imagePickerService.pickFromGallery();
      _handlePickerResult(image);
    } on ImagePickerException catch (e) {
      _handlePickerError(e.message);
    } catch (e) {
      _handlePickerError(e.toString());
    }
  }

  void _handlePickerError(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: AppTheme.alertRed,
      ),
    );
  }

  void _showCameraUnavailableNotice() {
    final lang = LanguageProvider.of(context).currentLanguage;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.cameraUnavailableMsg(lang)),
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.warningAmber,
      ),
    );
  }

  void _handlePickerResult(PickedLeafImage? image) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    final lang = LanguageProvider.of(context).currentLanguage;

    if (image == null) {
      // User cancelled or dismissed the picker
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.cancelledMsg(lang)),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.textDark,
        ),
      );
      return;
    }

    setState(() {
      _selectedImage = image;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.imageSelectedBadge(lang)),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
  }

  void _removeImage() {
    final lang = LanguageProvider.of(context).currentLanguage;
    setState(() {
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.removedMsg(lang)),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.forestGreenDark,
      ),
    );
  }

  void _showModelUnavailableDialog() {
    final lang = LanguageProvider.of(context).currentLanguage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.creamLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppTheme.warningAmber,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.dialogModelUnavailableTitle(lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.dialogModelUnavailableBody(lang),
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          if (widget.onNavigateToKnowledge != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onNavigateToKnowledge!();
              },
              child: Text(
                AppStrings.dialogBtnViewKnowledge(lang),
                style: const TextStyle(
                  color: AppTheme.forestGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.dialogBtnOk(lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header description
          Text(
            AppStrings.leafAnalysisTitle(lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.leafAnalysisSubtitle(lang),
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textMuted,
            ),
          ),

          const SizedBox(height: 20),

          // MANDATORY REQUIREMENT: Prominent AI Model Offline / No Fake AI disclaimer
          _buildAiModelOfflineCard(context, lang),

          const SizedBox(height: 20),

          // Image Preview or Empty Upload Box
          if (_isLoading)
            _buildLoadingBox()
          else if (_selectedImage != null)
            _buildPreviewBox(context, lang)
          else
            _buildEmptyUploadBox(context, lang),

          const SizedBox(height: 20),

          // Primary Inspection Action Button
          ElevatedButton.icon(
            key: const Key('screen_leaf_health_button'),
            onPressed: _selectedImage == null ? null : _showModelUnavailableDialog,
            icon: const Icon(Icons.psychology_outlined),
            label: Text(AppStrings.btnAnalyze(lang)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _selectedImage == null ? AppTheme.creamDark : AppTheme.forestGreen,
              foregroundColor: _selectedImage == null ? AppTheme.textMuted : AppTheme.creamLight,
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAiModelOfflineCard(BuildContext context, AppLanguage lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.5), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningAmber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.aiModelOfflineTitle(lang),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forestGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.aiModelOfflineDisclaimer(lang),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBox() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamDark),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.forestGreen),
      ),
    );
  }

  Widget _buildEmptyUploadBox(BuildContext context, AppLanguage lang) {
    final isCameraSupported = widget.imagePickerService.isCameraSupported;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.leafGreenDark.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.leafGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.uploadPrompt(lang),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.uploadHint(lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textMuted,
            ),
          ),
          if (!isCameraSupported) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppTheme.warningAmber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.cameraUnavailableMsg(lang),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              // Stack vertically on narrow widths or with larger text
              final bool stackButtons = !isCameraSupported || constraints.maxWidth < (380 * textScale);

              final cameraBtn = Tooltip(
                message: isCameraSupported ? '' : AppStrings.cameraDisabledTooltip(lang),
                child: ElevatedButton.icon(
                  key: const Key('camera_pick_button'),
                  onPressed: isCameraSupported ? _pickFromCamera : null,
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: Text(
                    AppStrings.btnCamera(lang),
                    textAlign: TextAlign.center,
                  ),
                  style: isCameraSupported
                      ? null
                      : ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.creamDark.withValues(alpha: 0.6),
                          foregroundColor: AppTheme.textMuted,
                        ),
                ),
              );

              final galleryBtn = isCameraSupported
                  ? OutlinedButton.icon(
                      key: const Key('gallery_pick_button'),
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: Text(
                        AppStrings.btnGallery(lang),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ElevatedButton.icon(
                      key: const Key('gallery_pick_button'),
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.file_open_outlined, size: 20),
                      label: Text(
                        AppStrings.btnGallery(lang),
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        foregroundColor: AppTheme.creamLight,
                      ),
                    );

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isCameraSupported) ...[
                      galleryBtn,
                      const SizedBox(height: 10),
                      cameraBtn,
                    ] else ...[
                      cameraBtn,
                      const SizedBox(height: 10),
                      galleryBtn,
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cameraBtn),
                  const SizedBox(width: 12),
                  Expanded(child: galleryBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBox(BuildContext context, AppLanguage lang) {
    final image = _selectedImage!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image render
          Container(
            height: 260,
            color: Colors.black12,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  image.bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Center(
                    child: Icon(Icons.broken_image, size: 48, color: AppTheme.textMuted),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.leafGreen, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          image.formattedSize,
                          style: const TextStyle(
                            color: AppTheme.creamLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.image, size: 18, color: AppTheme.forestGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        image.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                    final bool stackButtons = constraints.maxWidth < (360 * textScale);

                    final removeBtn = OutlinedButton.icon(
                      key: const Key('remove_image_button'),
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.alertRed, size: 18),
                      label: Text(
                        AppStrings.btnRemoveImage(lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.alertRed),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.alertRed),
                      ),
                    );

                    final changeBtn = OutlinedButton.icon(
                      key: const Key('change_image_button'),
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: Text(
                        AppStrings.btnChangeImage(lang),
                        textAlign: TextAlign.center,
                      ),
                    );

                    if (stackButtons) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          changeBtn,
                          const SizedBox(height: 10),
                          removeBtn,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: removeBtn),
                        const SizedBox(width: 10),
                        Expanded(child: changeBtn),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
