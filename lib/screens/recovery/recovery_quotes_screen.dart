import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'dart:math';

class RecoveryQuotesScreen extends StatefulWidget {
  const RecoveryQuotesScreen({super.key});

  @override
  State<RecoveryQuotesScreen> createState() => _RecoveryQuotesScreenState();
}

class _RecoveryQuotesScreenState extends State<RecoveryQuotesScreen> {
  int _currentQuoteIndex = 0;
  final PageController _pageController = PageController();

  final List<RecoveryQuote> _quotes = [
    RecoveryQuote(
      text:
          "Recovery is not a race. You don't have to feel guilty if it takes you longer than you thought it would.",
      author: "Unknown",
      category: "Self-Compassion",
      color: Colors.blue,
    ),
    RecoveryQuote(
      text:
          "The strongest people are not those who show strength in front of us, but those who win battles we know nothing about.",
      author: "Unknown",
      category: "Strength",
      color: Colors.purple,
    ),
    RecoveryQuote(
      text:
          "You are not your mistakes. You are not your struggles. You are here now with the power to shape your day and your future.",
      author: "Steve Maraboli",
      category: "Self-Worth",
      color: Colors.green,
    ),
    RecoveryQuote(
      text:
          "Progress, not perfection. Every small step forward is a victory worth celebrating.",
      author: "Unknown",
      category: "Progress",
      color: Colors.orange,
    ),
    RecoveryQuote(
      text: "The cave you fear to enter holds the treasure you seek.",
      author: "Joseph Campbell",
      category: "Courage",
      color: Colors.teal,
    ),
    RecoveryQuote(
      text:
          "Healing doesn't mean the damage never existed. It means the damage no longer controls our lives.",
      author: "Akshay Dubey",
      category: "Healing",
      color: Colors.pink,
    ),
    RecoveryQuote(
      text:
          "You have been assigned this mountain to show others it can be moved.",
      author: "Mel Robbins",
      category: "Purpose",
      color: Colors.indigo,
    ),
    RecoveryQuote(
      text:
          "Recovery is an acceptance that your life is in shambles and you have to change it.",
      author: "Jamie Lee Curtis",
      category: "Acceptance",
      color: Colors.red,
    ),
    RecoveryQuote(
      text: "The only way out is through. Keep going, even when it's hard.",
      author: "Robert Frost",
      category: "Perseverance",
      color: Colors.cyan,
    ),
    RecoveryQuote(
      text:
          "You are braver than you believe, stronger than you seem, and more loved than you know.",
      author: "A.A. Milne",
      category: "Self-Love",
      color: Colors.amber,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentQuoteIndex = Random().nextInt(_quotes.length);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Recovery Quotes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: AppColors.primary),
            onPressed: _shuffleQuote,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuoteIndex = index;
                  });
                },
                itemCount: _quotes.length,
                itemBuilder: (context, index) {
                  return _buildQuoteCard(_quotes[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(RecoveryQuote quote) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  quote.color,
                  quote.color.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: quote.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  quote.text,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  '— ${quote.author}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quote.category,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _quotes.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentQuoteIndex ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentQuoteIndex
                      ? _quotes[_currentQuoteIndex].color
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _previousQuote,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'Previous',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextQuote,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    'Next',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _quotes[_currentQuoteIndex].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Daily quote button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDailyQuote,
              icon: const Icon(Icons.today_rounded),
              label: Text(
                'Get Daily Quote',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousQuote() {
    if (_currentQuoteIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuote() {
    if (_currentQuoteIndex < _quotes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _shuffleQuote() {
    final newIndex = Random().nextInt(_quotes.length);
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showDailyQuote() {
    // Get today's quote based on day of year
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final dailyQuoteIndex = dayOfYear % _quotes.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.today_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Today\'s Quote',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _quotes[dailyQuoteIndex].text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '— ${_quotes[dailyQuoteIndex].author}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pageController.animateToPage(
                dailyQuoteIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Text('View Full'),
          ),
        ],
      ),
    );
  }
}

class RecoveryQuote {
  final String text;
  final String author;
  final String category;
  final Color color;

  RecoveryQuote({
    required this.text,
    required this.author,
    required this.category,
    required this.color,
  });
}
