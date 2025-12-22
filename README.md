# AgriNest - Ethiopian Smart Farming App

[![GitHub repo](https://img.shields.io/badge/GitHub-Ya--Red7/IETP--AgriNest-blue)](https://github.com/Ya-Red7/IETP-AgriNest)

AgriNest is a comprehensive mobile application designed to revolutionize farming practices in Ethiopia through smart technology integration. This project is developed as part of the IETP (Integrated Engineering Team Project) curriculum.

The app provides farmers with real-time monitoring, analytics, and insights to optimize crop yields and resource management.

## Features

- **Real-time Sensor Monitoring**: Track soil moisture, temperature, humidity, and light levels
- **Data Analytics**: Visualize farming data with interactive charts and graphs
- **User Authentication**: Secure login and signup with Firebase Authentication
- **Multi-language Support**: Available in English and Amharic
- **Offline Data Storage**: Local data persistence with Hive
- **Smart Notifications**: Alerts for optimal farming conditions

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Firebase (Authentication, Firestore)
- **Local Storage**: Hive
- **Charts**: FL Chart
- **Navigation**: Go Router
- **UI**: Material Design with custom theming

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio or VS Code
- Firebase project setup

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Ya-Red7/IETP-AgriNest.git
   cd IETP-AgriNest
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Authentication and Firestore
   - Download `google-services.json` and place it in `android/app/`
   - Update Firebase configuration in `lib/firebase_options.dart`

4. Run the app:
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Generate Riverpod code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build APK for Android
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

## Screenshots

*Screenshots will be added after the first stable release*

## Project Structure

```
lib/
├── core/              # Core utilities and configurations
│   ├── localization/  # Multi-language support
│   ├── theme/         # App theming and styles
│   └── utils/         # Constants and helpers
├── models/            # Data models
├── providers/         # State management providers
├── routes/            # App routing configuration
├── screens/           # UI screens
├── services/          # Business logic and API services
└── widgets/           # Reusable UI components
```

## Project Context

This project is developed as part of the Integrated Engineering Team Project (IETP) coursework. AgriNest demonstrates the integration of modern mobile development technologies with agricultural technology to address real-world problems in Ethiopian farming.

### Academic Objectives
- Demonstrate proficiency in Flutter mobile development
- Implement Firebase backend services
- Apply software engineering best practices
- Create a user-friendly interface for agricultural data management

## Contributing

Contributions are welcome! This is an educational project, so feel free to:
- Report issues and suggest improvements
- Submit pull requests for bug fixes or enhancements
- Share feedback on the implementation

## Acknowledgments

- **Institution**: Addis Ababa Science and Technology University (AASTU)
- **Program**: Integrated Engineering Team Project (IETP)
- **Group**: Group 81
- **Year**: 2025

## License

This project is developed for educational purposes by Group 81 - AASTU IETP 2025.

## Support

For support or questions, please contact the development team or create an issue in the [GitHub repository](https://github.com/Ya-Red7/IETP-AgriNest/issues).
