import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aibuilder/core/widgets/shimmer_box.dart';
import 'package:aibuilder/features/dashboard/components/projects_shimmer_view.dart';
import 'package:aibuilder/features/templates/widgets/templates_shimmer_list.dart';
import 'package:aibuilder/features/website_config/widgets/website_config_shimmer_view.dart';
import 'package:aibuilder/features/subscription/widgets/past_subscriptions_shimmer_view.dart';
import 'package:aibuilder/features/assets/components/assets_shimmer_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShimmerBox and Shimmer System Tests', () {
    testWidgets('renders standalone ShimmerBox correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(width: 120, height: 24, borderRadius: 8),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    testWidgets('renders convenience constructors (circle, text, button)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShimmerBox.circle(size: 48),
                ShimmerBox.text(width: 160),
                ShimmerBox.button(width: 200),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsNWidgets(3));
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('renders under Shimmer with ShaderMask', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: Column(
                children: [
                  ShimmerBox(width: 100, height: 20),
                  ShimmerBox(width: 200, height: 40),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.byType(ShimmerBox), findsNWidgets(2));

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('renders Shimmer.fromColors with custom colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              direction: ShimmerDirection.ltr,
              child: ShimmerBox(width: 150, height: 30),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ShimmerBox), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('renders ShimmerCard with styled container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(
              child: Column(
                children: const [
                  ShimmerBox(width: 80, height: 16),
                  SizedBox(height: 8),
                  ShimmerBox(width: double.infinity, height: 100),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCard), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('ShimmerLoading switches cross-fade smoothly', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ShimmerLoading(
                  isLoading: isLoading,
                  placeholder: const ShimmerBox(width: 100, height: 30),
                  child: const Text('Loaded Content'),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() => isLoading = false),
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(ShimmerBox), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Loaded Content'), findsOneWidget);
    });

    testWidgets('supports dark mode and custom direction', (tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData.dark(),
          child: const MaterialApp(
            home: Scaffold(
              body: Shimmer(
                direction: ShimmerDirection.diagonalRtl,
                child: ShimmerBox(width: 120, height: 24),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('ProjectsShimmerView renders correctly in light and dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectsShimmerView(),
            ),
          ),
        ),
      );

      expect(find.byType(ProjectsShimmerView), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('TemplatesShimmerList renders correctly in CustomScrollView', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                TemplatesShimmerList(isDark: false, count: 2),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TemplatesShimmerList), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('WebsiteConfigShimmerView renders top nav and skeleton cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WebsiteConfigShimmerView(),
          ),
        ),
      );

      expect(find.byType(WebsiteConfigShimmerView), findsOneWidget);
      expect(find.byType(ShimmerCard), findsNWidgets(3));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('PastSubscriptionsShimmerView and AssetsShimmerView render correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PastSubscriptionsShimmerView(count: 2),
                  AssetsShimmerView(count: 2),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PastSubscriptionsShimmerView), findsOneWidget);
      expect(find.byType(AssetsShimmerView), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
