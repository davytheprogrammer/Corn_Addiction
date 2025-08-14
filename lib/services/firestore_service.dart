import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corn_addiction/models/daily_checkin_model.dart';
import 'package:corn_addiction/models/streak_model.dart';
import 'package:corn_addiction/models/urge_log_model.dart';
import 'package:corn_addiction/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');
  
  // User methods
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }
  
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }
  
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toFirestore());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }
  
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    try {
      await _usersCollection.doc(uid).update({field: value});
    } catch (e) {
      print('Error updating user field: $e');
      rethrow;
    }
  }
  
  // Streak methods
  Future<String> createStreak(StreakModel streak) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(streak.userId)
          .collection('streaks')
          .add(streak.toFirestore());
      
      return docRef.id;
    } catch (e) {
      print('Error creating streak: $e');
      rethrow;
    }
  }
  
  Future<StreakModel?> getCurrentStreak(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return StreakModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching current streak: $e');
      rethrow;
    }
  }
  
  Future<void> endStreak(String userId, String streakId, DateTime endDate, String reason) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .doc(streakId)
          .update({
            'isActive': false,
            'endDate': Timestamp.fromDate(endDate),
            'endReason': reason
          });
    } catch (e) {
      print('Error ending streak: $e');
      rethrow;
    }
  }
  
  Future<List<StreakModel>> getUserStreaks(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .orderBy('startDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => StreakModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching user streaks: $e');
      rethrow;
    }
  }
  
  // Daily check-in methods
  Future<String> createDailyCheckIn(DailyCheckInModel checkIn) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(checkIn.userId)
          .collection('checkIns')
          .add(checkIn.toFirestore());
      
      // Update user stats
      await _usersCollection.doc(checkIn.userId).update({
        'checkInsCompleted': FieldValue.increment(1),
        'lastActive': Timestamp.fromDate(DateTime.now())
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating daily check-in: $e');
      rethrow;
    }
  }
  
  Future<DailyCheckInModel?> getCheckInForDate(String userId, DateTime date) async {
    try {
      // Create date range to match the entire day
      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkIns')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return DailyCheckInModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching check-in for date: $e');
      rethrow;
    }
  }
  
  Future<List<DailyCheckInModel>> getUserCheckIns(
      String userId, {int limit = 30}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkIns')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => DailyCheckInModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching user check-ins: $e');
      rethrow;
    }
  }
  
  // Urge log methods
  Future<String> createUrgeLog(UrgeLogModel urgeLog) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(urgeLog.userId)
          .collection('urgeLogs')
          .add(urgeLog.toFirestore());
      
      // Update user stats
      if (urgeLog.wasResisted) {
        await _usersCollection.doc(urgeLog.userId).update({
          'urgesResisted': FieldValue.increment(1),
          'lastActive': Timestamp.fromDate(DateTime.now())
        });
      } else {
        // If the urge was not resisted, we should end the current streak
        StreakModel? currentStreak = await getCurrentStreak(urgeLog.userId);
        if (currentStreak != null) {
          await endStreak(
            urgeLog.userId, 
            currentStreak.id, 
            urgeLog.timestamp, 
            'Relapse recorded'
          );
          
          // Start a new streak
          StreakModel newStreak = StreakModel(
            id: '', // Will be set by Firestore
            userId: urgeLog.userId,
            startDate: urgeLog.timestamp.add(const Duration(minutes: 1)), // Start 1 minute after relapse
            daysCount: 0,
            isActive: true
          );
          await createStreak(newStreak);
        }
      }
      
      return docRef.id;
    } catch (e) {
      print('Error creating urge log: $e');
      rethrow;
    }
  }
  
  Future<List<UrgeLogModel>> getUserUrgeLogs(
      String userId, {int limit = 30}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('urgeLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => UrgeLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching user urge logs: $e');
      rethrow;
    }
  }
  
  // Analytics methods
  Future<Map<String, int>> getMonthlyUrgeData(String userId, DateTime month) async {
    try {
      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('urgeLogs')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();
      
      Map<String, int> urgesByDay = {};
      
      // Initialize all days of the month with 0
      for (int i = 1; i <= endOfMonth.day; i++) {
        urgesByDay[i.toString()] = 0;
      }
      
      // Count urges by day
      for (var doc in snapshot.docs) {
        UrgeLogModel urge = UrgeLogModel.fromFirestore(doc);
        String day = urge.timestamp.day.toString();
        urgesByDay[day] = (urgesByDay[day] ?? 0) + 1;
      }
      
      return urgesByDay;
    } catch (e) {
      print('Error fetching monthly urge data: $e');
      rethrow;
    }
  }
}
