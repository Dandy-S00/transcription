import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();

  bool _isInitialized = false;
  bool _isSpeaking = false;

  Function()? onComplete;
  Function(String error)? onError;

  Future<bool> initialize() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onComplete?.call();
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        _logger.e('TTS error: $message');
        onError?.call(message.toString());
      });

      _isInitialized = true;
      _logger.i('TTS initialized successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to initialize TTS: $e');
      return false;
    }
  }

  Future<void> speak(String text, {String locale = 'en-US'}) async {
    if (!_isInitialized) {
      _logger.w('TTS not initialized');
      return;
    }

    if (text.trim().isEmpty) return;

    try {
      await _flutterTts.setLanguage(locale);
      _isSpeaking = true;
      await _flutterTts.speak(text);
      _logger.d('Speaking: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
    } catch (e) {
      _isSpeaking = false;
      _logger.e('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.1, 2.0));
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
}
