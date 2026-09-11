import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import '../features/places/places_provider.dart';
import '../core/services/supabase_service.dart';
import '../shared/services/data_service.dart';
import '../shared/models/place.dart';
import '../shared/widgets/optimized_image.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingTrips = false;
  List<UserTrip> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    setState(() => _isLoadingTrips = true);
    try {
      // Trips would be loaded from Supabase in real implementation
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) setState(() => _isLoadingTrips = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PlacesProvider>(
      builder: (context, auth, placesProvider, _) {
        final user = auth.user;
        final savedCount = placesProvider.savedPlaces.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (auth.isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () => _showSettings(context),
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              // Profile header
              SliverToBoxAdapter(
                child: _buildProfileHeader(context, user, savedCount),
              ),
              // Stats
              SliverToBoxAdapter(
                child: _buildStatsRow(context, savedCount),
              ),
              // My Trips
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, 'My Trips', onTapAll: () => _createTrip(context)),
              ),
              _buildTripsSection(context),
              // Settings
              SliverToBoxAdapter(
                child: _buildSettingsSection(context, auth),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, int savedCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: user?.userMetadata['avatar_url'] != null
                ? NetworkImage(user!.userMetadata['avatar_url'])
                : null,
            child: user?.userMetadata['avatar_url'] == null
                ? Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'G',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            user?.userMetadata['full_name'] ?? user?.email?.split('@').first ?? 'Guest User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // Email/Provider
          if (user != null)
            Text(
              user.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),
          // Saved count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$savedCount saved place${savedCount != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int savedCount) {
    final stats = [
      ('Saved', savedCount.toString(), Icons.bookmark_rounded),
      ('Trips', _trips.length.toString(), Icons.route_rounded),
      ('Visited', '0', Icons.check_circle_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: stats.map((stat) => Expanded(
          child: _StatCard(
            label: stat.$1,
            value: stat.$2,
            icon: stat.$3,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onTapAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onTapAll != null)
            TextButton.icon(
              onPressed: onTapAll,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Trip'),
            ),
        ],
      ),
    );
  }

  Widget _buildTripsSection(BuildContext context) {
    if (_isLoadingTrips) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      );
    }
    if (_trips.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Card(
            child: InkWell(
              onTap: () => _createTrip(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Create your first trip', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Plan itineraries with multiple destinations', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final trip = _trips[index];
          return _TripCard(trip: trip);
        },
        childCount: _trips.length,
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider auth) {
    final settings = [
      if (auth.isAuthenticated) ...[
        ('Account', Icons.person_rounded, () {}),
        ('Sync Data', Icons.sync_rounded, () => _syncData(context)),
        ('Sign Out', Icons.logout_rounded, () => auth.signOut()),
      ] else ...[
        ('Sign In', Icons.login_rounded, () => Navigator.pushNamed(context, '/auth')),
      ],
      ('About', Icons.info_rounded, () => _showAbout(context)),
      ('Privacy Policy', Icons.privacy_tip_rounded, () {}),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: settings.map((s) => ListTile(
                leading: Icon(s.$2, color: Theme.of(context).colorScheme.primary),
                title: Text(s.$1),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: s.$3,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _createTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateTripDialog(onCreate: _loadTrips),
    );
  }

  Future<void> _syncData(BuildContext context) async {
    final dataService = context.read<DataService>();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing...')));
    await dataService.syncWithCloud();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synced successfully')));
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Nadodi',
      applicationVersion: '2.1.0',
      applicationIcon: const Icon(Icons.landscape_rounded, size: 48, color: Color(0xFF006D5B)),
      children: [
        const Text('Kerala Tourism Explorer'),
        const SizedBox(height: 16),
        const Text('Discover hidden gems, plan trips, and explore Kerala like never before.'),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    // Navigate to settings screen
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final UserTrip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.route_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(trip.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('${trip.placeIds.length} places • ${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

class _CreateTripDialog extends StatefulWidget {
  final VoidCallback onCreate;

  const _CreateTripDialog({required this.onCreate});

  @override
  State<_CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<_CreateTripDialog> {
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 10));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Trip Name', hintText: 'Kerala Adventure'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (date != null) setState(() => _startDate = date);
            },
          ),
          ListTile(
            title: const Text('End Date'),
            subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime.now().add(const Duration(days: 365)));
              if (date != null) setState(() => _endDate = date);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              // Create trip in Supabase
              widget.onCreate();
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}