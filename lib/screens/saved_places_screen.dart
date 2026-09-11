import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import '../features/places/places_provider.dart';
import '../shared/models/place.dart';
import '../shared/widgets/cards.dart';
import '../theme/app_theme.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PlacesProvider>(
      builder: (context, auth, placesProvider, _) {
        final savedPlaces = placesProvider.savedPlaces;
        
        if (!auth.isAuthenticated) {
          return _buildGuestView(context);
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Places'),
            actions: [
              if (savedPlaces.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  onPressed: () => _showClearAllDialog(context, placesProvider),
                ),
            ],
          ),
          body: savedPlaces.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = savedPlaces[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(place.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => placesProvider.toggleBookmark(place),
                        child: PlaceCard(
                          place: place,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/place-detail',
                            arguments: place,
                          ),
                          onBookmark: () => placesProvider.toggleBookmark(place),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Places')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign in to save places',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your bookmarks will sync across devices',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved places yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any place to save it here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, PlacesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all saved places?'),
        content: const Text('This will remove all bookmarks. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              for (final place in provider.savedPlaces) {
                provider.toggleBookmark(place);
              }
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}