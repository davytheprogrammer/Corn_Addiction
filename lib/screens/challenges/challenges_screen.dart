import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/challenge_model.dart';
import '../../models/challenge_progress_model.dart';
import '../../models/user_model.dart';
import '../../services/challenge_service.dart';
import '../../services/rewards_service.dart';
import '../../widgets/common_widgets.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChallengeService _challengeService = ChallengeService();
  final RewardsService _rewardsService = RewardsService();
  bool _isLoading = true;
  List<ChallengeModel> _activeChallenges = [];
  List<ChallengeModel> _upcomingChallenges = [];
  Map<String, ChallengeProgressModel?> _userProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<UserModel?>(context, listen: false);
      if (user != null) {
        final activeChallenges = await _challengeService.getActiveChallenges();
        final upcomingChallenges = await _challengeService.getUpcomingChallenges();
        
        // Load user progress for active challenges
        final Map<String, ChallengeProgressModel?> userProgress = {};
        for (final challenge in activeChallenges) {
          final progress = await _challengeService.getUserChallengeProgress(user.uid, challenge.id);
          if (progress == null) {
            // Create progress entry if it doesn't exist
            final newProgress = await _challengeService.createChallengeProgress(user.uid, challenge.id);
            userProgress[challenge.id] = newProgress;
          } else {
            userProgress[challenge.id] = progress;
          }
        }

        setState(() {
          _activeChallenges = activeChallenges;
          _upcomingChallenges = upcomingChallenges;
          _userProgress = userProgress;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading challenges: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProgress(String challengeId, String key, dynamic value) async {
    try {
      final user = Provider.of<UserModel?>(context, listen: false);
      if (user == null) return;

      final currentProgress = _userProgress[challengeId];
      if (currentProgress == null) return;

      // Update progress
      final updatedProgress = currentProgress.updateProgress(key, value);
      await _challengeService.updateChallengeProgress(updatedProgress);

      // Get challenge to check requirements
      final challenge = _activeChallenges.firstWhere((c) => c.id == challengeId);
      
      // Check if challenge is completed and award badge
      final badge = await _rewardsService.checkAndAwardChallengeBadge(
        user.uid, 
        challengeId, 
        challenge.requirements, 
        updatedProgress.progress
      );

      if (badge != null) {
        // Show badge earned notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Congratulations! You earned the ${badge.badgeName} badge!'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to rewards screen
                Navigator.pushNamed(context, '/rewards');
              },
            ),
          ),
        );
      }

      // Refresh challenges
      await _loadChallenges();
    } catch (e) {
      print('Error updating progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update progress. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Challenges'),
            Tab(text: 'Upcoming Challenges'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveChallengesTab(),
                _buildUpcomingChallengesTab(),
              ],
            ),
    );
  }

  Widget _buildActiveChallengesTab() {
    if (_activeChallenges.isEmpty) {
      return const Center(
        child: Text(
          'No active challenges at the moment.\nCheck back soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _activeChallenges[index];
          final progress = _userProgress[challenge.id];
          return _buildChallengeCard(challenge, progress);
        },
      ),
    );
  }

  Widget _buildUpcomingChallengesTab() {
    if (_upcomingChallenges.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming challenges at the moment.\nCheck back soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _upcomingChallenges[index];
          return _buildUpcomingChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge, ChallengeProgressModel? progress) {
    final bool isCompleted = progress?.isCompleted ?? false;
    final bool badgeAwarded = progress?.badgeAwarded ?? false;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getChallengeTypeColors(challenge.challengeType),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (badgeAwarded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: _getPrimaryColor(challenge.challengeType),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Ends on ${_formatDate(challenge.endDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Requirements:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildRequirementsList(challenge, progress),
            const SizedBox(height: 16),
            if (!isCompleted) _buildProgressActions(challenge, progress),
            if (isCompleted && !badgeAwarded)
              const Center(
                child: Text(
                  'Challenge completed! Badge will be awarded soon.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            if (badgeAwarded)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/rewards');
                  },
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('View Your Badge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _getPrimaryColor(challenge.challengeType),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingChallengeCard(ChallengeModel challenge) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getPrimaryColor(challenge.challengeType),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPrimaryColor(challenge.challengeType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    challenge.challengeType.toUpperCase(),
                    style: TextStyle(
                      color: _getPrimaryColor(challenge.challengeType),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(challenge.description),
            const SizedBox(height: 16),
            Text(
              'Starts on ${_formatDate(challenge.startDate)}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Ends on ${_formatDate(challenge.endDate)}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      challenge.badgeImagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge: ${challenge.badgeName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        challenge.badgeDescription,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRequirementsList(ChallengeModel challenge, ChallengeProgressModel? progress) {
    final List<Widget> widgets = [];
    final requirements = challenge.requirements;
    final userProgress = progress?.progress ?? {};

    requirements.forEach((key, requiredValue) {
      final currentValue = userProgress[key] ?? 0;
      final double progressPercent = currentValue / requiredValue;
      final bool isCompleted = currentValue >= requiredValue;

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatRequirementKey(key),
                    style: TextStyle(
                      color: Colors.white,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  '$currentValue / $requiredValue',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });

    return widgets;
  }

  Widget _buildProgressActions(ChallengeModel challenge, ChallengeProgressModel? progress) {
    // This is a simplified example. In a real app, you would have specific actions
    // based on the challenge type and requirements.
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Show dialog to update progress
          _showUpdateProgressDialog(challenge, progress);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _getPrimaryColor(challenge.challengeType),
        ),
        child: const Text('Update Progress'),
      ),
    );
  }

  void _showUpdateProgressDialog(ChallengeModel challenge, ChallengeProgressModel? progress) {
    if (progress == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final requirements = Map<String, dynamic>.from(challenge.requirements);
        final currentProgress = Map<String, dynamic>.from(progress.progress);
        final Map<String, TextEditingController> controllers = {};

        // Create controllers for each requirement
        requirements.forEach((key, value) {
          controllers[key] = TextEditingController(
            text: (currentProgress[key] ?? 0).toString(),
          );
        });

        return AlertDialog(
          title: Text('Update ${challenge.title} Progress'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: requirements.entries.map((entry) {
                final key = entry.key;
                final requiredValue = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controllers[key],
                    decoration: InputDecoration(
                      labelText: '${_formatRequirementKey(key)} (Required: $requiredValue)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update progress for each requirement
                controllers.forEach((key, controller) {
                  final newValue = int.tryParse(controller.text) ?? 0;
                  _updateProgress(challenge.id, key, newValue);
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatRequirementKey(String key) {
    // Convert camelCase or snake_case to readable text
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .capitalize();
  }

  List<Color> _getChallengeTypeColors(String challengeType) {
    if (challengeType == 'weekly') {
      return [Colors.teal.shade300, Colors.teal.shade700];
    } else {
      return [Colors.amber.shade300, Colors.amber.shade700];
    }
  }

  Color _getPrimaryColor(String challengeType) {
    if (challengeType == 'weekly') {
      return Colors.teal.shade700;
    } else {
      return Colors.amber.shade700;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}