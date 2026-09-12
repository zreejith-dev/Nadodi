import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/places/places_provider.dart';
import '../features/hidden/hidden_provider.dart'
    hide HiddenSpotsProvider;
import '../shared/services/data_service.dart';
import '../shared/models/place.dart';
import '../shared/widgets/cards.dart';
import '../shared/widgets/optimized_image.dart';
import 'place_detail_screen.dart';
import 'hidden_places_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlacesProvider, HiddenSpotsProvider>(
      builder: (context, placesProvider, hiddenProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(context, placesProvider),
          body: placesProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, placesProvider, hiddenProvider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/map'),
            icon: const Icon(Icons.map_rounded),
            label: const Text('Map View'),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, PlacesProvider provider) {
    return AppBar(
      title: Text(
        'Nadodi',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => _showSearchBottomSheet(context, provider),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_rounded),
          onPressed: () => Navigator.pushNamed(context, '/saved'),
        ),
        IconButton(
          icon: const Icon(Icons.person_rounded),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PlacesProvider provider, hiddenProvider) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildSearchField(context, provider),
          ),
        ),
        // Categories
        SliverToBoxAdapter(
          child: _buildCategoryChips(context, provider),
        ),
        // Featured places
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            context,
            'Featured Places',
            onTapAll: () => _navigateToFiltered(context, provider, category: provider.categories.first),
          ),
        ),
        _buildPlacesList(context, provider.filteredPlaces.take(10).toList()),
        // Nearby hidden spots
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            context,
            'Hidden Gems',
            onTapAll: () => Navigator.pushNamed(context, '/hidden'),
          ),
        ),
        _buildHiddenSpotsList(context, hiddenProvider.filteredSpots.take(5).toList()),
        // Quick actions
        SliverToBoxAdapter(
          child: _buildQuickActions(context),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // FAB space
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, PlacesProvider provider) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search places, districts...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  setState(() => _searchQuery = '');
                  provider.clearFilters();
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
        provider.setSearchQuery(value);
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context, PlacesProvider provider) {
    final theme = Theme.of(context);
    final categories = ['All', ...provider.categories];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = provider.selectedCategory == category || (category == 'All' && provider.selectedCategory.isEmpty);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                if (category == 'All') {
                  provider.clearFilters();
                } else {
                  provider.setCategory(category);
                }
              },
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onTapAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onTapAll != null)
            TextButton(onPressed: onTapAll, child: const Text('View All')),
        ],
      ),
    );
  }

  Widget _buildPlacesList(BuildContext context, List<TouristPlace> places) {
    if (places.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No places found')),
      );
    }
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PlaceCard(
                place: place,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/place-detail',
                  arguments: place,
                ),
                onBookmark: () => context.read<PlacesProvider>().toggleBookmark(place),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHiddenSpotsList(BuildContext context, List<HiddenSpot> spots) {
    if (spots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No hidden spots')),
      );
    }
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: spots.length,
        itemBuilder: (context, index) {
          final spot = spots[index];
          return SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: HiddenSpotCard(
                spot: spot,
                onTap: () => Navigator.pushNamed(context, '/hidden'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ('Plan a Trip', Icons.route_rounded, () => Navigator.pushNamed(context, '/profile')),
      ('Nearby Places', Icons.near_me_rounded, () => Navigator.pushNamed(context, '/map')),
      ('Hidden Gems', Icons.diamond_rounded, () => Navigator.pushNamed(context, '/hidden')),
      ('Saved Places', Icons.bookmark_rounded, () => Navigator.pushNamed(context, '/saved')),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: actions.map((action) => _QuickActionCard(
          title: action.$1,
          icon: action.$2,
          onTap: action.$3,
        )).toList(),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context, PlacesProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchBottomSheet(provider: provider),
    );
  }

  void _navigateToFiltered(BuildContext context, PlacesProvider provider, {String? category}) {
    // Navigate to a filtered view or just show filtered results
    provider.setCategory(category ?? '');
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBottomSheet extends StatefulWidget {
  final PlacesProvider provider;

  const _SearchBottomSheet({required this.provider});

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search places, districts...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          widget.provider.clearFilters();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                widget.provider.setSearchQuery(value);
                setState(() {});
              },
            ),
          ),
          // Results
          Expanded(
            child: Consumer<PlacesProvider>(
              builder: (context, provider, _) {
                final results = provider.filteredPlaces;
                if (results.isEmpty) {
                  return const Center(child: Text('No results found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final place = results[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: OptimizedImage(
                          imageUrl: place.imageUrl,
                          width: 50,
                          height: 50,
                          cacheWidth: 100,
                          cacheHeight: 100,
                        ),
                      ),
                      title: Text(place.name),
                      subtitle: Text('${place.category} • ${place.district}'),
                      trailing: Icon(
                        place.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: place.isSaved ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/place-detail',
                          arguments: place,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}