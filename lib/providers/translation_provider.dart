import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_state.dart';
import '../models/language.dart';
import '../services/speech_recognition_service.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';

class TranslationProvider extends ChangeNotifier {
  final SpeechRecognitionService _speechService;
  final TranslationService _translationService;
  final TTSService _ttsService;

  AppState _state = AppState();
  Timer? _debounceTimer;
  String _pendingText = '';

  AppState get state => _state;

  TranslationProvider({
    required SpeechRecognitionService speechService,
    required TranslationService translationService,
    required TTSService ttsService,
  })  : _speechService = speechService,
        _translationService = translationService,
        _ttsService = ttsService {
    _setupCallbacks();
    _loadPreferences();
  }

  void _setupCallbacks() {
    _speechService.onResult = _onSpeechResult;
    _speechService.onError = _onSpeechError;
    _ttsService.onComplete = _onTTSComplete;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _state = _state.copyWith(
      targetLanguage: prefs.getString('targetLanguage') ?? 'es',
      ttsEnabled: prefs.getBool('ttsEnabled') ?? true,
      textDisplayEnabled: prefs.getBool('textDisplayEnabled') ?? true,
    );
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetLanguage', _state.targetLanguage);
    await prefs.setBool('ttsEnabled', _state.ttsEnabled);
    await prefs.setBool('textDisplayEnabled', _state.textDisplayEnabled);
  }

  Future<void> toggleListening() async {
    if (_state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    _state = _state.copyWith(isListening: true, error: null);
    notifyListeners();

    await _speechService.startListening();
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _state = _state.copyWith(isListening: false);
    notifyListeners();
  }

  void _onSpeechResult(String text, bool isFinal) {
    _state = _state.copyWith(currentTranscript: text);
    notifyListeners();

    if (isFinal && text.isNotEmpty) {
      _processTranslation(text);
    } else if (!isFinal) {
      _debounceTranslation(text);
    }
  }

  void _debounceTranslation(String text) {
    _pendingText = text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_pendingText.isNotEmpty) {
        _processTranslation(_pendingText);
      }
    });
  }

  Future<void> _processTranslation(String text) async {
    _state = _state.copyWith(isProcessing: true);
    notifyListeners();

    try {
      final result = await _translationService.translate(
        text: text,
        targetLanguage: _state.targetLanguage,
        sourceLanguage: 'auto',
      );

      _state = _state.copyWith(
        currentTranslation: result.translatedText,
        detectedSourceLanguage: result.detectedSourceLanguage,
        isProcessing: false,
      );

      // Add to history
      final entry = TranslationEntry(
        originalText: text,
        translatedText: result.translatedText,
        sourceLanguage: result.detectedSourceLanguage,
        targetLanguage: _state.targetLanguage,
        timestamp: DateTime.now(),
      );
      final updatedHistory = [entry, ..._state.history];
      _state = _state.copyWith(
        history: updatedHistory.length > 50
            ? updatedHistory.sublist(0, 50)
            : updatedHistory,
      );
      notifyListeners();

      // Speak the translation if TTS is enabled
      if (_state.ttsEnabled && result.translatedText.isNotEmpty) {
        final targetLang = SupportedLanguages.getByCode(_state.targetLanguage);
        await _ttsService.speak(result.translatedText, locale: targetLang.ttsLocale);
      }

      // Restart listening after processing
      if (_state.isListening && !_speechService.isListening) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_state.isListening) {
          await _speechService.startListening();
        }
      }
    } catch (e) {
      _state = _state.copyWith(
        isProcessing: false,
        error: 'Translation failed: $e',
      );
      notifyListeners();
    }
  }

  void _onSpeechError(String error) {
    if (error == 'error_no_match' || error == 'error_speech_timeout') {
      // Restart listening on timeout
      if (_state.isListening) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_state.isListening) {
            _speechService.startListening();
          }
        });
      }
    } else {
      _state = _state.copyWith(error: 'Speech error: $error');
      notifyListeners();
    }
  }

  void _onTTSComplete() {
    // TTS finished speaking
  }

  void setTargetLanguage(String languageCode) {
    _state = _state.copyWith(targetLanguage: languageCode);
    notifyListeners();
    _savePreferences();
  }

  void setTTSEnabled(bool enabled) {
    _state = _state.copyWith(ttsEnabled: enabled);
    notifyListeners();
    _savePreferences();
  }

  void setTextDisplayEnabled(bool enabled) {
    _state = _state.copyWith(textDisplayEnabled: enabled);
    notifyListeners();
    _savePreferences();
  }

  void clearHistory() {
    _state = _state.copyWith(history: []);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }
}
