export 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // ALWAYS force light theme to match the iOS simulator design exactly
  return ThemeMode.light;
});

// Auth Providers
final authStateProvider = StreamProvider((ref) {
  // TODO: Implement Firebase Auth stream
  return Stream.empty();
});

final userProvider = Provider((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Navigation Provider
final currentIndexProvider = StateProvider<int>((ref) => 0);

// AI Coach Provider
final aiCoachProvider = StateProvider<String>((ref) => 'Emma');

// User Preferences Provider
final userPreferencesProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'notifications': true,
    'darkMode': false,
    'cameraAccess': false,
    'fileAccess': false,
  };
});
