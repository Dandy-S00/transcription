import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../models/language.dart';
import '../models/translation_state.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslationProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            title: const Text(
              'VoiceTranslate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white70),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Status indicator
                _buildStatusBar(state),

                // Language selector
                _buildLanguageSelector(context, provider),

                // Translation display
                Expanded(
                  child: _buildTranslationDisplay(state),
                ),

                // Error display
                if (state.error != null) _buildErrorBanner(context, provider),

                // Control buttons
                _buildControlBar(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(AppState state) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (state.isListening && state.isProcessing) {
      statusColor = Colors.orange;
      statusText = 'Translating...';
      statusIcon = Icons.translate;
    } else if (state.isListening) {
      statusColor = Colors.green;
      statusText = 'Listening...';
      statusIcon = Icons.hearing;
    } else {
      statusColor = Colors.grey;
      statusText = 'Ready';
      statusIcon = Icons.mic_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (state.isListening) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, TranslationProvider provider) {
    final state = provider.state;
    final targetLang = SupportedLanguages.getByCode(state.targetLanguage);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Source language
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FROM',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.sourceLanguage == 'auto'
                      ? 'Auto-detect'
                      : SupportedLanguages.getByCode(state.sourceLanguage).name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(Icons.arrow_forward, color: Colors.white54),

          // Target language
          Expanded(
            child: GestureDetector(
              onTap: () => _showLanguagePicker(context, provider),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TO',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        targetLang.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationDisplay(AppState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Original text card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.white38, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Original Speech',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        state.currentTranscript.isEmpty
                            ? 'Tap the microphone button to start listening...'
                            : state.currentTranscript,
                        style: TextStyle(
                          color: state.currentTranscript.isEmpty
                              ? Colors.white24
                              : Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Translated text card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE94560).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE94560).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.translate, color: Color(0xFFE94560), size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Translation',
                        style: TextStyle(
                          color: Color(0xFFE94560),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (state.isProcessing)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE94560),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        state.currentTranslation.isEmpty
                            ? 'Translation will appear here...'
                            : state.currentTranslation,
                        style: TextStyle(
                          color: state.currentTranslation.isEmpty
                              ? Colors.white24
                              : Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, TranslationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.state.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 16),
            onPressed: provider.clearError,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, TranslationProvider provider) {
    final state = provider.state;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // TTS toggle
          IconButton(
            onPressed: () => provider.setTTSEnabled(!state.ttsEnabled),
            icon: Icon(
              state.ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: state.ttsEnabled ? Colors.white : Colors.white38,
              size: 28,
            ),
            tooltip: state.ttsEnabled ? 'Disable audio' : 'Enable audio',
          ),

          // Main mic button
          GestureDetector(
            onTap: provider.toggleListening,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.isListening
                    ? const Color(0xFFE94560)
                    : const Color(0xFF0F3460),
                boxShadow: [
                  if (state.isListening)
                    BoxShadow(
                      color: const Color(0xFFE94560).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Icon(
                state.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Text display toggle
          IconButton(
            onPressed: () =>
                provider.setTextDisplayEnabled(!state.textDisplayEnabled),
            icon: Icon(
              state.textDisplayEnabled
                  ? Icons.text_fields
                  : Icons.text_fields_outlined,
              color: state.textDisplayEnabled ? Colors.white : Colors.white38,
              size: 28,
            ),
            tooltip: state.textDisplayEnabled ? 'Hide text' : 'Show text',
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, TranslationProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Target Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: SupportedLanguages.all.length,
                  itemBuilder: (context, index) {
                    final lang = SupportedLanguages.all[index];
                    final isSelected =
                        lang.code == provider.state.targetLanguage;
                    return ListTile(
                      title: Text(
                        lang.name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFE94560) : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        lang.nativeName,
                        style: const TextStyle(color: Colors.white38),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFFE94560))
                          : null,
                      onTap: () {
                        provider.setTargetLanguage(lang.code);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
