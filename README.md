# ServiceConnect

A Flutter mobile application connecting home service providers with customers. Users can either find professionals for home repairs or offer their services as professionals.

## Features

- **Dual User Roles**: Customer and Professional modes
- **Authentication**: Email/password authentication with Supabase
- **Service Categories**: Browse multiple service categories (Plumbing, Electrical, Carpentry, etc.)
- **Service Requests**: Customers can create service requests
- **Job Marketplace**: Professionals can browse and accept available requests
- **Real-time Updates**: Track service request status
- **Secure Backend**: Supabase with Row Level Security

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd project
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Setup

The `.env` file is already configured with Supabase credentials. No additional setup is needed.

### 4. Run the Application

For Android:
```bash
flutter run
```

For iOS (macOS only):
```bash
flutter run -d ios
```

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user_profile.dart
│   ├── service_category.dart
│   └── service_request.dart
├── screens/             # UI screens
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── auth/           # Authentication screens
│   ├── customer/       # Customer-specific screens
│   └── professional/   # Professional-specific screens
├── services/            # Business logic and API calls
│   └── supabase_service.dart
└── main.dart           # Application entry point
```

## Database Schema

The app uses Supabase with the following tables:

- **profiles**: User profiles with type (customer/professional)
- **service_categories**: Available service categories
- **service_requests**: Service requests created by customers
- **reviews**: Reviews and ratings

## Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
flutter build ios --release
```

Then archive and distribute via Xcode.

## Testing

Run the test suite:

```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **Dependencies Error**: Run `flutter pub get` again
2. **Build Errors**: Run `flutter clean` then `flutter pub get`
3. **Android Build Issues**: Ensure Android SDK is properly configured
4. **iOS Build Issues**: Run `pod install` in the `ios/` directory

## User Flows

### Customer Flow
1. Sign up as a customer
2. Browse service categories
3. Create a service request
4. View request status
5. Track accepted requests

### Professional Flow
1. Sign up as a professional
2. Browse available service requests
3. Accept requests
4. Track accepted jobs
5. Manage job status

## Technology Stack

- **Framework**: Flutter (>=3.0.0 <4.0.0)
- **Language**: Dart (>=3.0.0 <4.0.0)
- **Backend**: Supabase
- **Authentication**: Supabase Auth (`supabase_flutter: ^2.5.0`)
- **Environment Variables**: `flutter_dotenv: ^5.1.0`
- **Database**: PostgreSQL (via Supabase)
- **State Management**: StatefulWidget

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
