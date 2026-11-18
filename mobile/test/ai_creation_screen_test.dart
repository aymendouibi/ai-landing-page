import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:aibuilder/core/localization/app_translations.dart';
import 'package:aibuilder/features/ai_creation/ai_creation_controller.dart';
import 'package:aibuilder/features/ai_creation/ai_creation_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en', 'US');
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('AiCreationScreen renders all sections according to design', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const AiCreationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header elements
    expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
    expect(find.text('AI LANDING PAGE'), findsOneWidget);
    expect(find.text('Your idea.\nA page in minutes.'), findsOneWidget);
    expect(
      find.text('Tell AI what you’re building. Make it yours.'),
      findsOneWidget,
    );

    // 2. Prompt card & idea chips
    expect(find.text('What would you like to create?'), findsOneWidget);
    expect(
      find.text('e.g. FocusMind, Apex Studio, Bloom Matcha...'),
      findsOneWidget,
    );
    expect(find.text('Try an idea'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Online store'), findsOneWidget);
    expect(find.text('SaaS product'), findsOneWidget);

    // 3. Style selector
    expect(find.text('Choose a style'), findsOneWidget);
    expect(find.text('Clean'), findsOneWidget);
    expect(find.text('Bold'), findsOneWidget);
    expect(find.text('Soft'), findsOneWidget);

    // 4. Make it yours
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('AI-selected sections'), findsOneWidget);
    expect(
      find.text('Hero, features, testimonials & a call to action'),
      findsOneWidget,
    );

    // 5. Generate action
    expect(find.text('Generate my Page'), findsOneWidget);
    expect(
      find.text('Uses 1 generation · You can edit everything after'),
      findsOneWidget,
    );

    // Test idea chips interactively
    await tester.tap(find.text('Portfolio'));
    await tester.pumpAndSettle();

    final controller = Get.find<AiCreationController>();
    expect(controller.promptController.text, contains('portfolio'));

    // Test style switching
    await tester.tap(find.text('Bold'));
    await tester.pumpAndSettle();
    expect(controller.selectedStyle.value, AiCreationStyle.bold);
  });
}
