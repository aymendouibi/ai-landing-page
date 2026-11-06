import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/designsystem/colors.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final isLoggedIn = await SessionManager.isLoggedIn();

  runApp(AiBuilderApp(isLoggedIn: isLoggedIn));
}

class AiBuilderApp extends StatelessWidget {
  final bool isLoggedIn;

  const AiBuilderApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Website Builder',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? AppRoutes.dashboard : AppRoutes.auth,
      getPages: AppPages.pages,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.ink,
          secondary: AppColors.atmosphereViolet,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
      ),
    );
  }
}
