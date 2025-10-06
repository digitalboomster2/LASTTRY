# 🚀 Savvy Bee - Setup Guide

This guide will walk you through setting up the Savvy Bee Flutter application on your local development environment.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** / **VS Code** with Flutter extensions
- **Git**
- **Firebase CLI** (for backend setup)
- **Node.js** (for Firebase Functions)

## 🔧 Initial Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd SavvyBee
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

## 🔥 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `savvy-bee-app`
4. Enable Google Analytics (recommended)
5. Choose analytics account or create new one

### 2. Configure Flutter App
```bash
flutterfire configure
```

This will:
- Detect your Flutter project
- List available Firebase projects
- Generate `firebase_options.dart` file
- Configure platforms (iOS, Android, Web)

### 3. Enable Firebase Services
In your Firebase project, enable these services:

#### Authentication
- Go to Authentication > Sign-in method
- Enable Email/Password
- Enable Google Sign-in (optional)

#### Firestore Database
- Go to Firestore Database
- Click "Create database"
- Start in test mode (for development)
- Choose location closest to your users

#### Storage
- Go to Storage
- Click "Get started"
- Start in test mode
- Choose location

#### Functions (Optional)
- Go to Functions
- Click "Get started"
- Install Firebase CLI if prompted

### 4. Set Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow access to subcollections
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own documents
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🔑 Environment Configuration

### 1. OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create account or sign in
3. Generate API key
4. Add to your environment or create `.env` file

### 2. Create Environment File
Create `lib/core/config/env.dart`:
```dart
class Env {
  static const String openaiApiKey = 'your_openai_api_key_here';
  // Add other environment variables as needed
}
```

## 📱 Platform-Specific Setup

### Android
1. Ensure Android SDK is installed
2. Create/update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

3. Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
1. Ensure Xcode is installed
2. Open `ios/Runner.xcworkspace` in Xcode
3. Update deployment target to iOS 12.0+
4. Add camera and photo library usage descriptions in `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan receipts and documents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to upload financial documents.</string>
```

### Web
1. Ensure Flutter web is enabled:
```bash
flutter config --enable-web
```

2. Add Firebase web configuration to `web/index.html`:
```html
<script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-storage.js"></script>
```

## 🧪 Testing Setup

### 1. Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

### 2. Test on Devices
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on all connected devices
flutter run -d all
```

## 🚀 Running the App

### 1. Development Mode
```bash
flutter run
```

### 2. Release Mode
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### 3. Profile Mode (Performance Testing)
```bash
flutter run --profile
```

## 📊 Firebase Analytics Setup

### 1. Enable Analytics
1. Go to Firebase Console > Analytics
2. Click "Get started"
3. Follow setup instructions

### 2. Test Events
The app automatically tracks these events:
- App opens
- Feature usage
- Goal creation
- Document uploads
- AI insights generated

## 🔍 Debugging & Troubleshooting

### Common Issues

#### 1. Firebase Configuration Errors
- Ensure `firebase_options.dart` is generated correctly
- Verify Firebase project ID matches
- Check if all required services are enabled

#### 2. Permission Errors
- Verify platform-specific permissions are set
- Check if device supports required features
- Ensure proper usage descriptions (iOS)

#### 3. Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart SDK versions
- Verify all dependencies are compatible

#### 4. AI Service Errors
- Verify OpenAI API key is valid
- Check internet connectivity
- Ensure API key has sufficient credits

### Debug Commands
```bash
# Clean build
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor

# Analyze code
flutter analyze

# Format code
flutter format .

# Check dependencies
flutter pub deps
```

## 📱 App Features to Test

### Core Functionality
1. **Onboarding Flow** - Complete user setup
2. **Dashboard** - View financial overview
3. **AI Chat** - Interact with financial coach
4. **Document Upload** - Test receipt scanning
5. **Goal Setting** - Create and track financial goals
6. **Journal Entries** - Log mood and spending

### AI Features
1. **Heal Me** - Get financial counselling
2. **Analyse Me** - Review spending patterns
3. **Daily Coaching** - Receive personalized tips
4. **Goal Recommendations** - AI-suggested financial goals

## 🔄 Development Workflow

### 1. Feature Development
1. Create feature branch: `git checkout -b feature/feature-name`
2. Implement feature with tests
3. Run tests: `flutter test`
4. Commit changes: `git commit -m "feat: add feature description"`
5. Push and create pull request

### 2. Code Quality
- Follow Flutter style guide
- Write unit tests for business logic
- Use meaningful commit messages
- Document complex functions

### 3. Testing Strategy
- Unit tests for services and models
- Widget tests for UI components
- Integration tests for user flows
- Manual testing on real devices

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://gorouter.dev/)

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Search existing GitHub issues
3. Create a new issue with:
   - Flutter version: `flutter --version`
   - Error logs
   - Steps to reproduce
   - Device/platform information

---

**Happy coding! 🐝✨**

Your Savvy Bee app should now be ready to run and develop!
