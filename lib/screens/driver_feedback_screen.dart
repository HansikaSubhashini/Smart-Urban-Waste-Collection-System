import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';

/// Screen where the driver can view all feedback received from residents.
class DriverFeedbackScreen extends StatefulWidget {
  const DriverFeedbackScreen({super.key});

  @override
  State<DriverFeedbackScreen> createState() => _DriverFeedbackScreenState();
}

class _DriverFeedbackScreenState extends State<DriverFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final AuthService _authService = AuthService();

  double _averageRating = 0.0;
  int _totalFeedback = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final driverId = _authService.currentUser?.uid ?? '';
    if (driverId.isEmpty) return;

    try {
      final avg = await _feedbackService.getDriverAverageRating(driverId);
      final count = await _feedbackService.getDriverFeedbackCount(driverId);
      if (mounted) {
        setState(() {
          _averageRating = avg;
          _totalFeedback = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading feedback stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rate_review, color: Color(0xFFFF8F00), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'My Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.darkGreen),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ─── Rating Summary Card ───
          _buildRatingSummaryCard(),
          const SizedBox(height: 20),

          // ─── Section Header ───
          const Row(
            children: [
              Icon(Icons.forum_outlined, color: AppTheme.textLight, size: 18),
              SizedBox(width: 8),
              Text(
                'RECENT FEEDBACK',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── Feedback List ───
          _buildFeedbackList(driverId),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRatingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF006B56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGreen.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average rating circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '—',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '/ 5.0',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalFeedback ${_totalFeedback == 1 ? 'review' : 'reviews'} from residents',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                // Star display
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < _averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xFFFFD54F),
                      size: 22,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(String driverId) {
    if (driverId.isEmpty) {
      return _buildEmptyState();
    }

    return StreamBuilder<List<DriverFeedback>>(
      stream: _feedbackService.getDriverFeedbackStream(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final feedbackList = snapshot.data ?? [];

        if (feedbackList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: feedbackList.map((fb) => _buildFeedbackCard(fb)).toList(),
        );
      },
    );
  }

  Widget _buildFeedbackCard(DriverFeedback feedback) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(feedback.createdAt);
    final emoji = DriverFeedback.categoryIcon(feedback.category);

    // Color based on rating
    Color ratingColor;
    if (feedback.rating >= 4) {
      ratingColor = const Color(0xFF22C55E);
    } else if (feedback.rating >= 3) {
      ratingColor = const Color(0xFFFF8F00);
    } else {
      ratingColor = const Color(0xFFEF4444);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Resident info
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.lightBlueBackground,
                    child: Text(
                      feedback.residentName.isNotEmpty
                          ? feedback.residentName[0].toUpperCase()
                          : 'R',
                      style: const TextStyle(
                        color: AppTheme.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.residentName.isNotEmpty
                            ? feedback.residentName
                            : 'Resident',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: ratingColor, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${feedback.rating}.0',
                      style: TextStyle(
                        color: ratingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Category chip
          if (feedback.category.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    feedback.displayCategory,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Comment
          if (feedback.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.08)),
              ),
              child: Text(
                feedback.comment,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Area tag
          if (feedback.area.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 14),
                const SizedBox(width: 4),
                Text(
                  feedback.area,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00).withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(Icons.rate_review_outlined, color: Color(0xFFFF8F00), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Feedback Yet',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Feedback from residents will appear here\nonce they submit their reviews.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 32),
          const SizedBox(height: 12),
          const Text(
            'Unable to load feedback',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
