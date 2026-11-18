import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aibuilder/features/editor/editor_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('EditorController orientation toggle updates state correctly', () {
    final controller = EditorController();
    expect(controller.isLandscape.value, false);

    controller.toggleLandscape();
    expect(controller.isLandscape.value, true);

    controller.toggleLandscape();
    expect(controller.isLandscape.value, false);

    controller.setLandscape();
    expect(controller.isLandscape.value, true);

    controller.setPortrait();
    expect(controller.isLandscape.value, false);
  });

  test('EditorController viewport switching works across modes', () {
    final controller = EditorController();
    expect(controller.viewport.value, ViewportMode.mobile);

    controller.setViewport(ViewportMode.desktop);
    expect(controller.viewport.value, ViewportMode.desktop);

    controller.setViewport(ViewportMode.tablet);
    expect(controller.viewport.value, ViewportMode.tablet);

    controller.setViewport(ViewportMode.mobile);
    expect(controller.viewport.value, ViewportMode.mobile);
  });

  test('EditorController bottom panel tab selection works', () {
    final controller = EditorController();
    expect(controller.selectedTab.value, 0); // Add
    expect(controller.isPanelOpen.value, false);

    controller.openTab(1); // Edit
    expect(controller.selectedTab.value, 1);
    expect(controller.isPanelOpen.value, true);

    controller.openTab(2); // Layers
    expect(controller.selectedTab.value, 2);
    expect(controller.isPanelOpen.value, true);

    controller.openTab(3); // Design
    expect(controller.selectedTab.value, 3);
    expect(controller.isPanelOpen.value, true);

    controller.closePanel();
    expect(controller.isPanelOpen.value, false);
  });

  test('EditorController font and color presets selection and updates work', () {
    final controller = EditorController();
    Get.put<EditorController>(controller);
    controller.onInit();
    expect(controller.fontPresets.length, greaterThanOrEqualTo(6));
    expect(controller.colorPresets.length, greaterThanOrEqualTo(6));

    // Select a font preset
    final sansPreset = controller.fontPresets.firstWhere((p) => p.name == 'Sans');
    controller.selectFontPreset(sansPreset);
    expect(controller.selectedFontPreset.value, 'Sans');
    expect(
      controller.document.value?['site']?['theme']?['typography']?['headingFamily'],
      'Inter',
    );

    // Select another font preset
    final cinzelPreset = controller.fontPresets.firstWhere((p) => p.name == 'Editorial');
    controller.selectFontPreset(cinzelPreset);
    expect(controller.selectedFontPreset.value, 'Editorial');
    expect(
      controller.document.value?['site']?['theme']?['typography']?['headingFamily'],
      'Cinzel',
    );

    // Select a color preset
    final espressoPreset = controller.colorPresets.firstWhere((p) => p.name == 'Espresso');
    controller.selectColorPreset(espressoPreset);
    expect(controller.selectedColorPreset.value, 'Espresso');
    expect(
      controller.document.value?['site']?['theme']?['colors']?['primary'],
      '#D97706',
    );
  });

  test('EditorController updateWebsiteTitle and liveSiteUrl work correctly', () async {
    final controller = EditorController();
    Get.put<EditorController>(controller);
    controller.onInit();

    controller.websiteSubdomain = 'my-cool-bakery';
    expect(
      controller.liveSiteUrl,
      'https://www.ai-landing-page.xyz/sites/my-cool-bakery',
    );

    await controller.updateWebsiteTitle('Awesome Artisan Bakery');
    expect(controller.websiteName.value, 'Awesome Artisan Bakery');
    expect(
      controller.document.value?['navigation']?['logo']?['text'],
      'Awesome Artisan Bakery',
    );
    expect(
      controller.document.value?['site']?['name'],
      'Awesome Artisan Bakery',
    );
  });

  test('EditorController section alignment and size changes update state', () {
    final controller = EditorController();
    Get.put<EditorController>(controller);
    controller.onInit();

    controller.selectSection('sec-hero-1');
    expect(controller.selectedSectionId.value, 'sec-hero-1');

    // Update alignment to center
    controller.updateSectionStyle('textAlign', 'center');
    expect(controller.selectedSectionAlign.value, 'center');

    // Update section padding to spacious (L)
    controller.updateSectionStyle('padding', 'spacious');
    expect(controller.selectedSectionPadding.value, 'spacious');

    // Verify document contains updated styles
    final pages = controller.document.value?['pages'] as List?;
    final sections = pages?[0]['sections'] as List?;
    final hero = sections?.firstWhere((s) => s['id'] == 'sec-hero-1', orElse: () => null);
    expect(hero?['styles']?['textAlign'], 'center');
    expect(hero?['styles']?['padding'], 'spacious');
  });
}
