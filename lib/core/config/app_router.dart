import 'package:flutter/material.dart';

import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/event_detail_screen.dart';
import '../../presentation/screens/promoter_profile_screen.dart';
import '../../presentation/screens/payment_screen.dart';
import '../../presentation/screens/user_profile_screen.dart';
import '../../presentation/screens/event_search_screen.dart';
import '../../presentation/screens/bookmarked_events_screen.dart';
import '../../presentation/screens/user_events_screen.dart';
import '../../presentation/screens/notifications_screen.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String eventDetail = '/event-detail';
  static const String userProfile = '/user-profile';
  static const String userSettings = '/user-settings';
  static const String userEvents = '/user-events';
  static const String bookmarkedEvents = '/bookmarked-events';
  static const String subscriptions = '/subscriptions';
  static const String notifications = '/notifications';
  static const String eventRegistration = '/event-registration';
  static const String payment = '/payment';
  static const String ticketView = '/ticket-view';
  static const String promoterDashboard = '/promoter-dashboard';
  static const String eventCreation = '/event-creation';
  static const String eventManagement = '/event-management';
  static const String eventEdit = '/event-edit';
  static const String attendeeManagement = '/attendee-management';
  static const String commentManagement = '/comment-management';
  static const String analytics = '/analytics';
  static const String earningsReport = '/earnings-report';
  static const String promoterProfileEdit = '/promoter-profile-edit';
  static const String verificationUpload = '/verification-upload';
  static const String adminDashboard = '/admin-dashboard';
  static const String userManagement = '/user-management';
  static const String promoterVerification = '/promoter-verification';
  static const String eventModeration = '/event-moderation';
  static const String categoryManagement = '/category-management';
  static const String tagManagement = '/tag-management';
  static const String platformStatistics = '/platform-statistics';
  static const String systemSettings = '/system-settings';
  static const String searchResults = '/search-results';
  static const String categoryListing = '/category-listing';
  static const String promoterProfile = '/promoter-profile';
  static const String about = '/about';
  static const String contact = '/contact';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route arguments if provided
    final args = settings.arguments;

    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(
          builder:
              (_) => const Placeholder(), // Replace with ForgotPasswordScreen
        );
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case eventDetail:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: args),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventSlug: args),
          );
        } else if (args is Map<String, dynamic>) {
          final eventId = args['eventId'] as int?;
          final eventSlug = args['eventSlug'] as String?;

          if (eventId != null) {
            return MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: eventId),
            );
          } else if (eventSlug != null) {
            return MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventSlug: eventSlug),
            );
          }
        }

        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Invalid event details')),
              ),
        );

      case promoterProfile:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => PromoterProfileScreen(promoterId: args),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Invalid promoter ID')),
              ),
        );

      case payment:
        if (args is Map<String, dynamic>) {
          final event = args['event'];
          final registration = args['registration'];
          if (event != null && registration != null) {
            return MaterialPageRoute(
              builder:
                  (_) =>
                      PaymentScreen(event: event, registration: registration),
            );
          }
        }
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Invalid payment details')),
              ),
        );

      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());

      case bookmarkedEvents:
        return MaterialPageRoute(
          builder: (_) => const BookmarkedEventsScreen(),
        );

      case userEvents:
        return MaterialPageRoute(builder: (_) => const UserEventsScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case searchResults:
        final query =
            args is String
                ? args
                : args is Map<String, dynamic>
                ? args['query'] as String?
                : null;
        final categoryId =
            args is Map<String, dynamic> ? args['categoryId'] as int? : null;

        return MaterialPageRoute(
          builder:
              (_) => EventSearchScreen(
                initialQuery: query,
                categoryId: categoryId,
              ),
        );

      // Add other routes as needed

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
