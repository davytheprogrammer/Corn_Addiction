import 'package:flutter/material.dart';

import '../models/challenge_badge_model.dart';

class ChallengeBadgeCard extends StatelessWidget {
  final ChallengeBadgeModel badge;
  final VoidCallback? onToggleDisplay;

  const ChallengeBadgeCard({
    Key? key,
    required this.badge,
    this.onToggleDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getChallengeTypeColors(),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              badge.badgeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  badge.badgeImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.badgeDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned on ${_formatDate(badge.earnedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            if (onToggleDisplay != null)
              ElevatedButton.icon(
                onPressed: onToggleDisplay,
                icon: Icon(
                  badge.isDisplayed ? Icons.visibility : Icons.visibility_off,
                  color: _getPrimaryColor(),
                ),
                label: Text(
                  badge.isDisplayed ? 'Hide Badge' : 'Display Badge',
                  style: TextStyle(color: _getPrimaryColor()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _getChallengeTypeColors() {
    if (badge.challengeType == 'weekly') {
      return [Colors.teal.shade300, Colors.teal.shade700];
    } else {
      return [Colors.amber.shade300, Colors.amber.shade700];
    }
  }

  Color _getPrimaryColor() {
    if (badge.challengeType == 'weekly') {
      return Colors.teal.shade700;
    } else {
      return Colors.amber.shade700;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}