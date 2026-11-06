import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';
import 'package:aibuilder/features/editor/ask_ai_review_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ask AI Before/After Review Tests', () {
    late EditorController controller;

    setUp(() {
      Get.reset();
      controller = EditorController();
      Get.put<EditorController>(controller);

      // Seed with sample Lumen Coffee document (Crema palette)
      controller.document.value = {
        'site': {
          'name': 'Lumen Coffee',
          'theme': {
            'colors': {
              'background': '#FAF6F0',
              'primary': '#B85028',
              'surface': '#FFFFFF',
              'text': {
                'primary': '#0F172A',
                'secondary': '#78716C',
                'inverse': '#FFFFFF',
              },
            },
          },
        },
        'pages': [
          {
            'id': 'home',
            'title': 'Home',
            'sections': [
              {
                'id': 'sec_hero',
                'component': 'hero',
                'props': {
                  'headline': 'Small-batch coffee, roasted every Friday',
                  'subheadline':
                      'Single-origin beans from farms we visit, roasted in our Alberta Street shop and shipped the same day.',
                  'ctaText': 'Order beans',
                },
              }
            ],
          }
        ],
      };
      controller.selectedColorPreset.value = 'Crema';
    });

    tearDown(() {
      Get.reset();
    });

    test('submitAiPrompt snapshots original doc and creates proposed diff (Crema -> Espresso)', () async {
      await controller.submitAiPrompt('Switch to Espresso dark mode');

      expect(controller.stashedOriginalDoc.value, isNotNull);
      expect(controller.stashedAiProposedDoc.value, isNotNull);
      expect(controller.aiReviewMode.value, equals('After'));
      expect(controller.aiReviewStep.value, equals('review'));

      // Check diffs computed
      expect(controller.aiChangeDiffs.isNotEmpty, isTrue);
      final paletteDiff = controller.aiChangeDiffs.firstWhere((d) => d['type'] == 'Palette');
      expect(paletteDiff['old'], equals('Crema'));
      expect(paletteDiff['new'], equals('Espresso'));

      // Active document should now be in the proposed Espresso state
      expect(controller.selectedColorPreset.value, equals('Espresso'));
    });

    test('toggleAiReviewMode switches between Before and After seamlessly', () async {
      await controller.submitAiPrompt('Switch to Espresso');

      // Toggle to Before
      controller.toggleAiReviewMode('Before');
      expect(controller.aiReviewMode.value, equals('Before'));
      expect(controller.selectedColorPreset.value, equals('Crema'));
      expect(
        controller.document.value!['site']['theme']['colors']['background'],
        equals('#FAF6F0'),
      );

      // Toggle back to After
      controller.toggleAiReviewMode('After');
      expect(controller.aiReviewMode.value, equals('After'));
      expect(controller.selectedColorPreset.value, equals('Espresso'));
      expect(
        controller.document.value!['site']['theme']['colors']['background'],
        equals('#1C1917'),
      );
    });

    test('discardAiProposal erases AI changes and restores the old version', () async {
      final originalBg = controller.document.value!['site']['theme']['colors']['background'];

      await controller.submitAiPrompt('Switch to Espresso');
      expect(controller.selectedColorPreset.value, equals('Espresso'));

      // User chooses to discard (keep old version)
      controller.discardAiProposal();

      expect(controller.selectedColorPreset.value, equals('Crema'));
      expect(
        controller.document.value!['site']['theme']['colors']['background'],
        equals(originalBg),
      );
      expect(controller.stashedAiProposedDoc.value, isNull);
      expect(controller.stashedOriginalDoc.value, isNull);
      expect(controller.isAiReviewActive.value, isFalse);
    });

    test('applyAiProposal commits proposed AI changes and updates undo history', () async {
      await controller.submitAiPrompt('Switch to Espresso');
      final proposedBg = controller.document.value!['site']['theme']['colors']['background'];

      // User chooses to apply change (keeps new version)
      controller.applyAiProposal();

      expect(controller.selectedColorPreset.value, equals('Espresso'));
      expect(
        controller.document.value!['site']['theme']['colors']['background'],
        equals(proposedBg),
      );
      expect(controller.undoStack.isNotEmpty, isTrue);
      expect(controller.stashedAiProposedDoc.value, isNull);
      expect(controller.stashedOriginalDoc.value, isNull);
    });

    test('tryAnotherAiVersion cycles through variations and updates diffs', () async {
      await controller.submitAiPrompt('Switch palette');
      expect(controller.aiVariationIndex.value, equals(0));

      controller.tryAnotherAiVersion();
      expect(controller.aiVariationIndex.value, equals(1));
      expect(controller.selectedColorPreset.value, equals('Matcha'));

      controller.tryAnotherAiVersion();
      expect(controller.aiVariationIndex.value, equals(2));
      expect(controller.selectedColorPreset.value, equals('Riviera'));
    });

    testWidgets('AskAiReviewSheet renders Before/After toggle, diffs, Discard, and Apply buttons',
        (tester) async {
      await controller.submitAiPrompt('Switch to Espresso');

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AskAiReviewSheet(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements matching Image 4
      expect(find.text('Ask AI'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Before'), findsOneWidget);
      expect(find.text('After'), findsOneWidget);
      expect(find.text('Changes'), findsOneWidget);
      expect(find.text('Palette'), findsOneWidget);
      expect(find.textContaining('Crema'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Espresso'), findsAtLeastNWidgets(1));
      expect(find.text('Try another version'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Apply change'), findsOneWidget);

      // Tap 'Before' toggle
      await tester.tap(find.text('Before'));
      await tester.pumpAndSettle();
      expect(controller.aiReviewMode.value, equals('Before'));

      // Tap 'Discard' button
      await tester.tap(find.text('Discard'));
      await tester.pump(const Duration(seconds: 4));
      expect(controller.selectedColorPreset.value, equals('Crema'));
    });
  });
}
