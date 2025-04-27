import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';

// Import promoter screens
import 'presentation/screens/promotor/promotor_dashboard_screen.dart';
import 'presentation/screens/promotor/event_creation_screen.dart';
import 'presentation/screens/promotor/event_management_screen.dart';
import 'presentation/screens/promotor/event_edit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Reset onboarding state for testing
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(AppConstants.onboardingCompleteKey);
  final bool onboardingComplete =
      prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'Event Spot',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            onGenerateRoute:
                (settings) => AppRouter.generateRoute(
                  settings,
                  onboardingComplete: onboardingComplete,
                ),
            initialRoute: AppRouter.root,
            routes: {
              // Promoter routes
              '/promotor/dashboard':
                  (context) => const PromotorDashboardScreen(),
              '/promotor/create-event':
                  (context) => const EventCreationScreen(),
              '/promotor/manage-events':
                  (context) => const EventManagementScreen(),
              '/promotor/edit-event': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return EventEditScreen(eventId: args['eventId']);
              },
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}
