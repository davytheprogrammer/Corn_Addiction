import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:lottie/lottie.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  final List<RecoveryTool> _tools = [
    RecoveryTool(
      title: 'Guided Breathing',
      description: 'Manage urges with deep breathing exercises',
      icon: Icons.air_rounded,
      color: const Color(0xFF4CAF50),
      route: '/breathing',
      isLocked: false,
    ),
    RecoveryTool(
      title: 'Mindfulness Meditation',
      description: 'Stay present and calm your mind',
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFF5C6BC0),
      route: '/meditation',
      isLocked: false,
    ),
    RecoveryTool(
      title: 'Urge Surfing',
      description: 'Learn to ride out urges without giving in',
      icon: Icons.waves_rounded,
      color: const Color(0xFF26A69A),
      route: '/urge-surfing',
      isLocked: false,
    ),
    RecoveryTool(
      title: 'Emergency Button',
      description: 'Quick help when you need it most',
      icon: Icons.emergency_rounded,
      color: const Color(0xFFEF5350),
      route: '/emergency',
      isLocked: false,
      isHighlighted: true,
    ),
    RecoveryTool(
      title: 'Recovery Journal',
      description: 'Track thoughts and feelings about your journey',
      icon: Icons.book_rounded,
      color: const Color(0xFF7E57C2),
      route: '/journal',
      isLocked: false,
    ),
    RecoveryTool(
      title: 'Healthy Habits',
      description: 'Build activities to replace your addiction',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFFFFB74D),
      route: '/habits',
      isLocked: true,
    ),
    RecoveryTool(
      title: 'AI Recovery Coach',
      description: 'Get personalized guidance and advice',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF42A5F5),
      route: '/ai-coach',
      isLocked: true,
      comingSoon: true,
    ),
    RecoveryTool(
      title: 'Trigger Action Planning',
      description: 'Create plans to handle high-risk situations',
      icon: Icons.engineering_rounded,
      color: const Color(0xFF78909C),
      route: '/trigger-planning',
      isLocked: true,
    ),
  ];

  final List<Article> _articles = [
    Article(
      title: 'Understanding Addiction and Recovery',
      category: 'Education',
      imageUrl: 'assets/images/understanding_addiction.jpg',
      estimatedReadTime: 5,
      route: '/articles/understanding-addiction',
    ),
    Article(
      title: 'How to Handle a Relapse',
      category: 'Recovery',
      imageUrl: 'assets/images/handling_relapse.jpg',
      estimatedReadTime: 4,
      route: '/articles/handling-relapse',
    ),
    Article(
      title: 'The Science of Dopamine and Addiction',
      category: 'Science',
      imageUrl: 'assets/images/dopamine_science.jpg',
      estimatedReadTime: 7,
      route: '/articles/dopamine-science',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recovery Tools',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Refresh logic here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmergencyCard(),
              const SizedBox(height: 24),
              _buildToolsGrid(),
              const SizedBox(height: 24),
              _buildArticlesSection(),
              const SizedBox(height: 24),
              _buildCommunitySupport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFFFBE9E7),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Having a Crisis?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get immediate help with our emergency tools',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red[700]!.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tools & Techniques',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Resources to help you overcome urges',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _tools.length,
          itemBuilder: (context, index) {
            final tool = _tools[index];
            return _buildToolCard(tool);
          },
        ),
      ],
    );
  }

  Widget _buildToolCard(RecoveryTool tool) {
    return Card(
      elevation: tool.isHighlighted ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: tool.isHighlighted
            ? BorderSide(
                color: tool.color.withOpacity(0.5),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (tool.isLocked) {
            _showUnlockFeatureDialog(tool);
          } else {
            // Navigate to tool screen
            // Navigator.pushNamed(context, tool.route);
            
            // Temporary placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${tool.title} feature coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tool.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tool.icon,
                      color: tool.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tool.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      tool.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (tool.isLocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.grey[700],
                    size: 16,
                  ),
                ),
              ),
            if (tool.comingSoon ?? false)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'COMING SOON',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learn & Improve',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to articles page
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Educational content for your recovery journey',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final article = _articles[index];
            return _buildArticleCard(article);
          },
        ),
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to article
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Article "${article.title}" coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Use a placeholder since we don't have the actual images
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.article_rounded,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.estimatedReadTime} min read',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunitySupport() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Support',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re not alone in this journey',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSupportOption(
                    'Join Forums',
                    'Connect with others who understand',
                    Icons.forum_rounded,
                    Colors.purple[300]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSupportOption(
                    'Find Support Groups',
                    'Local and online meetings',
                    Icons.groups_rounded,
                    Colors.teal[300]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to support option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About Recovery Tools',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These tools are designed to help you overcome addiction and stay on your recovery path.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              Text(
                'If you\'re experiencing a crisis:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                'Use the Emergency Button for immediate help',
                Icons.emergency,
              ),
              _buildInfoItem(
                'Try guided breathing to manage urges',
                Icons.air,
              ),
              _buildInfoItem(
                'Reach out to your support network',
                Icons.people,
              ),
              const SizedBox(height: 16),
              Text(
                'Premium features can be unlocked in the settings.',
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockFeatureDialog(RecoveryTool tool) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: tool.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tool.icon,
                  size: 64,
                  color: tool.color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unlock ${tool.title}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This feature is available with our premium plan, which includes:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildPremiumFeature('Access to all recovery tools'),
              _buildPremiumFeature('Advanced progress tracking'),
              _buildPremiumFeature('AI-powered recovery coach'),
              _buildPremiumFeature('Ad-free experience'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to premium plans
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Premium plans coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Premium Plans',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecoveryTool {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final bool isLocked;
  final bool isHighlighted;
  final bool? comingSoon;

  RecoveryTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.isLocked = false,
    this.isHighlighted = false,
    this.comingSoon,
  });
}

class Article {
  final String title;
  final String category;
  final String imageUrl;
  final int estimatedReadTime;
  final String route;

  Article({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.estimatedReadTime,
    required this.route,
  });
}
