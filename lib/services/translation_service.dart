import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TranslationService {
  final Logger _logger = Logger();

  // Uses the free Google Translate endpoint (no API key required)
  // For production, use the official Google Cloud Translation API with a key
  static const String _freeTranslateUrl =
      'https://translate.googleapis.com/translate_a/single';

  String? _apiKey;

  TranslationService({String? apiKey}) : _apiKey = apiKey;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    if (text.trim().isEmpty) {
      return TranslationResult(
        translatedText: '',
        detectedSourceLanguage: sourceLanguage,
      );
    }

    try {
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        return await _translateWithApi(text, targetLanguage, sourceLanguage);
      } else {
        return await _translateFree(text, targetLanguage, sourceLanguage);
      }
    } catch (e) {
      _logger.e('Translation error: $e');
      rethrow;
    }
  }

  Future<TranslationResult> _translateWithApi(
    String text,
    String targetLanguage,
    String sourceLanguage,
  ) async {
    const baseUrl =
        'https://translation.googleapis.com/language/translate/v2';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'target': targetLanguage,
        'source': sourceLanguage == 'auto' ? null : sourceLanguage,
        'key': _apiKey,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translation = data['data']['translations'][0];
      return TranslationResult(
        translatedText: translation['translatedText'],
        detectedSourceLanguage:
            translation['detectedSourceLanguage'] ?? sourceLanguage,
      );
    } else {
      throw TranslationException(
        'API translation failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<TranslationResult> _translateFree(
    String text,
    String targetLanguage,
    String sourceLanguage,
  ) async {
    final uri = Uri.parse(_freeTranslateUrl).replace(queryParameters: {
      'client': 'gtx',
      'sl': sourceLanguage,
      'tl': targetLanguage,
      'dt': 't',
      'q': text,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data[0] as List;
      final translatedText =
          translations.map((t) => t[0] as String).join('');
      final detectedLang = data[2] as String? ?? sourceLanguage;

      return TranslationResult(
        translatedText: translatedText,
        detectedSourceLanguage: detectedLang,
      );
    } else {
      throw TranslationException(
        'Free translation failed: ${response.statusCode}',
      );
    }
  }
}

class TranslationResult {
  final String translatedText;
  final String detectedSourceLanguage;

  TranslationResult({
    required this.translatedText,
    required this.detectedSourceLanguage,
  });
}

class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);

  @override
  String toString() => 'TranslationException: $message';
}
