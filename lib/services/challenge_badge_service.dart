import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/challenge_badge_model.dart'; 
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../models/user_model.dart';
import '../widgets/challenge_badge_card.dart';

class ChallengeBadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Award badge to user when challenge is completed
  Future<ChallengeBadgeModel?> awardBadgeForChallenge(
    String userId,
    ChallengeModel challenge,
    ChallengeProgressModel progress,
  ) async {
    // Check if challenge is completed
    if (!progress.isCompleted) {
      return null;
    }
    
    // Check if badge is already awarded
    if (progress.badgeAwarded) {
      return null;
    }
    
    // Create new badge
    final badge = ChallengeBadgeModel(
      id: '', // Will be set after Firestore add
      userId: userId,
      badgeId: challenge.badgeId,
      badgeName: challenge.badgeName,
      badgeDescription: challenge.badgeDescription,
      badgeImagePath: challenge.badgeImagePath,
      earnedAt: DateTime.now(),
      challengeType: challenge.challengeType,
      challengeId: challenge.id,
      isDisplayed: true,
    );
    
    // Save badge to Firestore
    final docRef = await _firestore.collection('challenge_badges').add(badge.toFirestore());
    
    // Update badge with generated ID
    final updatedBadge = badge.copyWith(id: docRef.id);
    await docRef.update({'id': docRef.id});
    
    // Update challenge progress to mark badge as awarded
    await _firestore.collection('challenge_progress').doc(progress.id).update({
      'badgeAwarded': true,
    });
    
    // Update user's earned badges
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final user = UserModel.fromFirestore(userDoc);
    final updatedEarnedBadges = List<String>.from(user.earnedBadges)..add(updatedBadge.badgeId);
    await _firestore.collection('users').doc(userId).update({
      'earnedBadges': updatedEarnedBadges,
    });
    
    return updatedBadge;
  }
  
  // Get all user's badges
  Future<List<ChallengeBadgeModel>> getUserBadges(String userId) async {
    final querySnapshot = await _firestore
        .collection('challenge_badges')
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => ChallengeBadgeModel.fromFirestore(doc))
        .toList();
  }
  
  // Toggle badge display status
  Future<void> toggleBadgeDisplay(String badgeId, bool isDisplayed) async {
    await _firestore.collection('challenge_badges').doc(badgeId).update({
      'isDisplayed': isDisplayed,
    });
  }
  
  // Show badge earned popup
  void showBadgeEarnedPopup(BuildContext context, ChallengeBadgeModel badge) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: badge.challengeType == 'weekly'
                    ? [Colors.teal.shade300, Colors.teal.shade700]
                    : [Colors.amber.shade300, Colors.amber.shade700],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Badge Earned!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      badge.badgeImagePath,
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge.badgeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  badge.badgeDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: badge.challengeType == 'weekly'
                        ? Colors.teal.shade700
                        : Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}