# Update App Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the app icon for Web, iOS, and Android platforms using the newly generated 3D music note logo.

**Architecture:** Copy the new logo file to the assets folder, update the `pubspec.yaml` configuration, and use `flutter_launcher_icons` to regenerate the launcher icons for all target platforms automatically.

**Tech Stack:** Flutter, flutter_launcher_icons package, powershell, git

## Global Constraints
- Target logo path: `assets/images/logo.png`
- Source logo path: `C:\Users\Nguyen Thanh Nguyen\.gemini\antigravity-ide\brain\3f336074-6e01-45ff-80ea-b4979f2a16ab\new_logo_1784460671768.png`
- Ensure all platform builds remain healthy.

---

### Task 1: Replace logo source asset

**Files:**
- Modify: `assets/images/logo.png`

**Interfaces:**
- Consumes: `C:\Users\Nguyen Thanh Nguyen\.gemini\antigravity-ide\brain\3f336074-6e01-45ff-80ea-b4979f2a16ab\new_logo_1784460671768.png`
- Produces: Updated file `assets/images/logo.png`

- [ ] **Step 1: Copy/overwrite the logo file**
  Copy the source image to `assets/images/logo.png` (overwriting the existing file).
  Command: `Copy-Item -Path "C:\Users\Nguyen Thanh Nguyen\.gemini\antigravity-ide\brain\3f336074-6e01-45ff-80ea-b4979f2a16ab\new_logo_1784460671768.png" -Destination "d:\music_app\assets\images\logo.png" -Force`

- [ ] **Step 2: Verify the asset file has been replaced**
  Check the size and metadata of the target image file.
  Command: `Get-Item "d:\music_app\assets\images\logo.png"`
  Expected: Success, file size matches the new logo (around 241,845 bytes or whatever size the generated image is).

- [ ] **Step 3: Commit the asset replacement**
  Command:
  ```bash
  git add assets/images/logo.png
  git commit -m "feat: replace logo source asset with new 3D music note"
  ```

---

### Task 2: Configure and run flutter_launcher_icons for Android, iOS, and Web

**Files:**
- Modify: `pubspec.yaml`
- Modify/Create: Android launcher icon files (`android/app/src/main/res/mipmap-*/ic_launcher.png`)
- Modify/Create: iOS launcher icon files (`ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`)
- Modify/Create: Web launcher icon files (`web/favicon.png`, `web/icons/Icon-*.png`)

**Interfaces:**
- Consumes: Updated `assets/images/logo.png`
- Produces: Updated platform launcher icons

- [ ] **Step 1: Configure pubspec.yaml for Web launcher icons**
  Edit `pubspec.yaml` to add web configurations under `flutter_launcher_icons`.
  Change:
  ```yaml
  flutter_launcher_icons:
    android: "ic_launcher"
    ios: true
    image_path: "assets/images/logo.png"
    min_sdk_size: 21
  ```
  to:
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

- [ ] **Step 2: Run flutter_launcher_icons generation**
  Run the flutter generator command.
  Command: `flutter pub run flutter_launcher_icons`
  Expected: Liveness/success message indicating launcher icons generated for Android, iOS, and Web.

- [ ] **Step 3: Verify generated files in git status**
  Check which files were modified/added.
  Command: `git status`
  Expected: Modified files under `android/app/src/main/res`, `ios/Runner/Assets.xcassets`, and `web/icons` or `web/favicon.png`.

- [ ] **Step 4: Commit all generated launcher icons**
  Command:
  ```bash
  git add pubspec.yaml android/app/src/main/res ios/Runner/Assets.xcassets web/
  git commit -m "feat: generate launcher icons for android, ios, and web using flutter_launcher_icons"
  ```
