import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/pre_chat_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/docbox/presentation/pages/docbox_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/heal_me/presentation/pages/heal_me_page.dart';
import '../../features/analyse_me/presentation/pages/analyse_me_page.dart';
import '../../features/piggy_bank/presentation/pages/piggy_bank_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Root route - redirect to splash
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const PreChatPage(),
      ),
            // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const PreChatPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Pre-chat page (standalone, no navigation)
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const PreChatPage(),
      ),
      
      // Standalone chat page (no navigation bar)
      GoRoute(
        path: '/chat/main',
        name: 'chat-main',
        builder: (context, state) => const ChatPage(),
      ),
      
      // Main App
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
      // Root route - redirect to splash
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const PreChatPage(),
      ),
                
          // Dashboard Tab
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          
          // DocBox Tab
          GoRoute(
            path: '/docbox',
            name: 'docbox',
            builder: (context, state) => const DocBoxPage(),
          ),
          
          // Goals Tab
          GoRoute(
            path: '/goals',
            name: 'goals',
            builder: (context, state) => const GoalsPage(),
          ),
          
          // Journal Tab
          GoRoute(
            path: '/journal',
            name: 'journal',
            builder: (context, state) => const JournalPage(),
          ),
        ],
      ),
      
      // Feature Pages
      GoRoute(
        path: '/heal-me',
        name: 'heal-me',
        builder: (context, state) => const HealMePage(),
      ),
      
      GoRoute(
        path: '/analyse-me',
        name: 'analyse-me',
        builder: (context, state) => const AnalyseMePage(),
      ),
      
      GoRoute(
        path: '/piggy-bank',
        name: 'piggy-bank',
        builder: (context, state) => const PiggyBankPage(),
      ),
    ],
  );
});
