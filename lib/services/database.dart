import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/streak_model.dart';
import '../models/urge_log_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // collection references:
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference streakCollection =
      FirebaseFirestore.instance.collection('streaks');
  final CollectionReference urgeLogCollection =
      FirebaseFirestore.instance.collection('urgeLogs');

  Future updateUserData(String? displayName, String? email, String type) async {
    return await userCollection.doc(uid).set({
      'displayName': displayName,
      'email': email,
      'type': type, // P-Patient or T-Therapist
      'sober_days': null,
      'last_checked_in': null,
    });
  }

  // get users stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

  // Get current active streak for user
  Future<StreakModel?> getCurrentStreak() async {
    if (uid == null) return null;

    try {
      final querySnapshot = await streakCollection
          .where('userId', isEqualTo: uid)
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return StreakModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current streak: $e');
      return null;
    }
  }

  // Get urge logs for user based on timeframe
  Future<List<UrgeLogModel>> getUrgeLogs({String timeframe = 'week'}) async {
    if (uid == null) return [];

    try {
      DateTime startDate;
      final endDate = DateTime.now();

      switch (timeframe) {
        case 'week':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
          break;
        case '3months':
          startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
          break;
        case 'year':
          startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 7));
      }

      final querySnapshot = await urgeLogCollection
          .where('userId', isEqualTo: uid)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UrgeLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting urge logs: $e');
      return [];
    }
  }

  // Add a new streak
  Future<void> addStreak(StreakModel streak) async {
    try {
      await streakCollection.add(streak.toFirestore());
    } catch (e) {
      debugPrint('Error adding streak: $e');
      rethrow;
    }
  }

  // Add a new urge log
  Future<void> addUrgeLog(UrgeLogModel urgeLog) async {
    try {
      await urgeLogCollection.add(urgeLog.toFirestore());
    } catch (e) {
      debugPrint('Error adding urge log: $e');
      rethrow;
    }
  }

  // Update streak
  Future<void> updateStreak(String streakId, Map<String, dynamic> data) async {
    try {
      await streakCollection.doc(streakId).update(data);
    } catch (e) {
      debugPrint('Error updating streak: $e');
      rethrow;
    }
  }

  // Create or update daily check-in
  Future<void> checkInDaily() async {
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get current active streak
      final currentStreak = await getCurrentStreak();

      if (currentStreak == null) {
        // Create new streak
        final newStreak = StreakModel(
          id: '',
          userId: uid!,
          startDate: today,
          daysCount: 1,
          isActive: true,
        );
        await addStreak(newStreak);
      } else {
        // Update existing streak
        final daysSinceStart =
            today.difference(currentStreak.startDate).inDays + 1;
        await updateStreak(currentStreak.id, {
          'daysCount': daysSinceStart,
          'lastCheckIn': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      debugPrint('Error checking in daily: $e');
      rethrow;
    }
  }
}
