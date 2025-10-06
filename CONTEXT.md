# Savvy Bee - Project Context & Requirements

## 🐝 Product Overview
**Savvy Bee** — Your money, your mind, working together.

A warm, intuitive AI-powered finance companion that understands your habits, your goals, and your feelings — and works with you until you win.

## 🎯 Vision
To guide users from their current financial reality to long-term financial mastery by combining hard numbers with human psychology in a single, proactive assistant.

## 🏗️ Architecture Decisions

### Frontend: Flutter
- Cross-platform (iOS, Android, Web-ready)
- Modern UI with smooth animations and microinteractions
- Riverpod for state management
- GoRouter for navigation
- Hive for offline caching

### Backend: Firebase
- Firestore for real-time database
- Firebase Auth for authentication
- Firebase Storage for document uploads
- Firebase Functions for AI processing
- Firebase Analytics for user insights

### AI Integration
- OpenAI API for intelligent responses
- Firebase ML Kit for local processing
- Vector embeddings for user memory

## 🎨 Design Principles
- Modern minimalism with whitespace-rich layouts
- Optional dark mode
- SVG icons only
- Smooth motion design with microinteractions
- Warm, empathetic tone throughout

## 🚀 MVP Features

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

## 📱 User Experience
- Onboarding to Home ≤ 90 seconds
- First actionable tip ≤ 30 seconds
- No dead ends - every insight leads to action
- Proactive AI coaching
- Interconnected features that "talk" to each other

## 🔒 Security & Privacy
- GDPR + NDPR compliant
- End-to-end encryption
- Secure document processing
- User data ownership

## 📊 Success Metrics
- User engagement with AI features
- Financial goal completion rates
- Document upload frequency
- User retention and satisfaction

## 🎯 Target Users
1. **Budget Conscious Beginners** - Need clarity and emotional support
2. **Goal-Driven Savers** - Have targets and need plans
3. **Overwhelmed Earners** - Earn well but feel they have nothing to show

## 🔄 Development Phases
1. **Phase 1**: Core architecture and basic modules
2. **Phase 2**: AI integration and advanced features
3. **Phase 3**: Analytics and optimization
4. **Phase 4**: Scale and additional integrations
