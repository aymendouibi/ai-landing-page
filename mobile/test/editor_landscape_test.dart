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
}
