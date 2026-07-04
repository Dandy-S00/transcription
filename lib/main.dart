import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/translation_provider.dart';
import 'services/speech_recognition_service.dart';
import 'services/translation_service.dart';
import 'services/tts_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for accessibility
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _initError;
  TranslationProvider? _provider;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Request microphone permission
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        setState(() {
          _initError = 'Microphone permission is required for speech recognition';
        });
        return;
      }

      // Initialize services
      final speechService = SpeechRecognitionService();
      final translationService = TranslationService();
      final ttsService = TTSService();

      final speechReady = await speechService.initialize();
      if (!speechReady) {
        setState(() {
          _initError = 'Speech recognition is not available on this device';
        });
        return;
      }

      await ttsService.initialize();

      setState(() {
        _provider = TranslationProvider(
          speechService: speechService,
          translationService: translationService,
          ttsService: ttsService,
        );
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = 'Failed to initialize: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE94560),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _initError!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initError = null;
                      });
                      _initializeServices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                ),
                SizedBox(height: 24),
                Text(
                  'Initializing VoiceTranslate...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Provider wraps MaterialApp so all routes (History, Settings)
    // pushed via Navigator.push can access TranslationProvider
    return ChangeNotifierProvider.value(
      value: _provider!,
      child: MaterialApp(
        title: 'VoiceTranslate',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFE94560),
        secondary: const Color(0xFF0F3460),
        surface: const Color(0xFF1A1A2E),
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
}
