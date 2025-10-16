import 'package:flutter_test/flutter_test.dart';
import 'package:audio_extractor/app.dart'; // Make sure this path is correct

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Pump the AppRoot widget
    await tester.pumpWidget(const AppRoot());

    // Verify that the title appears
    expect(find.text('YouTube Audio Downloader'), findsOneWidget);
  });
}
