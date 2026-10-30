import 'package:flutter/material.dart';

import 'core/localization/app_language.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/entrance/thulir_entrance_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartTeaApp(showEntrance: true));
}

/// The root application widget for SmartTea AIoT (Thulir - துளிர்).
/// Allows injecting custom [ImagePickerService], [PreferencesService], and entrance overrides for automated testing.
class SmartTeaApp extends StatefulWidget {
  final ImagePickerService? imagePickerService;
  final PreferencesService? preferencesService;
  final AppLanguage initialLanguage;
  final int initialTabIndex;
  final bool showEntrance;
  final bool skipEntranceDelay;

  const SmartTeaApp({
    super.key,
    this.imagePickerService,
    this.preferencesService,
    this.initialLanguage = AppLanguage.en,
    this.initialTabIndex = 0,
    this.showEntrance = false,
    this.skipEntranceDelay = false,
  });

  @override
  State<SmartTeaApp> createState() => _SmartTeaAppState();
}

class _SmartTeaAppState extends State<SmartTeaApp> {
  late final LanguageController _languageController;
  late final ImagePickerService _imagePickerService;
  late final PreferencesService _preferencesService;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController();
    if (widget.initialLanguage != AppLanguage.en) {
      _languageController.setLanguage(widget.initialLanguage);
    }
    _imagePickerService =
        widget.imagePickerService ?? DefaultImagePickerService();
    _preferencesService =
        widget.preferencesService ?? DefaultPreferencesService();
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
            title: 'Thulir • Smart Tea Farming',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: widget.showEntrance
                ? ThulirEntranceScreen(
                    preferencesService: _preferencesService,
                    imagePickerService: _imagePickerService,
                    skipEntranceDelay: widget.skipEntranceDelay,
                  )
                : MainNavigationScreen(
                    imagePickerService: _imagePickerService,
                    initialTabIndex: widget.initialTabIndex,
                  ),
          );
        },
      ),
    );
  }
}
