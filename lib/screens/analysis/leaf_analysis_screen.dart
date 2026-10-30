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
          // Header description matching Screen 6
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
            style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
          ),

          const SizedBox(height: 18),

          // Image Preview or Upload Box matching Screen 6
          if (_isLoading)
            _buildLoadingBox()
          else if (_selectedImage != null)
            _buildPreviewBox(context, lang)
          else
            _buildEmptyUploadBox(context, lang),

          const SizedBox(height: 18),

          // Primary Inspection Action Button (Screen 6)
          ElevatedButton.icon(
            key: const Key('screen_leaf_health_button'),
            onPressed: _showModelUnavailableDialog,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text(
              AppStrings.btnAnalyze(lang),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: AppTheme.creamLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
          ),

          const SizedBox(height: 22),

          // Recent Analysis Section matching Screen 6
          _buildRecentAnalysisSection(context, lang),

          const SizedBox(height: 18),

          // Prominent AI Model Offline disclaimer banner (Screen 6)
          _buildAiModelOfflineCard(context, lang),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAiModelOfflineCard(BuildContext context, AppLanguage lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningAmber.withValues(alpha: 0.5),
          width: 1.2,
        ),
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

    final cameraBtn = ElevatedButton.icon(
      key: const Key('camera_pick_button'),
      onPressed: isCameraSupported ? _pickFromCamera : null,
      icon: const Icon(Icons.camera_alt, size: 20),
      label: Text(
        AppStrings.btnCamera(lang),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.1),
        foregroundColor: AppTheme.forestGreen,
        disabledBackgroundColor: AppTheme.creamDark.withValues(alpha: 0.5),
        disabledForegroundColor: AppTheme.textMuted,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTheme.forestGreen.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );

    final galleryBtn = ElevatedButton.icon(
      key: const Key('gallery_pick_button'),
      onPressed: _pickFromGallery,
      icon: const Icon(Icons.photo_library_outlined, size: 20),
      label: Text(
        AppStrings.btnGallery(lang),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.forestGreen.withValues(alpha: 0.1),
        foregroundColor: AppTheme.forestGreen,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTheme.forestGreen.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamDark, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Square Leaf Sample Preview
              Expanded(
                flex: 6,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.creamDark, width: 1.2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/leaf_sample.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Center(
                            child: Icon(
                              Icons.eco,
                              size: 48,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.45),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            lang == AppLanguage.ta ? 'முன்னோட்டம்' : 'Preview',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Right: Camera & Gallery Stacked Action Buttons
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    SizedBox(width: double.infinity, child: cameraBtn),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: galleryBtn),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              AppStrings.uploadPrompt(lang),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isCameraSupported) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningAmber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.warningAmber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.cameraUnavailableMsg(lang),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.leafGreen,
                          size: 14,
                        ),
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
                    const Icon(
                      Icons.image,
                      size: 18,
                      color: AppTheme.forestGreen,
                    ),
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
                    final textScale = MediaQuery.textScalerOf(context)
                        .scale(1.0);
                    final bool stackButtons =
                        constraints.maxWidth < (360 * textScale);

                    final removeBtn = OutlinedButton.icon(
                      key: const Key('remove_image_button'),
                      onPressed: _removeImage,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.alertRed,
                        size: 18,
                      ),
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

  Widget _buildRecentAnalysisSection(BuildContext context, AppLanguage lang) {
    final recentItems = [
      (
        title: lang == AppLanguage.ta ? 'ஆரோக்கியமான இலை' : 'Healthy Leaf',
        sub: lang == AppLanguage.ta
            ? 'முக்கிய பாதிப்புகள் இல்லை'
            : 'No major issues detected',
        date: 'Oct 28, 2026',
        badge: lang == AppLanguage.ta ? 'ஆரோக்கியம்' : 'Healthy',
        badgeColor: AppTheme.secondaryLeafGreen,
      ),
      (
        title: lang == AppLanguage.ta ? 'சாத்தியமான கருகல்' : 'Possible Blight',
        sub: lang == AppLanguage.ta
            ? 'அறிகுறிகள் கண்டறியப்பட்டன'
            : 'Symptoms detected',
        date: 'Oct 28, 2026',
        badge: lang == AppLanguage.ta ? 'எச்சரிக்கை' : 'Warning',
        badgeColor: AppTheme.warningAmber,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lang == AppLanguage.ta
                    ? 'சமீபத்திய ஆய்வுகள்'
                    : 'Recent Analysis',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
            if (widget.onNavigateToKnowledge != null)
              TextButton(
                onPressed: widget.onNavigateToKnowledge,
                child: Text(
                  lang == AppLanguage.ta ? 'அனைத்தும் காண்க' : 'See All',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondaryLeafGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentItems.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: AppTheme.creamLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppTheme.creamDark, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/leaf_sample.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 44,
                        height: 44,
                        color: AppTheme.forestGreen.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.eco,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: item.badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.badgeColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      item.badge,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: item.badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
