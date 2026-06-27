class TranslationEntry {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  TranslationEntry({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });
}

class AppState {
  final bool isListening;
  final bool isProcessing;
  final String currentTranscript;
  final String currentTranslation;
  final String targetLanguage;
  final String sourceLanguage;
  final List<TranslationEntry> history;
  final String? error;
  final bool ttsEnabled;
  final bool textDisplayEnabled;

  AppState({
    this.isListening = false,
    this.isProcessing = false,
    this.currentTranscript = '',
    this.currentTranslation = '',
    this.targetLanguage = 'es',
    this.sourceLanguage = 'auto',
    this.history = const [],
    this.error,
    this.ttsEnabled = true,
    this.textDisplayEnabled = true,
  });

  AppState copyWith({
    bool? isListening,
    bool? isProcessing,
    String? currentTranscript,
    String? currentTranslation,
    String? targetLanguage,
    String? sourceLanguage,
    List<TranslationEntry>? history,
    String? error,
    bool? ttsEnabled,
    bool? textDisplayEnabled,
  }) {
    return AppState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      currentTranslation: currentTranslation ?? this.currentTranslation,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      history: history ?? this.history,
      error: error,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      textDisplayEnabled: textDisplayEnabled ?? this.textDisplayEnabled,
    );
  }
}
