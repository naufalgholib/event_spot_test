class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.eventspot.com/api';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String eventsEndpoint = '/events';
  static const String categoriesEndpoint = '/categories';
  static const String usersEndpoint = '/users';
  static const String promotersEndpoint = '/promoters';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String darkModeKey = 'dark_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Firebase
  static const String fcmTopic = 'event_notifications';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 200);

  // Layout Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 16.0;

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // User Types
  static const String userTypeAdmin = 'admin';
  static const String userTypePromoter = 'promoter';
  static const String userTypeRegular = 'regular';
}
