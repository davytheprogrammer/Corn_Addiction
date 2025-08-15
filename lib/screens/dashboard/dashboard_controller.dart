import 'package:flutter/material.dart';
import 'package:corn_addiction/models/streak_model.dart';

import 'package:corn_addiction/services/auth_service.dart';
import 'package:corn_addiction/services/database.dart';

class DashboardController extends ChangeNotifier {
  bool _isLoading = true;
  StreakModel? _currentStreak;
  bool _hasCheckedInToday = false;
  int _currentStreakDays = 0;
  DateTime? _lastCheckIn;

  // Getters
  bool get isLoading => _isLoading;
  StreakModel? get currentStreak => _currentStreak;
  bool get hasCheckedInToday => _hasCheckedInToday;
  int get currentStreakDays => _currentStreakDays;
  DateTime? get lastCheckIn => _lastCheckIn;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final database = DatabaseService(uid: authService.currentUser!.uid);
      final streak = await database.getCurrentStreak();

      _currentStreak = streak;

      // Fix: Use the actual daysCount from the database instead of calculating
      if (streak != null && streak.isActive) {
        _currentStreakDays = streak.daysCount;
      } else {
        _currentStreakDays = 0;
      }

      // Check if user has checked in today
      _lastCheckIn = streak?.startDate;
      final today = DateTime.now();
      _hasCheckedInToday = _lastCheckIn != null &&
          _lastCheckIn!.year == today.year &&
          _lastCheckIn!.month == today.month &&
          _lastCheckIn!.day == today.day;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> checkIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final database = DatabaseService(uid: authService.currentUser!.uid);

      await database.checkInDaily();
      await loadUserData(); // Reload data to get updated streak

      return 'Check-in successful! Day $_currentStreakDays complete!';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<String> reportRelapse() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final database = DatabaseService(uid: authService.currentUser!.uid);

      // End current streak if it exists
      if (_currentStreak != null && _currentStreak!.isActive) {
        await database.endStreak(_currentStreak!.id);
      }

      // Reset streak data
      _currentStreak = null;
      _currentStreakDays = 0;
      _hasCheckedInToday = false;
      _lastCheckIn = null;

      await loadUserData(); // Reload data to get updated state

      return 'Relapse reported. Remember, recovery is a journey. You can start fresh tomorrow.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error reporting relapse: ${e.toString()}');
    }
  }
}
