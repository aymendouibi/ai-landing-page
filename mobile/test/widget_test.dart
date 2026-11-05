import 'package:flutter_test/flutter_test.dart';
import 'package:aibuilder/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiBuilderApp(isLoggedIn: false));
    expect(find.byType(AiBuilderApp), findsOneWidget);
  });
}
