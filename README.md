# 🐝 SavvyBee — Your AI Financial Coach

This is a Flutter app that analyzes real bank statements/receipts and turns them into a clean dashboard plus AI coaching (Groq). This guide is beginner‑friendly.

## 🎯 Vision

To guide users from their current financial reality to long-term financial mastery by combining hard numbers with human psychology in a single, proactive assistant.

## 🏗️ Architecture

### Frontend
- **Flutter** - Cross-platform (iOS, Android, Web-ready)
- **Riverpod** - State management
- **GoRouter** - Navigation with deep linking
- **Hive** - Offline caching

### Backend
- **Firebase** - Authentication, Firestore, Storage, Functions
- **OpenAI** - AI-powered insights and coaching
- **Firebase ML Kit** - Local document processing

### Design Principles
- Modern minimalism with whitespace-rich layouts
- Smooth motion design with microinteractions
- Warm, empathetic tone throughout
- Optional dark mode

## 🚀 Quick Start (Beginner)

### Prerequisites
- Flutter SDK 3.22+ installed
- macOS for iOS Simulator, or Chrome for Web
- Groq API key

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <your-repo-url> "SavvyBee"
   cd "SavvyBee"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Groq**
   Open `lib/shared/services/groq_ai_service.dart` and paste your key in `_apiKey`.

4. **Run the app**
   - Web (easiest): `flutter run -d chrome`
   - iOS (macOS):
     ```bash
     open -a Simulator
     flutter precache --ios
     flutter run -d "iPhone 16 Plus"
     ```

## 📱 What you can do

### Core Modules (6)
1. **Heal Me** - Instant, empathetic financial counselling
2. **Analyse Me** - Quick analysis of recent uploads
3. **Journal Log** - Guided prompts on spending + feelings
4. **DocBox** - Statements & receipts vault with OCR
5. **Goal Setter** - AI-powered goal planning
6. **Piggy Bank** - Gamified savings tracker

### Innovative Add-ons (4)
1. **Webscraper Discounts** - Price monitoring and alerts
2. **Financial Moodboard** - Visual motivators
3. **Financial Replay** - Monthly story recaps
4. **Pocket Coach Mode** - Daily micro-checkins

## 🎨 User Experience

- **Onboarding to Home** ≤ 90 seconds
- **First actionable tip** ≤ 30 seconds after landing
- **No dead ends** - every insight leads to action
- **Proactive AI coaching**
- **Interconnected features** that "talk" to each other

## 🔒 Security & Privacy

- GDPR + NDPR compliant
- End-to-end encryption
- Secure document processing
- User data ownership

## 📊 Project Structure (where things live)

```
lib/
├── core/                    # Core app configuration
│   ├── config/             # Firebase, environment config
│   ├── theme/              # App theming
│   ├── routing/            # Navigation
│   └── providers/          # State management
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── home/               # Main navigation shell
│   ├── chat/               # AI chat interface
│   ├── dashboard/          # Financial overview
│   ├── docbox/             # Document management
│   ├── goals/              # Goal setting & tracking
│   ├── journal/            # Mood & spending logs
│   ├── heal_me/            # Financial counselling
│   ├── analyse_me/         # Transaction analysis
│   └── piggy_bank/         # Savings tracker
└── shared/                 # Shared utilities
    ├── models/             # Data models
    ├── services/           # Business logic
    ├── utils/              # Helper functions
    └── widgets/            # Reusable UI components
```

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## 📦 Build & Deploy

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is proprietary and confidential.

## 🆘 Support

For support and questions, please contact the development team.

---

**Savvy Bee** - Making financial wellness accessible, empathetic, and intelligent. 🐝✨
# Force new build Mon Oct  6 10:34:07 WAT 2025
# Deployment trigger Mon Oct  6 12:31:40 WAT 2025
# FORCE UPDATE: Perfect local version Mon Oct  6 12:40:42 WAT 2025
