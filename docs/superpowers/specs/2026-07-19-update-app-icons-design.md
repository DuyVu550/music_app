# Design Specification: Update App Icons for Web, iOS, and Android

This document outlines the design and implementation details for updating the application icons across Web, iOS, and Android platforms using the newly generated 3D Music Note logo.

## Goals
- Replace the legacy app icon with a newly generated, modern, dynamic 3D music note icon.
- Ensure the icon is updated consistently across Android, iOS, and Web platforms.
- Leverage the `flutter_launcher_icons` tool to automate icon generation and minimize manual slicing/resizing errors.

## New Asset Details
- **Source Image**: The new logo is a dynamic 3D music note with neon pink, purple, and blue gradients on a dark background.
- **Source Path in Artifacts**: `C:\Users\Nguyen Thanh Nguyen\.gemini\antigravity-ide\brain\3f336074-6e01-45ff-80ea-b4979f2a16ab\new_logo_1784460671768.png`
- **Target Path in Project**: `assets/images/logo.png`

## Proposed Changes

### Configuration Update
Modify [pubspec.yaml](file:///d:/music_app/pubspec.yaml) to configure `flutter_launcher_icons` for Android, iOS, and Web:

```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/images/logo.png"
  min_sdk_size: 21
  web:
    generate: true
    image_path: "assets/images/logo.png"
    background_color: "#1a1a1a"
    theme_color: "#1a1a1a"
```

### Automation & Asset Generation
Run the `flutter_launcher_icons` package to generate target files automatically:
```bash
flutter pub run flutter_launcher_icons
```

This will automatically create/modify:
- **Android**:
  - `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS**:
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- **Web**:
  - `web/favicon.png`
  - `web/icons/Icon-192.png`
  - `web/icons/Icon-512.png`
  - `web/icons/Icon-maskable-192.png`
  - `web/icons/Icon-maskable-512.png`

## Verification Plan
1. **Build Verification**: Ensure `flutter pub get` and `flutter pub run flutter_launcher_icons` complete successfully.
2. **Platform Icons Verification**:
   - Verify that new files are generated under `android/app/src/main/res`, `ios/Runner/Assets.xcassets`, and `web/`.
3. **Execution Verification**: Check icon appearances on Android, iOS, and Web if simulated/built.
