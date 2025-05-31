class AppConstants {
  // API
  static const String baseUrl = 'http://192.168.1.9:8000/api';
  static const int apiTimeoutSeconds = 30;

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // UI Constants
  static const double borderRadius = 8.0;
  static const double buttonBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double chipBorderRadius = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;

  // Animation
  static const int splashDurationMs = 2000;
  static const int animationDurationMs = 300;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;

  // Pagination
  static const int defaultPageSize = 10;

  // Date Formats
  static const String dateFormat = 'E, MMM d, y';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'E, MMM d, y • h:mm a';

  // Event
  static const int defaultMaxAttendees = 100;
  static const double defaultTicketPrice = 0.0;

  // File Size Limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // User Roles
  static const String roleAdmin = 'admin';
  static const String rolePromoter = 'promoter';
  static const String roleUser = 'user';

  // Notification Channels
  static const String channelEvents = 'events';
  static const String channelBookings = 'bookings';
  static const String channelSystem = 'system';

  // Storage Keys
  static const String storageKeyToken = 'token';
  static const String storageKeyUser = 'user';
  static const String storageKeySettings = 'settings';
}
