import 'package:flutter/material.dart';
import 'core/localization/app_language.dart';
import 'core/services/image_picker_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartTeaApp());
}

/// The root application widget for SmartTea AIoT.
/// Allows injecting custom [ImagePickerService] and initial language for automated testing.
class SmartTeaApp extends StatefulWidget {
  final ImagePickerService? imagePickerService;
  final AppLanguage initialLanguage;
  final int initialTabIndex;

  const SmartTeaApp({
    super.key,
    this.imagePickerService,
    this.initialLanguage = AppLanguage.en,
    this.initialTabIndex = 0,
  });

  @override
  State<SmartTeaApp> createState() => _SmartTeaAppState();
}

class _SmartTeaAppState extends State<SmartTeaApp> {
  late final LanguageController _languageController;
  late final ImagePickerService _imagePickerService;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController();
    if (widget.initialLanguage != AppLanguage.en) {
      _languageController.setLanguage(widget.initialLanguage);
    }
    _imagePickerService = widget.imagePickerService ?? DefaultImagePickerService();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageProvider(
      controller: _languageController,
      child: ListenableBuilder(
        listenable: _languageController,
        builder: (context, _) {
          return MaterialApp(
            title: 'SmartTea AIoT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: MainNavigationScreen(
              imagePickerService: _imagePickerService,
              initialTabIndex: widget.initialTabIndex,
            ),
          );
        },
      ),
    );
  }
}
