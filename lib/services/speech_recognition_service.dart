import 'package:speech_to_text/speech_to_text.dart';
import 'package:logger/logger.dart';

class SpeechRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  final Logger _logger = Logger();

  bool _isInitialized = false;

  Function(String text, bool isFinal)? onResult;
  Function(String error)? onError;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          _logger.e('Speech recognition error: ${error.errorMsg}');
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          _logger.d('Speech recognition status: $status');
        },
      );

      if (!_isInitialized) {
        _logger.w('Speech recognition not available on this device');
      } else {
        _logger.i('Speech recognition initialized successfully');
      }
      return _isInitialized;
    } catch (e) {
      _logger.e('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  Future<void> startListening({String localeId = 'en_US'}) async {
    if (!_isInitialized) {
      _logger.w('Speech recognition not initialized');
      return;
    }

    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          onResult?.call(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          localeId: localeId,
        ),
      );
      _logger.i('Started listening with locale: $localeId');
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      _logger.i('Stopped listening');
    }
  }

  bool get isListening => _speechToText.isListening;
  bool get isInitialized => _isInitialized;

  Future<List<dynamic>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    return await _speechToText.locales();
  }
}
