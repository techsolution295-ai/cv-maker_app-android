import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/screens/onboarding_screen.dart';
import 'package:cv_ganerator/screens/main_shell.dart';
import 'package:cv_ganerator/screens/resume_creation_screen.dart';
import 'package:cv_ganerator/screens/template_screen.dart';
import 'package:cv_ganerator/screens/settings_screen.dart';
import 'package:cv_ganerator/screens/my_documents_screen.dart';
import 'package:cv_ganerator/screens/pro_screen.dart';
import 'package:cv_ganerator/screens/splash screen.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/billing_service.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  // Billing must be initialized first so AdService knows immediately
  // whether the user is already Pro (and should skip loading ads at all).
  await BillingService.instance.initialize();
  await AdService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdService.instance.handleAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      AdService.instance.handleAppBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/root': (context) => const MainShell(),
        '/home': (context) => const MainShell(),
        '/create-resume': (context) => const ResumeCreationScreen(),
        '/templates': (context) => const TemplateScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/my-documents': (context) => const MyDocumentsScreen(),
        '/pro': (context) => const ProScreen(),
      },
    );
  }
}
