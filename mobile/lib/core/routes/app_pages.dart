import 'package:get/get.dart';
import '../../features/ai_creation/ai_creation_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/editor/editor_screen.dart';
import '../../features/templates/templates_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.aiCreation,
      page: () => const AiCreationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editor,
      page: () => const EditorScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.templates,
      page: () => const TemplatesScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

