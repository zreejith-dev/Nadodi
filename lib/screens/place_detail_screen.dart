import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../features/places/places_provider.dart';
import '../shared/models/place.dart';
import '../shared/widgets/optimized_image.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TouristPlace place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final MapController _mapController = MapController();
  late TouristPlace _place;

  @override
  void initState() {
    super.initState();
    _place = widget.place;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesProvider>(
      builder: (context, provider, _) {
        // Update local place if bookmarked state changed
        final updated = provider.places.firstWhere(
          (p) => p.id == _place.id,
          orElse: () => _place,
        );
        if (updated != _place) _place = updated;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero image with app bar
              _buildSliverAppBar(context),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildDescription(context),
                      const SizedBox(height: 24),
                      _buildDetailsRow(context),
                      const SizedBox(height: 24),
                      _buildMapSection(context),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'place-${_place.id}',
              child: OptimizedImage(
                imageUrl: _place.imageUrl,
                fit: BoxFit.cover,
                cacheWidth: 800,
                cacheHeight: 600,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Category badge
            Positioned(
              bottom: 80,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _place.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _place.name,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _place.district,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Rating + Bookmark
        Row(
          children: [
            _buildRating(context),
            const SizedBox(width: 12),
            _buildBookmarkButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            _place.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<PlacesProvider>().toggleBookmark(_place),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _place.isSaved ? Icons.bookmark : Icons.bookmark_outline,
            color: _place.isSaved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (_place.description == null || _place.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          _place.description!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow(BuildContext context) {
    return Row(
      children: [
        _DetailChip(icon: Icons.category_rounded, label: _place.category),
        const SizedBox(width: 12),
        _DetailChip(icon: Icons.location_on_rounded, label: _place.district),
        const SizedBox(width: 12),
        if (_place.latitude != null && _place.longitude != null)
          _DetailChip(icon: Icons.explore_rounded, label: 'On Map'),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    if (_place.latitude == null || _place.longitude == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 250,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_place.latitude!, _place.longitude!),
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vynrix.nadodi',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_place.latitude!, _place.longitude!),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sharePlace(context),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _getDirections(context),
            icon: const Icon(Icons.directions_rounded),
            label: const Text('Directions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _sharePlace(BuildContext context) {
    final text = 'Check out ${_place.name} in ${_place.district}, Kerala! Rating: ${_place.rating}/5';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: $text (implement share plugin)')),
    );
  }

  void _getDirections(BuildContext context) {
    if (_place.latitude == null || _place.longitude == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${_place.latitude},${_place.longitude}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening maps: $url (implement url_launcher)')),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}