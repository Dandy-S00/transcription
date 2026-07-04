import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../models/language.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Output preferences
              _buildSectionHeader('Output Preferences'),
              _buildSettingCard(
                icon: Icons.volume_up,
                title: 'Audio Output (TTS)',
                subtitle: 'Read translations aloud',
                trailing: Switch(
                  value: state.ttsEnabled,
                  onChanged: provider.setTTSEnabled,
                  activeThumbColor: const Color(0xFFE94560),
                ),
              ),
              _buildSettingCard(
                icon: Icons.text_fields,
                title: 'Text Display',
                subtitle: 'Show translation text on screen',
                trailing: Switch(
                  value: state.textDisplayEnabled,
                  onChanged: provider.setTextDisplayEnabled,
                  activeThumbColor: const Color(0xFFE94560),
                ),
              ),

              const SizedBox(height: 24),

              // Language settings
              _buildSectionHeader('Language'),
              _buildSettingCard(
                icon: Icons.translate,
                title: 'Target Language',
                subtitle: SupportedLanguages.getByCode(state.targetLanguage).name,
                onTap: () => _showLanguageSelector(context, provider),
              ),

              const SizedBox(height: 24),

              // About
              _buildSectionHeader('About'),
              _buildSettingCard(
                icon: Icons.info_outline,
                title: 'VoiceTranslate',
                subtitle: 'v1.0.0 - Real-time accessibility translation',
              ),
              _buildSettingCard(
                icon: Icons.accessibility_new,
                title: 'Accessibility Service',
                subtitle: 'Enable in Android Settings > Accessibility',
                onTap: () => _showAccessibilityInfo(context),
              ),

              const SizedBox(height: 24),

              // Data
              _buildSectionHeader('Data'),
              _buildSettingCard(
                icon: Icons.delete_outline,
                title: 'Clear Translation History',
                subtitle: '${state.history.length} translations stored',
                onTap: () => _confirmClearHistory(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE94560),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF0F3460),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38)),
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Colors.white38)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, TranslationProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
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
                        '${lang.name} (${lang.nativeName})',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFE94560)
                              : Colors.white,
                        ),
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

  void _showAccessibilityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Accessibility Service',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'To use VoiceTranslate in the background:\n\n'
          '1. Go to Android Settings\n'
          '2. Navigate to Accessibility\n'
          '3. Find "VoiceTranslate"\n'
          '4. Enable the service\n\n'
          'This allows the app to listen and translate even when other apps are in the foreground.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, TranslationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Clear History',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all translation history?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
    );
  }
}
