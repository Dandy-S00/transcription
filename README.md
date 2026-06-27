# VoiceTranslate - Real-Time Accessibility Translation App

A Flutter-based accessibility app that automatically listens to spoken language in the background, detects the language being spoken, and translates it to the user's preferred language with both **audio** and **text** output options.

## Features

- **Background Listening** — Runs as an Android accessibility service, continuously listening to surrounding speech
- **Auto Language Detection** — Automatically detects the source language being spoken
- **Real-Time Translation** — Translates speech to your chosen target language on the fly
- **Dual Output** — Both text display and audio (TTS) playback of translations
- **19 Languages Supported** — English, Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean, Arabic, Hindi, Russian, Vietnamese, Thai, Turkish, Polish, Dutch, Ukrainian, Swedish
- **Translation History** — Keeps a rolling history of recent translations
- **Accessibility-First Design** — High-contrast dark theme, large text, clear visual feedback

## Architecture

```
Microphone Input
    ↓
Speech-to-Text (on-device)
    ↓
Language Detection + Translation (cloud)
    ↓
Text Display + Text-to-Speech Output
```

### Pipeline

1. **SpeechRecognitionService** — On-device speech recognition using `speech_to_text`
2. **TranslationService** — Cloud translation via Google Translate API (free tier or API key)
3. **TTSService** — Text-to-speech playback using `flutter_tts`
4. **TranslationProvider** — State management coordinating the full pipeline

## Getting Started

### Prerequisites

- Flutter 3.x+
- Android SDK 24+ (minSdk) / 34+ (targetSdk)
- An Android device or emulator

### Setup

```bash
# Clone the repo
git clone <this-repo>
cd voice_translate

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Google Translate API Key (Optional)

The app works out-of-the-box with the free Google Translate endpoint. For production use with higher quotas:

1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable the **Cloud Translation API**
3. Create an API key
4. Pass it when initializing `TranslationService(apiKey: 'YOUR_KEY')`

### Enabling the Accessibility Service

To allow background listening:

1. Go to **Android Settings → Accessibility**
2. Find **VoiceTranslate**
3. Enable the service

## Project Structure

```
lib/
├── main.dart                          # App entry point & initialization
├── models/
│   ├── language.dart                  # Supported languages definition
│   └── translation_state.dart         # App state model
├── providers/
│   └── translation_provider.dart      # State management & pipeline
├── screens/
│   ├── home_screen.dart               # Main UI with mic control
│   ├── settings_screen.dart           # App settings
│   └── history_screen.dart            # Translation history view
└── services/
    ├── speech_recognition_service.dart # On-device STT
    ├── translation_service.dart        # Cloud translation
    └── tts_service.dart                # Text-to-speech output

android/
├── app/src/main/
│   ├── AndroidManifest.xml            # Permissions & service declarations
│   ├── kotlin/.../TranslationAccessibilityService.kt
│   └── res/xml/accessibility_service_config.xml
```

## Permissions

| Permission | Purpose |
|-----------|---------|
| `RECORD_AUDIO` | Microphone access for speech recognition |
| `INTERNET` | Cloud translation API calls |
| `FOREGROUND_SERVICE` | Keep service running in background |
| `FOREGROUND_SERVICE_MICROPHONE` | Mic access in foreground service |
| `POST_NOTIFICATIONS` | Background service notification |

## License

MIT
