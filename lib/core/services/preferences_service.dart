import 'dart:convert';
import 'dart:io';

/// Abstract contract for lightweight local preference storage.
abstract class PreferencesService {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
}

/// In-memory implementation of [PreferencesService] for tests and transient environments.
class InMemoryPreferencesService implements PreferencesService {
  bool _onboardingCompleted;

  InMemoryPreferencesService({bool initialOnboardingCompleted = false})
    : _onboardingCompleted = initialOnboardingCompleted;

  @override
  Future<bool> isOnboardingCompleted() async => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    _onboardingCompleted = value;
  }
}

/// File-backed persistent implementation of [PreferencesService] that requires
/// zero external dependencies and works cross-platform on Android, Linux, and tests.
class DefaultPreferencesService implements PreferencesService {
  bool? _cachedOnboardingCompleted;
  File? _resolvedFile;

  File? _getStorageFile() {
    if (_resolvedFile != null) return _resolvedFile;
    try {
      Directory baseDir;
      if (Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
        baseDir = Directory('$home/.config/smart_tea_aiot');
      } else {
        baseDir = Directory('${Directory.systemTemp.path}/smart_tea_aiot');
      }

      if (!baseDir.existsSync()) {
        baseDir.createSync(recursive: true);
      }
      _resolvedFile = File('${baseDir.path}/app_preferences.json');
      return _resolvedFile;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    if (_cachedOnboardingCompleted != null) {
      return _cachedOnboardingCompleted!;
    }
    try {
      final file = _getStorageFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        _cachedOnboardingCompleted =
            data['onboarding_completed'] as bool? ?? false;
        return _cachedOnboardingCompleted!;
      }
    } catch (_) {
      // Fallback gracefully on read errors
    }
    _cachedOnboardingCompleted = false;
    return false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    _cachedOnboardingCompleted = value;
    try {
      final file = _getStorageFile();
      if (file != null) {
        Map<String, dynamic> data = {};
        if (await file.exists()) {
          try {
            data = jsonDecode(await file.readAsString());
          } catch (_) {}
        }
        data['onboarding_completed'] = value;
        await file.writeAsString(jsonEncode(data), flush: true);
      }
    } catch (_) {
      // Fallback gracefully on write errors
    }
  }
}
