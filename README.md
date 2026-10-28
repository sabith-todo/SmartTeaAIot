# SmartTeaAIoT — Smart Tea Farming Assistant

A Flutter-based smart tea farming assistant designed to help tea farmers capture leaf images, analyze plant health, and access farming guidance. The project aims to support both Android and Linux desktop platforms, with Tamil and English language support.

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Camera Support](#camera-support)
- [Testing and Code Quality](#testing-and-code-quality)
- [Development Roadmap](#development-roadmap)
- [Important Notes](#important-notes)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

SmartTeaAIoT is a cross-platform application focused on making technology-assisted tea farming more accessible.

The long-term goal is to combine image processing, machine learning, localized agricultural information, and multilingual interaction in a single application.

The application is being developed using Flutter and Dart, with platform-specific functionality for Android and Linux.

**Project status:** Under active development. Camera functionality and Android device testing are being integrated and verified. Machine learning analysis and agricultural recommendation features require further implementation and validation.

## Objectives

- Help users capture tea leaf images for analysis.
- Develop an AI-based approach for identifying tea leaf diseases.
- Provide understandable farming guidance based on reliable agricultural sources.
- Support Tamil and English interfaces.
- Support Android smartphones and Linux desktop computers.
- Improve accessibility for tea farmers, including users with limited technical experience.
- Explore offline functionality for areas with unreliable internet connectivity.

## Features

### Current development

- Flutter-based cross-platform application.
- Android and Linux desktop project targets.
- Camera capture workflow for leaf images.
- Linux webcam integration using `flutter_lite_camera`.
- Android image capture using `image_picker`.
- Camera preview, capture, retake, and confirmation workflow.
- Linux camera device discovery and selection when multiple devices are available.
- Tamil and English localization infrastructure.

These features are part of the current development work; successful builds and actual-device behavior should be verified before considering them production-ready.

### Planned features

- Tea leaf disease classification using a trained machine learning model.
- Image quality assessment to detect blurry, dark, overexposed, or unsuitable images.
- Clear explanations of analysis results and confidence levels.
- Agricultural recommendations backed by trustworthy sources.
- Tamil and English voice input and output.
- Offline access to selected features and information.
- A research or information portal for tea cultivation.

## Technology Stack

| Component | Technology |
|---|---|
| Application framework | Flutter |
| Programming language | Dart |
| Android platform | Android SDK and Gradle |
| Linux desktop platform | Flutter Linux desktop |
| Linux camera | `flutter_lite_camera` |
| Android image capture | `image_picker` |
| User interface | Flutter widgets |
| Localization | Application localization resources |
| Testing | Flutter test framework |
| Development environment | Fedora Linux, Android Studio, and Antigravity IDE |

Exact dependency versions are maintained in `pubspec.yaml` and should be checked there rather than assumed from this document.

## Project Structure

The following is a guide to important application directories and files. The precise structure may evolve during development.

```text
SmartTeaAIoT/
├── android/                       # Android platform configuration
├── linux/                         # Linux desktop configuration
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── image_picker_service.dart
│   │   │   ├── linux_camera_adapter.dart
│   │   │   └── linux_webcam_dialog.dart
│   │   └── localization/
│   │       └── app_strings.dart
│   ├── screens/
│   │   └── analysis/
│   │       └── leaf_analysis_screen.dart
│   └── main.dart
├── test/
│   ├── image_analysis_test.dart
│   ├── linux_webcam_test.dart
│   └── widget_test.dart
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

Some files or directories may differ in the current checkout. Use the actual repository contents as the source of truth.

## System Requirements

### Development machine

- Fedora Linux or another supported Flutter development operating system.
- Flutter SDK compatible with the project.
- Dart SDK provided by Flutter.
- Git.
- An IDE or code editor.
- Internet access for downloading dependencies and Android build components.

### Android development

- Android SDK.
- Android SDK Platform-Tools, including ADB.
- Android SDK Build-Tools.
- Android SDK Command-line Tools.
- The Android NDK version required by the installed Flutter SDK and project plugins.
- A compatible Android phone with USB debugging enabled, or an Android emulator.

### Linux desktop development

- Flutter Linux desktop support.
- A C/C++ toolchain and the Linux development libraries required by Flutter.
- A supported graphical desktop environment.
- Webcam permissions and access to the appropriate video devices when using a camera.

## Installation

### 1. Clone the repository

Replace the example URL with the actual repository URL if the project is hosted remotely.

```bash
git clone <YOUR_REPOSITORY_URL>
cd SmartTeaAIoT
```

Alternatively, open the existing project directory directly.

### 2. Verify Flutter

```bash
flutter --version
flutter doctor -v
```

Resolve any errors relevant to the platform you intend to build.

### 3. Install Flutter dependencies

From the project root:

```bash
flutter pub get
```

### 4. Configure Android SDK

If Android Studio is installed and the SDK is located at `~/Android/Sdk`, configure Flutter:

```bash
flutter config --android-sdk "$HOME/Android/Sdk"
```

Check the installation:

```bash
flutter doctor -v
flutter doctor --android-licenses
```

If the SDK command-line tools are already configured and the licenses have been accepted, there is no need to repeat this step.

### 5. Enable Linux desktop support

```bash
flutter config --enable-linux-desktop
flutter devices
```

Check that Linux appears among the available Flutter targets.

## Running the Application

Run these commands from the project root.

### Linux desktop

```bash
flutter run -d linux
```

To build a debug desktop application:

```bash
flutter build linux --debug
```

### Android smartphone

Connect an Android device with USB debugging enabled.

Check device detection:

```bash
adb devices
flutter devices
```

Then run:

```bash
flutter run
```

If multiple devices are connected, specify the desired device ID:

```bash
flutter run -d <DEVICE_ID>
```

### Build an Android APK

```bash
flutter build apk --debug
```

For a release APK:

```bash
flutter build apk --release
```

Release builds should be tested before distribution. Signing and release configuration may be required for publishing.

## Camera Support

### Android

Android image capture uses the `image_picker` package. The application requests the rear camera for leaf photography.

Actual camera behavior depends on the device, Android permissions, and package implementation.

### Linux

Linux webcam capture uses `flutter_lite_camera` with a platform-specific camera adapter and capture dialog.

The intended workflow is:

1. Discover available camera devices.
2. Select a camera when multiple devices are available.
3. Open the selected camera and start its preview.
4. Capture an image.
5. Retake or confirm the image.
6. Release camera resources when finished.

Linux device names do not reliably identify front-facing and rear-facing cameras. Camera selection should therefore not assume that a particular device index represents a specific orientation.

### Troubleshooting camera access

Check available video devices:

```bash
ls -l /dev/video*
```

Inspect relevant system messages:

```bash
journalctl -k -b --no-pager | grep -Ei 'camera|uvc|video'
```

If a webcam is unavailable, check whether another application is using it, whether the device is detected, and whether the current user has the required permissions.

Camera behavior should be verified independently on Linux and Android.

## Testing and Code Quality

Run the automated tests:

```bash
flutter test
```

Analyze the Dart code:

```bash
flutter analyze
```

Check patch formatting and whitespace before committing:

```bash
git diff --check
```

Build the Linux desktop application:

```bash
flutter build linux --debug
```

Build the Android application:

```bash
flutter build apk --debug
```

A successful automated test run does not replace testing on a physical Android device or a Linux computer with an actual webcam.

## Development Roadmap

### Phase 1 — Cross-platform foundation

- [x] Establish the Flutter project.
- [x] Configure Android and Linux platform targets.
- [ ] Verify the current project builds on both platforms.
- [ ] Verify camera capture on a physical Android device and Linux webcam.

### Phase 2 — Image quality assessment

Implement checks for:

- Blur and image sharpness.
- Poor lighting and overexposure.
- Insufficient image resolution.
- Whether a usable leaf image is present, where technically feasible.

Provide clear feedback such as *Good image*, *Retake recommended*, or *Image unsuitable for analysis*.

Initial image-quality checks may use conventional image-processing methods; they should not be presented as trained AI unless a model is actually implemented.

### Phase 3 — Tea leaf disease analysis

- Identify suitable datasets and verify their licensing.
- Review image labels and class balance.
- Train and evaluate a baseline classification model.
- Consider lightweight architectures suitable for mobile devices.
- Evaluate precision, recall, F1-score, and the confusion matrix.
- Validate performance using independent field images.
- Provide an uncertainty or inconclusive-result path for unreliable predictions.

A disease prediction should not be treated as a confirmed diagnosis without adequate validation.

### Phase 4 — Agricultural guidance

- Gather information from credible tea research institutions and agricultural authorities.
- Keep recommendations relevant to the user's region and crop.
- Record sources and dates for important guidance.
- Avoid inventing pesticide dosages or treatment instructions.
- Clearly distinguish verified information from general suggestions.

### Phase 5 — Multilingual and offline support

- Improve Tamil and English localization.
- Explore speech recognition and text-to-speech.
- Add offline access to suitable models and reference material.
- Test usability under poor connectivity conditions.

## Important Notes

- The project is under development; planned features must not be considered implemented merely because they appear in this README.
- Android's first build can take considerable time while Gradle downloads dependencies and the required Android NDK.
- The Flutter SDK determines the default NDK version. For the Flutter installation used during current development, the configured version is `28.2.13676358`.
- Do not delete Gradle caches or modify Android build configuration without first identifying the actual build error.
- Do not commit API keys, credentials, signing keys, or private configuration files.
- Keep the existing legacy project separate from this repository when making changes.

## Contributing

Contributions and improvements are welcome.

A recommended workflow is:

1. Review the existing code and project conventions.
2. Make one focused change at a time.
3. Run relevant tests and static analysis.
4. Test platform-specific features on the target platform.
5. Review the changes using `git diff`.
6. Commit and push only after reviewing the changes.

## License

No license has been specified in this README. Add the project's chosen license after confirming the applicable terms for the source code, datasets, machine learning models, and third-party dependencies.
