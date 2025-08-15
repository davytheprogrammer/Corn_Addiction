import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _challengesCollection = 
      FirebaseFirestore.instance.collection('challenges');
  final CollectionReference _challengeProgressCollection = 
      FirebaseFirestore.instance.collection('challenge_progress');

  // Create a new challenge
  Future<ChallengeModel> createChallenge({
    required String title,
    required String description,
    required String challengeType,
    required DateTime startDate,
    required DateTime endDate,
    required String badgeId,
    required String badgeName,
    required String badgeDescription,
    required String badgeImagePath,
    required Map<String, dynamic> requirements,
  }) async {
    final newChallengeRef = _challengesCollection.doc();
    
    final challenge = ChallengeModel(
      id: newChallengeRef.id,
      title: title,
      description: description,
      challengeType: challengeType,
      startDate: startDate,
      endDate: endDate,
      badgeId: badgeId,
      badgeName: badgeName,
      badgeDescription: badgeDescription,
      badgeImagePath: badgeImagePath,
      requirements: requirements,
    );

    await newChallengeRef.set(challenge.toFirestore());
    return challenge;
  }

  // Get all challenges
  Future<List<ChallengeModel>> getAllChallenges() async {
    final challengesSnapshot = await _challengesCollection
        .orderBy('startDate', descending: true)
        .get();

    return challengesSnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  // Get active challenges
  Future<List<ChallengeModel>> getActiveChallenges() async {
    final now = DateTime.now();
    final challengesSnapshot = await _challengesCollection
        .where('isActive', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    return challengesSnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  // Get upcoming challenges
  Future<List<ChallengeModel>> getUpcomingChallenges() async {
    final now = DateTime.now();
    final challengesSnapshot = await _challengesCollection
        .where('isActive', isEqualTo: true)
        .where('startDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('startDate')
        .get();

    return challengesSnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  // Get past challenges
  Future<List<ChallengeModel>> getPastChallenges() async {
    final now = DateTime.now();
    final challengesSnapshot = await _challengesCollection
        .where('endDate', isLessThan: Timestamp.fromDate(now))
        .orderBy('endDate', descending: true)
        .get();

    return challengesSnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  // Get a specific challenge
  Future<ChallengeModel?> getChallenge(String challengeId) async {
    final challengeDoc = await _challengesCollection.doc(challengeId).get();
    if (!challengeDoc.exists) {
      return null;
    }
    return ChallengeModel.fromFirestore(challengeDoc);
  }

  // Update a challenge
  Future<void> updateChallenge(ChallengeModel challenge) async {
    await _challengesCollection.doc(challenge.id).update(challenge.toFirestore());
  }

  // Delete a challenge
  Future<void> deleteChallenge(String challengeId) async {
    // Delete the challenge
    await _challengesCollection.doc(challengeId).delete();

    // Delete all related progress records
    final progressSnapshot = await _challengeProgressCollection
        .where('challengeId', isEqualTo: challengeId)
        .get();

    final batch = _firestore.batch();
    for (final doc in progressSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Get user's progress for all challenges
  Future<List<ChallengeProgressModel>> getUserChallengesProgress(String userId) async {
    final progressSnapshot = await _challengeProgressCollection
        .where('userId', isEqualTo: userId)
        .get();

    return progressSnapshot.docs
        .map((doc) => ChallengeProgressModel.fromFirestore(doc))
        .toList();
  }

  // Get user's progress for a specific challenge
  Future<ChallengeProgressModel?> getUserChallengeProgress(String userId, String challengeId) async {
    final progressSnapshot = await _challengeProgressCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (progressSnapshot.docs.isEmpty) {
      return null;
    }

    return ChallengeProgressModel.fromFirestore(progressSnapshot.docs.first);
  }

  // Update user's challenge progress
  Future<void> updateChallengeProgress(ChallengeProgressModel progress) async {
    await _challengeProgressCollection.doc(progress.id).set(progress.toFirestore());
  }

  // Create initial challenge progress for a user
  Future<ChallengeProgressModel> createChallengeProgress(String userId, String challengeId) async {
    final newProgressRef = _challengeProgressCollection.doc();
    
    final progress = ChallengeProgressModel(
      id: newProgressRef.id,
      userId: userId,
      challengeId: challengeId,
    );

    await newProgressRef.set(progress.toFirestore());
    return progress;
  }

  // Get all users' progress for a specific challenge
  Future<List<ChallengeProgressModel>> getAllUsersProgressForChallenge(String challengeId) async {
    final progressSnapshot = await _challengeProgressCollection
        .where('challengeId', isEqualTo: challengeId)
        .get();

    return progressSnapshot.docs
        .map((doc) => ChallengeProgressModel.fromFirestore(doc))
        .toList();
  }
}