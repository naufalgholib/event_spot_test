# Event Spot

Event Spot is a comprehensive Flutter application for event discovery and management. It provides features for event browsing, booking, and management, built with a clean architecture approach and modern UI principles.

## 📱 Features

- **User Authentication**: Register, login, and manage user profiles
- **Event Discovery**: Browse events with filtering by category, date, and price
- **Event Details**: View comprehensive information about events
- **Booking System**: Register for events and process payments
- **User Profiles**: View registered events and bookmarks 
- **Promoter Profiles**: Special interface for event organizers
- **Search Functionality**: Find events by keywords, locations, or categories

## 🛠️ Tech Stack

- **Flutter**: UI framework for cross-platform development
- **Material 3 Design**: Modern UI with light and dark theme support
- **Mock Repositories**: Simulated backend for development and testing

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (v3.10+ recommended)
- [Dart](https://dart.dev/get-dart) (v3.0+ recommended)
- Android Studio, VS Code, or any other IDE with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/naufalgholib/event_spot.git
   cd event_spot_test
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create necessary assets folders:
   ```bash
   mkdir -p assets/images
   touch assets/images/placeholder.png
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## 🧪 Testing the Application

The application uses mock repositories for data simulation. You can use the following credentials to test different user types:

### Admin Account
- Email: admin@eventspot.com
- Password: admin123

### Promoter Accounts
- Email: jane.smith@example.com
- Password: promoter123
- Email: sarah.williams@example.com
- Password: promoter456

### Regular User Accounts
- Email: mike.johnson@example.com
- Password: user123
- Email: alex.brown@example.com
- Password: user456

> Note: For development convenience, the application will also accept any password with 6 or more characters, but using the actual passwords provides a more realistic experience.

### Navigating the App

- The application starts with a splash screen, followed by an onboarding experience
- Navigate through the bottom tabs to access different sections
- Use the Home tab to browse events
- View your profile and registered events in the Profile tab
- Search for specific events using the Search feature

## 📱 Screen Simulation

To bypass authentication and directly test specific screens:

1. Open `lib/main.dart`
2. Replace the current `MyApp` class with code that directly loads a specific screen
3. For example, to test the payment screen:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return MaterialApp(
      title: 'Event Spot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Temporarily bypassing router to go directly to payment screen
      home: PaymentScreen(
        event: EventModel(
          id: 1,
          title: 'Music Festival 2023',
          // Include all required event properties
          ...
        ),
        registration: RegistrationModel(
          id: 101,
          eventId: 1,
          userId: 3,
          status: 'pending_payment',
          amount: 299.98,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  }
}
```

4. After testing, revert the changes to restore normal app flow

## 🏗️ Project Structure

```
lib/
├── core/              # Core components
│   ├── config/        # App configuration (router, constants)
│   ├── theme/         # Theme definitions
│   └── utils/         # Utility functions
├── data/              # Data layer
│   ├── models/        # Data models
│   └── repositories/  # Mock data repositories
└── presentation/      # UI layer
    ├── screens/       # App screens
    └── widgets/       # Reusable widgets
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is distributed under the MIT License. See `LICENSE` for more information.

## 📬 Contact

Your Name - your.email@example.com

Project Link: [https://github.com/yourusername/event_spot](https://github.com/yourusername/event_spot)

## 🔮 Roadmap

- Integrate with a real backend API
- Add real payment processing
- Implement push notifications
- Add maps integration for event locations
- Build admin dashboard for event moderation
