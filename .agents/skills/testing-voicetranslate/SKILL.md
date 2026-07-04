---
name: testing-voicetranslate
description: Test the VoiceTranslate Flutter app end-to-end on Android emulator. Use when verifying UI, navigation, state management, or speech/translation pipeline changes.
---

# Testing VoiceTranslate App

## Environment Setup

### Prerequisites
- Flutter SDK (3.44+)
- Android SDK with API 34 system image (`system-images;android-34;google_apis;x86_64`)
- Java 17 (OpenJDK)
- Android emulator AVD (Pixel 6 recommended)

### Start Emulator
```bash
export PATH="/home/ubuntu/flutter/bin:/home/ubuntu/Android/Sdk/cmdline-tools/latest/bin:/home/ubuntu/Android/Sdk/platform-tools:/home/ubuntu/Android/Sdk/emulator:$PATH"
export ANDROID_HOME=/home/ubuntu/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Start headless emulator (use -no-window for CI, remove for visual testing)
emulator -avd test_device -no-audio -no-window -gpu swiftshader_indirect -no-boot-anim &disown

# Wait for boot
adb wait-for-device
adb shell getprop sys.boot_completed  # should return "1"
```

### Build & Install
```bash
cd /home/ubuntu/repos/voice_translate
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk

# Pre-grant microphone permission (avoids permission dialog)
adb shell pm grant com.voicetranslate.voice_translate android.permission.RECORD_AUDIO
```

### Launch App
```bash
adb shell am start -n com.voicetranslate.voice_translate/.MainActivity
```

## Testing Approach

### Key Coordinates (1080x2400 display)
Use `adb shell uiautomator dump` to get exact coordinates, but typical positions:
- History icon: center ~(891, 202)
- Settings icon: center ~(1017, 202)
- Mic button: center ~(540, 2200)
- TTS toggle in Settings: center ~(896, 485)
- Text Display toggle in Settings: center ~(896, 695)

### Screenshots
```bash
adb exec-out screencap -p > /path/to/screenshot.png
```

### Navigation
```bash
# Tap a button
adb shell input tap <x> <y>

# Press Android back button
adb shell input keyevent KEYCODE_BACK
```

## Critical Tests

### 1. Provider Scoping (Navigation)
The most critical test: verify that navigating to Settings and History screens doesn't crash. These screens use `Consumer<TranslationProvider>` and will throw `ProviderNotFoundException` if the Provider isn't accessible.

**What to verify:**
- Tap Settings icon → "Settings" title renders, toggles visible
- Tap History icon → "Translation History" title renders, empty state shown
- No red error screen appears

### 2. Mic Toggle State
- Tap mic button → Status changes from "Ready" to "Listening..."
- Mic button changes from blue circle to red stop button
- Green mic indicator appears in Android status bar
- Tap stop → Returns to "Ready" state

### 3. Settings Toggles
- Navigate to Settings
- Toggle Audio Output (TTS) → Switch should change from ON to OFF visually
- Toggle Text Display → Same
- Navigate back → Home screen should reflect new toggle states

## Known Limitations

- **Speech recognition** won't produce transcription in emulator (no real mic). The app enters listening mode but receives no audio.
- **Translation API** can't be tested end-to-end without speech input. Requires real device or mocked audio.
- **TTS playback** can't be audibly verified in headless emulator.
- For full pipeline testing, use a real Android device with the debug APK.

## Devin Secrets Needed
- None required for basic testing
- Optional: `GOOGLE_TRANSLATE_API_KEY` for testing the paid API path (free endpoint works without key)

## Troubleshooting

- If app shows "Speech recognition is not available" error: The emulator might not support speech recognition. This is expected in some emulator configurations - the app handles it gracefully with an error screen and Retry button.
- If taps don't register: Use `adb shell uiautomator dump` to get exact element bounds, then tap the center of the target element's bounds.
- If emulator is "offline": Wait for `adb wait-for-device` and check `sys.boot_completed`.
