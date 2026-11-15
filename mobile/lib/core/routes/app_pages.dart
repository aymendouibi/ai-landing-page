import 'package:get/get.dart';
import '../../features/ai_creation/ai_creation_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/editor/editor_screen.dart';
import '../../features/templates/templates_screen.dart';
import '../../features/assets/assets_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/subscription/past_subscriptions_view.dart';
import '../../features/subscription/subscription_view.dart';
import '../../features/website_config/website_config_screen.dart';
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
    GetPage(
      name: AppRoutes.assets,
      page: () => const AssetsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.websiteConfig,
      page: () => const WebsiteConfigScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pastSubscriptions,
      page: () => const PastSubscriptionsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.billingHistory,
      page: () => const PastSubscriptionsView(),
      transition: Transition.rightToLeft,
    ),
  ];
}

