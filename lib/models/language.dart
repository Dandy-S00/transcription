class Language {
  final String code;
  final String name;
  final String nativeName;
  final String ttsLocale;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.ttsLocale,
  });
}

class SupportedLanguages {
  static const List<Language> all = [
    Language(code: 'en', name: 'English', nativeName: 'English', ttsLocale: 'en-US'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español', ttsLocale: 'es-ES'),
    Language(code: 'fr', name: 'French', nativeName: 'Français', ttsLocale: 'fr-FR'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch', ttsLocale: 'de-DE'),
    Language(code: 'it', name: 'Italian', nativeName: 'Italiano', ttsLocale: 'it-IT'),
    Language(code: 'pt', name: 'Portuguese', nativeName: 'Português', ttsLocale: 'pt-BR'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文', ttsLocale: 'zh-CN'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語', ttsLocale: 'ja-JP'),
    Language(code: 'ko', name: 'Korean', nativeName: '한국어', ttsLocale: 'ko-KR'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية', ttsLocale: 'ar-SA'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', ttsLocale: 'hi-IN'),
    Language(code: 'ru', name: 'Russian', nativeName: 'Русский', ttsLocale: 'ru-RU'),
    Language(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', ttsLocale: 'vi-VN'),
    Language(code: 'th', name: 'Thai', nativeName: 'ไทย', ttsLocale: 'th-TH'),
    Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', ttsLocale: 'tr-TR'),
    Language(code: 'pl', name: 'Polish', nativeName: 'Polski', ttsLocale: 'pl-PL'),
    Language(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', ttsLocale: 'nl-NL'),
    Language(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', ttsLocale: 'uk-UA'),
    Language(code: 'sv', name: 'Swedish', nativeName: 'Svenska', ttsLocale: 'sv-SE'),
  ];

  static Language getByCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => all.first,
    );
  }
}
