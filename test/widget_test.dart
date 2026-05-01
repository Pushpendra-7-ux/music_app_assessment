import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BlosicalApp(),
      ),
    );

    // verify the app renders
    expect(find.byType(BlosicalApp), findsOneWidget);
  });
}
