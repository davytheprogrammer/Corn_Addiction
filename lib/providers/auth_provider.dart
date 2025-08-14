import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/models/the_user.dart';
import 'package:corn_addiction/models/user_model.dart';
import 'package:corn_addiction/services/auth.dart';
import 'package:corn_addiction/services/firestore_service.dart';
import 'package:corn_addiction/services/local_storage_service.dart';

// Core service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Auth state provider
final authStateProvider = StreamProvider<TheUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.user;
});

// Current user provider - fetches full user data from Firestore
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  
  if (authState == null) return null;
  
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getUser(authState.uid!);
});

// User streak provider
final userCurrentStreakProvider = FutureProvider<int>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  
  if (authState == null) return 0;
  
  final firestoreService = ref.read(firestoreServiceProvider);
  final streak = await firestoreService.getCurrentStreak(authState.uid!);
  
  return streak?.daysCount ?? 0;
});

// App settings provider from local storage
final appSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return LocalStorageService.getAppSettings();
});

// Notification settings provider
final notificationSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return LocalStorageService.getNotificationSettings();
});

// Auth loading provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error provider
final authErrorProvider = StateProvider<String?>((ref) => null);
