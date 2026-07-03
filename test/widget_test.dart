import 'package:flutter_test/flutter_test.dart';
import 'package:voice_translate/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const AppInitializer());
    expect(find.text('Initializing VoiceTranslate...'), findsOneWidget);
  });
}
