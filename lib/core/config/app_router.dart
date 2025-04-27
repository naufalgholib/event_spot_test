import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/general/login_screen.dart';
import '../../presentation/screens/general/register_screen.dart';
import '../../presentation/screens/user/home_screen.dart';
import '../../presentation/screens/user/event_detail_screen.dart';
import '../../presentation/screens/user/promoter_profile_screen.dart';
import '../../presentation/screens/user/payment_screen.dart';
import '../../presentation/screens/user/user_profile_screen.dart';
import '../../presentation/screens/user/event_search_screen.dart';
import '../../presentation/screens/user/bookmarked_events_screen.dart';
import '../../presentation/screens/user/user_events_screen.dart';
import '../../presentation/screens/user/notifications_screen.dart';
import '../../presentation/screens/general/about_faq_screen.dart';
import '../../presentation/screens/general/contact_screen.dart';
import '../../presentation/screens/general/password_recovery_screen.dart';
import '../../presentation/screens/user/user_settings_screen.dart';
import '../../presentation/screens/user/subscription_management_screen.dart';
import '../../presentation/screens/user/edit_profile_screen.dart';
import '../../presentation/screens/promotor/promotor_dashboard_screen.dart';
import '../../presentation/screens/promotor/event_creation_screen.dart';
import '../../presentation/screens/promotor/event_management_screen.dart';
import '../../presentation/screens/promotor/event_edit_screen.dart';
import '../../presentation/screens/promotor/attendee_management_screen.dart';
import '../../presentation/screens/promotor/analytics_dashboard_screen.dart';
import '../../presentation/screens/promotor/verification_document_upload_screen.dart';
import '../../presentation/screens/promotor/verification_waiting_screen.dart';
import '../../presentation/screens/promotor/promotor_profile_screen.dart';
import '../../presentation/screens/promotor/promotor_settings_screen.dart';
// Admin screen imports
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/admin/promoter_verification_screen.dart';
import '../../presentation/screens/admin/event_moderation_screen.dart';
import '../../presentation/screens/admin/category_management_screen.dart';
import '../../presentation/screens/admin/tag_management_screen.dart';
import '../../presentation/screens/admin/platform_statistics_screen.dart';
import '../../presentation/screens/admin/system_settings_screen.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String eventDetail = '/event-detail';
  static const String userProfile = '/user-profile';
  static const String userSettings = '/settings';
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
  static const String verificationWaiting = '/verification-waiting';
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
  static const String aboutFAQ = '/about-faq';
  static const String passwordRecovery = '/password-recovery';
  static const String subscriptionManagement = '/subscription-management';
  static const String editProfile = '/edit-profile';
  static const String promotorProfile = '/promotor-profile';
  static const String promotorSettings = '/promotor-settings';

  // Admin routes from AdminRoutes
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminPromoters = '/admin/promoters';
  static const String adminEvents = '/admin/events';
  static const String adminCategories = '/admin/categories';
  static const String adminTags = '/admin/tags';
  static const String adminStatistics = '/admin/statistics';
  static const String adminSettings = '/admin/settings';

  static Route<dynamic> generateRoute(
    RouteSettings settings, {
    bool? onboardingComplete,
  }) {
    // Extract route arguments if provided
    final args = settings.arguments;

    // Protected routes that require authentication
    final protectedRoutes = {
      userProfile,
      userSettings,
      userEvents,
      bookmarkedEvents,
      subscriptions,
      notifications,
      eventRegistration,
      payment,
      ticketView,
    };

    // Admin only routes
    final adminRoutes = {
      adminDashboard,
      userManagement,
      promoterVerification,
      eventModeration,
      categoryManagement,
      tagManagement,
      platformStatistics,
      systemSettings,
      admin,
      adminUsers,
      adminPromoters,
      adminEvents,
      adminCategories,
      adminTags,
      adminStatistics,
      adminSettings,
    };

    // Promoter only routes
    final promoterRoutes = {
      promoterDashboard,
      eventCreation,
      eventManagement,
      eventEdit,
      attendeeManagement,
      commentManagement,
      analytics,
      earningsReport,
      promoterProfileEdit,
    };

    return MaterialPageRoute(
      builder: (context) {
        // Check authentication for protected routes
        if (protectedRoutes.contains(settings.name)) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (!authProvider.isLoggedIn) {
            return LoginScreen();
          }
        }

        // Check admin access
        if (adminRoutes.contains(settings.name)) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (!authProvider.hasRole('admin')) {
            return Scaffold(
              body: Center(
                child: Text('Access denied. Admin privileges required.'),
              ),
            );
          }
        }

        // Check promoter access
        if (promoterRoutes.contains(settings.name)) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (!authProvider.hasRole('promotor')) {
            return Scaffold(
              body: Center(
                child: Text('Access denied. Promoter privileges required.'),
              ),
            );
          }
        }

        // Route specific logic
        switch (settings.name) {
          case root:
            return SplashScreen(
              onboardingComplete: onboardingComplete ?? false,
            );
          case login:
            return const LoginScreen();
          case register:
            return const RegisterScreen();
          case forgotPassword:
            return const PasswordRecoveryScreen();
          case onboarding:
            return const OnboardingScreen();
          case home:
            return const HomeScreen();
          case eventDetail:
            if (args is int) {
              return EventDetailScreen(eventId: args);
            } else if (args is String) {
              return EventDetailScreen(eventSlug: args);
            } else if (args is Map<String, dynamic>) {
              final eventId = args['eventId'] as int?;
              final eventSlug = args['eventSlug'] as String?;

              if (eventId != null) {
                return EventDetailScreen(eventId: eventId);
              } else if (eventSlug != null) {
                return EventDetailScreen(eventSlug: eventSlug);
              }
            }

            return const Scaffold(
              body: Center(child: Text('Invalid event details')),
            );

          case promoterProfile:
            if (args is int) {
              return PromoterProfileScreen(promoterId: args);
            }
            return const Scaffold(
              body: Center(child: Text('Invalid promoter ID')),
            );

          case payment:
            if (args is Map<String, dynamic>) {
              final event = args['event'];
              final registration = args['registration'];
              if (event != null && registration != null) {
                return PaymentScreen(event: event, registration: registration);
              }
            }
            return const Scaffold(
              body: Center(child: Text('Invalid payment details')),
            );

          case userProfile:
            return const UserProfileScreen();

          case bookmarkedEvents:
            return const BookmarkedEventsScreen();

          case userEvents:
            return const UserEventsScreen();

          case notifications:
            return const NotificationsScreen();

          case searchResults:
            final query = args is String
                ? args
                : args is Map<String, dynamic>
                    ? args['query'] as String?
                    : null;
            final categoryId = args is Map<String, dynamic>
                ? args['categoryId'] as int?
                : null;

            return EventSearchScreen(
              initialQuery: query,
              categoryId: categoryId,
            );

          case aboutFAQ:
            return const AboutFAQScreen();

          case contact:
            return const ContactScreen();

          case passwordRecovery:
            return const PasswordRecoveryScreen();

          case userSettings:
            return const UserSettingsScreen();

          case subscriptionManagement:
            return const SubscriptionManagementScreen();

          case editProfile:
            return const EditProfileScreen();

          // Promotor routes
          case promoterDashboard:
            return const PromotorDashboardScreen();

          case eventCreation:
            return const EventCreationScreen();

          case eventManagement:
            return const EventManagementScreen();

          case eventEdit:
            if (args is Map<String, dynamic> && args.containsKey('eventId')) {
              return EventEditScreen(eventId: args['eventId']);
            }
            return const Scaffold(
              body: Center(child: Text('Invalid event ID for editing')),
            );

          case attendeeManagement:
            if (args is Map<String, dynamic> && args.containsKey('eventId')) {
              return AttendeeManagementScreen(eventId: args['eventId']);
            }
            return const Scaffold(
              body: Center(
                  child: Text('Invalid event ID for attendee management')),
            );

          case analytics:
            if (args is Map<String, dynamic> && args.containsKey('eventId')) {
              return AnalyticsDashboardScreen(eventId: args['eventId']);
            } else if (args is String) {
              return AnalyticsDashboardScreen(eventId: args);
            }
            return const Scaffold(
              body: Center(child: Text('Invalid event ID for analytics')),
            );

          // Verification routes
          case verificationUpload:
            return const VerificationDocumentUploadScreen();

          case verificationWaiting:
            return const VerificationWaitingScreen();

          case promotorProfile:
            return const PromotorProfileScreen();

          case promotorSettings:
            return const PromotorSettingsScreen();

          // Admin routes
          case admin:
          case adminDashboard:
            return const AdminDashboardScreen();

          case adminUsers:
          case userManagement:
            return const UserManagementScreen();

          case adminPromoters:
          case promoterVerification:
            return const PromoterVerificationScreen();

          case adminEvents:
          case eventModeration:
            return const EventModerationScreen();

          case adminCategories:
          case categoryManagement:
            return const CategoryManagementScreen();

          case adminTags:
          case tagManagement:
            return const TagManagementScreen();

          case adminStatistics:
          case platformStatistics:
            return const PlatformStatisticsScreen();

          case adminSettings:
          case systemSettings:
            return const SystemSettingsScreen();

          // Add other routes as needed

          default:
            // Check for promotor specific sub-routes
            if (settings.name?.startsWith('/promotor/') == true) {
              final path = settings.name?.substring('/promotor/'.length);

              switch (path) {
                case 'create-event':
                  return const EventCreationScreen();

                case 'manage-events':
                  return const EventManagementScreen();

                case 'edit-event':
                  if (args is Map<String, dynamic> &&
                      args.containsKey('eventId')) {
                    return EventEditScreen(eventId: args['eventId']);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Invalid event ID for editing')),
                  );

                case 'my-events':
                  return const EventManagementScreen();
              }
            }

            return Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            );
        }
      },
    );
  }

  // Helper methods from AdminRoutes
  static bool hasAdminAccess(String userType) {
    return userType == 'admin';
  }

  static void redirectIfNotAdmin(BuildContext context, String userType) {
    if (!hasAdminAccess(userType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Admin privileges required.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
}
