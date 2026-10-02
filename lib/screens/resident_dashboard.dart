import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/collection_service.dart';
import '../models/collection_model.dart';

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  final CollectionService _collectionService = CollectionService();
  final AuthService _auth = AuthService();

  CollectionSchedule? _nextCollection;
  CollectionSchedule? _lastCollection;
  bool _geoFenceEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Try to find next collection for any area (demo uses Bambalapitiya)
      final next = await _collectionService.getNextCollection('Bambalapitiya');
      if (mounted) {
        setState(() {
          _nextCollection = next;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading resident data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(
              'EcoTrack Colombo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Welcome, ${user.name}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            _buildNextCollectionCard(),
            const SizedBox(height: 16),
            _buildSmartETACard(),
            const SizedBox(height: 16),
            _buildGeoFenceCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View History',
                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentActivityStream(),
            const SizedBox(height: 16),
            _buildMapPlaceholder(),
            const SizedBox(height: 16),
            _buildMissedCollectionCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNextCollectionCard() {
    String dateStr = 'Loading...';
    String typeStr = 'General Waste';
    String locationStr = 'Your Area';

    if (!_isLoading && _nextCollection != null) {
      dateStr = DateFormat('EEEE, MMM d').format(_nextCollection!.scheduledDate);
      typeStr = _nextCollection!.displayType;
      locationStr = _nextCollection!.area;
    } else if (!_isLoading) {
      dateStr = 'No upcoming collection';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT COLLECTION',
            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  locationStr,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collection Type',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    typeStr,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You\'re ready for collection!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("I'm Ready", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartETACard() {
    String etaWindow = '7:45 AM - 8:05 AM';
    if (_nextCollection != null) {
      final time = _nextCollection!.scheduledDate;
      final start = DateFormat('h:mm a').format(time);
      final end = DateFormat('h:mm a').format(time.add(const Duration(minutes: 20)));
      etaWindow = '$start - $end';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightBlueBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: AppTheme.primaryGreen),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HIGH ACCURACY ML',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Smart ETA',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            etaWindow,
            style: const TextStyle(color: Color(0xFF1976D2), fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Predicted arrival window based on current route traffic.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGeoFenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.gps_fixed, color: AppTheme.textDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Geo-fence Alerts',
                  style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notify me when the truck is within ${_auth.currentUser?.alertProximity ?? "500m"} of my home.',
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: _geoFenceEnabled,
            onChanged: (val) {
              setState(() => _geoFenceEnabled = val);
            },
            activeColor: AppTheme.darkGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityStream() {
    return StreamBuilder<List<CollectionSchedule>>(
      stream: _collectionService.getResidentHistory('Bambalapitiya'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ));
        }

        final collections = snapshot.data ?? [];
        final completed = collections.where((c) => c.status == 'completed').toList();

        if (completed.isEmpty) {
          return _buildRecentActivityItem('No recent collections', '');
        }

        final last = completed.first;
        final timeStr = DateFormat('h:mm a EEEE').format(last.scheduledDate);

        return _buildRecentActivityItem('Last collection successful', timeStr);
      },
    );
  }

  Widget _buildRecentActivityItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=Colombo&zoom=13&size=600x300&maptype=roadmap&key=PLACEHOLDER'),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text(
            'Truck is en route',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedCollectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missed a collection?',
                  style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Report issues directly to CMC',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
