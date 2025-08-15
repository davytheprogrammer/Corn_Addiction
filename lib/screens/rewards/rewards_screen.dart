import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/streak_milestone_model.dart';
import '../../models/challenge_badge_model.dart';
import '../../models/user_model.dart';
import '../../services/rewards_service.dart';
import '../../widgets/streak_milestone_card.dart';
import '../../widgets/challenge_badge_card.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/rewards_provider.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<StreakMilestoneModel> _milestones = [];
  List<ChallengeBadgeModel> _badges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserRewards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRewards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final rewardsService = ref.read(rewardsServiceProvider);
        final milestones = await rewardsService.getUserStreakMilestones(user.uid);
        final badges = await rewardsService.getUserBadges(user.uid);

        setState(() {
          _milestones = milestones;
          _badges = badges;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rewards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _claimMilestoneReward(StreakMilestoneModel milestone) async {
    try {
      final rewardsService = ref.read(rewardsServiceProvider);
      await rewardsService.claimMilestoneReward(milestone.id);
      
      // Refresh the rewards list
      _loadUserRewards();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward claimed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      debugPrint('Error claiming reward: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim reward'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _toggleBadgeDisplay(ChallengeBadgeModel badge) async {
    try {
      final rewardsService = ref.read(rewardsServiceProvider);
      await rewardsService.toggleBadgeDisplay(badge.id, !badge.isDisplayed);
      
      // Refresh the rewards list
      _loadUserRewards();
    } catch (e) {
      debugPrint('Error toggling badge display: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update badge display'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMilestonesTab() {
    if (_milestones.isEmpty) {
      return const Center(child: Text('No streak milestones yet. Keep going!'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _milestones.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StreakMilestoneCard(
            milestone: _milestones[index],
            onClaimReward: () => _claimMilestoneReward(_milestones[index]),
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab() {
    if (_badges.isEmpty) {
      return const Center(child: Text('No badges earned yet. Complete challenges to earn badges!'));
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadUserRewards(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          return ChallengeBadgeCard(
            badge: badge,
            onToggleDisplay: () => _toggleBadgeDisplay(badge),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Achievements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Streak Milestones'),
            Tab(text: 'Challenge Badges'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMilestonesTab(),
                _buildBadgesTab(),
              ],
            ),
    );
  }
}