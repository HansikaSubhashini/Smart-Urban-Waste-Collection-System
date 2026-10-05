import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';

/// Screen where a resident can submit feedback for a driver.
class ResidentFeedbackScreen extends StatefulWidget {
  const ResidentFeedbackScreen({super.key});

  @override
  State<ResidentFeedbackScreen> createState() => _ResidentFeedbackScreenState();
}

class _ResidentFeedbackScreenState extends State<ResidentFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();

  int _selectedRating = 0;
  String _selectedCategory = 'service';
  String? _selectedDriverId;
  String? _selectedDriverName;
  bool _isSubmitting = false;
  bool _isLoadingDrivers = true;

  List<Map<String, String>> _drivers = [];

  final List<Map<String, dynamic>> _categories = [
    {'value': 'punctuality', 'label': 'Punctuality', 'emoji': '⏰', 'desc': 'On-time arrivals'},
    {'value': 'cleanliness', 'label': 'Cleanliness', 'emoji': '🧹', 'desc': 'Neat & tidy collection'},
    {'value': 'behavior', 'label': 'Behavior', 'emoji': '🤝', 'desc': 'Professional conduct'},
    {'value': 'service', 'label': 'Overall Service', 'emoji': '⭐', 'desc': 'General performance'},
    {'value': 'other', 'label': 'Other', 'emoji': '💬', 'desc': 'Any other feedback'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      final drivers = await _feedbackService.getAvailableDrivers();
      if (mounted) {
        setState(() {
          _drivers = drivers;
          _isLoadingDrivers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading drivers: $e');
      if (mounted) setState(() => _isLoadingDrivers = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedDriverId == null) {
      _showMessage('Please select a driver.', isError: true);
      return;
    }
    if (_selectedRating == 0) {
      _showMessage('Please give a star rating.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _authService.currentUser;
      final feedback = DriverFeedback(
        id: '',
        driverId: _selectedDriverId!,
        driverName: _selectedDriverName ?? '',
        residentId: user?.uid ?? '',
        residentName: user?.name ?? 'Anonymous',
        area: user?.address ?? 'Colombo',
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        category: _selectedCategory,
      );

      await _feedbackService.submitFeedback(feedback);

      if (mounted) {
        _showMessage('Thank you! Your feedback has been submitted.', isError: false);
        // Reset form
        setState(() {
          _selectedRating = 0;
          _selectedCategory = 'service';
          _selectedDriverId = null;
          _selectedDriverName = null;
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to submit: ${e.toString().replaceFirst("Exception: ", "")}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.feedback, color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Give Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Illustration ───
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // ─── Select Driver ───
            _buildSectionLabel('SELECT DRIVER', Icons.local_shipping_outlined),
            const SizedBox(height: 10),
            _buildDriverSelector(),
            const SizedBox(height: 24),

            // ─── Star Rating ───
            _buildSectionLabel('RATE YOUR EXPERIENCE', Icons.star_outline),
            const SizedBox(height: 10),
            _buildStarRating(),
            const SizedBox(height: 24),

            // ─── Category ───
            _buildSectionLabel('FEEDBACK CATEGORY', Icons.category_outlined),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 24),

            // ─── Comment ───
            _buildSectionLabel('YOUR COMMENTS (OPTIONAL)', Icons.edit_outlined),
            const SizedBox(height: 10),
            _buildCommentField(),
            const SizedBox(height: 32),

            // ─── Submit Button ───
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.rate_review, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Your Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Help us improve by rating your waste collection driver.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textLight, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverSelector() {
    if (_isLoadingDrivers) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2),
          ),
        ),
      );
    }

    if (_drivers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: const Center(
          child: Text(
            'No drivers available at the moment.',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedDriverId != null
              ? AppTheme.primaryGreen.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: _selectedDriverId != null ? 2 : 1,
        ),
      ),
      child: Column(
        children: _drivers.asMap().entries.map((entry) {
          final index = entry.key;
          final driver = entry.value;
          final isSelected = _selectedDriverId == driver['id'];
          final isLast = index == _drivers.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedDriverId = driver['id'];
                    _selectedDriverName = driver['name'];
                  });
                },
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected
                            ? AppTheme.primaryGreen.withOpacity(0.1)
                            : AppTheme.lightBlueBackground,
                        child: Icon(
                          Icons.person,
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.darkGreen : AppTheme.textDark,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Zone: ${driver['zone']} • Truck: ${driver['truckId']}',
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast) Divider(height: 1, indent: 60, color: Colors.grey.withOpacity(0.1)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStarRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedRating > 0
              ? const Color(0xFFFFD54F).withOpacity(0.5)
              : Colors.grey.withOpacity(0.15),
          width: _selectedRating > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: _selectedRating >= starIndex ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _selectedRating >= starIndex
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: _selectedRating >= starIndex
                          ? const Color(0xFFFFB300)
                          : Colors.grey.shade300,
                      size: 44,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 10),
            Text(
              _getRatingLabel(_selectedRating),
              style: TextStyle(
                color: _getRatingColor(_selectedRating),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return '😞 Poor';
      case 2:
        return '😐 Below Average';
      case 3:
        return '🙂 Good';
      case 4:
        return '😊 Very Good';
      case 5:
        return '🌟 Excellent!';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF22C55E);
      case 5:
        return const Color(0xFF059669);
      default:
        return AppTheme.textLight;
    }
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cat['emoji'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  cat['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Share your experience in detail...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: const TextStyle(color: AppTheme.textLight, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isReady = _selectedDriverId != null && _selectedRating > 0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isReady && !_isSubmitting) ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: isReady ? 4 : 0,
          shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: isReady ? Colors.white : Colors.grey.shade500,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Feedback',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isReady ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
