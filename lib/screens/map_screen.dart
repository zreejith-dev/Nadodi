import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../features/places/places_provider.dart';
import '../features/hidden/hidden_provider.dart';
import '../shared/services/data_service.dart';
import '../shared/models/place.dart';
import '../shared/widgets/optimized_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  String _selectedLayer = 'places'; // places, hotels, restaurants, hidden

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
        _mapController.move(_currentLocation!, 12);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlacesProvider, HiddenSpotsProvider, DataService>(
      builder: (context, placesProvider, hiddenProvider, dataService, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Map View'),
            actions: [
              _buildLayerSelector(context),
              IconButton(
                icon: _isLoadingLocation
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location_rounded),
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(10.8505, 76.2711), // Kerala center
                  initialZoom: 8,
                  minZoom: 6,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vynrix.nadodi',
                    maxZoom: 19,
                  ),
                  _buildMarkersLayer(placesProvider, hiddenProvider, dataService),
                  if (_currentLocation != null) _buildCurrentLocationMarker(),
                ],
              ),
              // Legend
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: _buildLegend(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNearbyBottomSheet(context, placesProvider, hiddenProvider, dataService),
            icon: const Icon(Icons.near_me_rounded),
            label: const Text('Nearby'),
          ),
        );
      },
    );
  }

  Widget _buildLayerSelector(BuildContext context) {
    final layers = ['places', 'hotels', 'restaurants', 'hidden'];
    return PopupMenuButton<String>(
      initialValue: _selectedLayer,
      onSelected: (value) => setState(() => _selectedLayer = value),
      itemBuilder: (context) => layers.map((layer) => PopupMenuItem(
        value: layer,
        child: Text(layer[0].toUpperCase() + layer.substring(1)),
      )).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Chip(
          label: Text(_selectedLayer[0].toUpperCase() + _selectedLayer.substring(1)),
          avatar: Icon(_getLayerIcon(_selectedLayer), size: 18),
          onDeleted: null,
        ),
      ),
    );
  }

  IconData _getLayerIcon(String layer) {
    switch (layer) {
      case 'places': return Icons.place_rounded;
      case 'hotels': return Icons.hotel_rounded;
      case 'restaurants': return Icons.restaurant_rounded;
      case 'hidden': return Icons.diamond_rounded;
      default: return Icons.place_rounded;
    }
  }

  MarkerLayer _buildMarkersLayer(PlacesProvider placesProvider, HiddenSpotsProvider hiddenProvider, DataService dataService) {
    final List<Marker> markers = [];

    switch (_selectedLayer) {
      case 'places':
        for (final place in placesProvider.places) {
          if (place.latitude != null && place.longitude != null) {
            markers.add(_buildPlaceMarker(place));
          }
        }
        break;
      case 'hotels':
        for (final hotel in dataService.hotels) {
          if (hotel.latitude != null && hotel.longitude != null) {
            markers.add(_buildHotelMarker(hotel));
          }
        }
        break;
      case 'restaurants':
        for (final restaurant in dataService.restaurants) {
          if (restaurant.latitude != null && restaurant.longitude != null) {
            markers.add(_buildRestaurantMarker(restaurant));
          }
        }
        break;
      case 'hidden':
        for (final spot in hiddenProvider.spots) {
          if (spot.latitude != null && spot.longitude != null) {
            markers.add(_buildHiddenMarker(spot));
          }
        }
        break;
    }

    return MarkerLayer(markers: markers);
  }

  Marker _buildPlaceMarker(TouristPlace place) {
    return Marker(
      point: LatLng(place.latitude!, place.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showPlacePopup(place),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.place_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Marker _buildHotelMarker(Hotel hotel) {
    return Marker(
      point: LatLng(hotel.latitude!, hotel.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showHotelPopup(hotel),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Marker _buildRestaurantMarker(Restaurant restaurant) {
    return Marker(
      point: LatLng(restaurant.latitude!, restaurant.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showRestaurantPopup(restaurant),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Marker _buildHiddenMarker(HiddenSpot spot) {
    return Marker(
      point: LatLng(spot.latitude!, spot.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showHiddenPopup(spot),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  MarkerLayer _buildCurrentLocationMarker() {
    return MarkerLayer(
      markers: [
        Marker(
          point: _currentLocation!,
          width: 20,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
            ),
          ),
        ),
      ],
    );
  }

  void _showPlacePopup(TouristPlace place) {
    showDialog(
      context: context,
      builder: (context) => _PlacePopup(
        title: place.name,
        subtitle: '${place.category} • ${place.district}',
        rating: place.rating,
        imageUrl: place.imageUrl,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/place-detail', arguments: place);
        },
      ),
    );
  }

  void _showHotelPopup(Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => _PlacePopup(
        title: hotel.name,
        subtitle: '${hotel.type} • ${hotel.district} • ${hotel.priceRange}',
        rating: hotel.rating,
        imageUrl: hotel.imageUrl,
        onTap: () {
          Navigator.pop(context);
          // Navigate to hotel detail
        },
      ),
    );
  }

  void _showRestaurantPopup(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => _PlacePopup(
        title: restaurant.name,
        subtitle: '${restaurant.cuisine} • ${restaurant.district}',
        rating: restaurant.rating,
        imageUrl: restaurant.imageUrl,
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showHiddenPopup(HiddenSpot spot) {
    showDialog(
      context: context,
      builder: (context) => _PlacePopup(
        title: spot.name,
        subtitle: '${spot.type} • ${spot.district} • ${spot.difficulty}',
        rating: spot.rating,
        imageUrl: spot.imageUrl,
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showNearbyBottomSheet(BuildContext context, PlacesProvider placesProvider, HiddenSpotsProvider hiddenProvider, DataService dataService) {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NearbyBottomSheet(
        location: _currentLocation!,
        placesProvider: placesProvider,
        hiddenProvider: hiddenProvider,
        dataService: dataService,
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final items = [
      (Colors.blue, 'Places', Icons.place_rounded),
      (Colors.orange, 'Hotels', Icons.hotel_rounded),
      (Colors.red, 'Restaurants', Icons.restaurant_rounded),
      (Colors.purple, 'Hidden Gems', Icons.diamond_rounded),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: items.map((item) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: item.$1, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(item.$2, style: Theme.of(context).textTheme.bodySmall),
            ],
          )).toList(),
        ),
      ),
    );
  }
}

class _PlacePopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String? imageUrl;
  final VoidCallback onTap;

  const _PlacePopup({
    required this.title,
    required this.subtitle,
    required this.rating,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  OptimizedImage(
                    imageUrl: imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber[700], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: onTap, child: const Text('View Details')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyBottomSheet extends StatefulWidget {
  final LatLng location;
  final PlacesProvider placesProvider;
  final HiddenSpotsProvider hiddenProvider;
  final DataService dataService;

  const _NearbyBottomSheet({
    required this.location,
    required this.placesProvider,
    required this.hiddenProvider,
    required this.dataService,
  });

  @override
  State<_NearbyBottomSheet> createState() => _NearbyBottomSheetState();
}

class _NearbyBottomSheetState extends State<_NearbyBottomSheet> {
  late Future<List<dynamic>> _nearbyFuture;

  @override
  void initState() {
    super.initState();
    _nearbyFuture = _loadNearby();
  }

  Future<List<dynamic>> _loadNearby() async {
    final lat = widget.location.latitude;
    final lng = widget.location.longitude;
    final results = <dynamic>[];

    try {
      // Fetch from Supabase
      final nearbyPlaces = await widget.dataService.getNearbyPlaces(lat, lng);
      results.addAll(nearbyPlaces);
    } catch (e) {
      debugPrint('Nearby error: $e');
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.near_me_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Nearby Places', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _nearbyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No nearby places found'));
                }
                final places = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    if (place is TouristPlace) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: OptimizedImage(imageUrl: place.imageUrl, width: 50, height: 50),
                        ),
                        title: Text(place.name),
                        subtitle: Text('${place.category} • ${place.district} • ${place.rating}★'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/place-detail', arguments: place);
                        },
                      );
                    }
                    return const SizedBox.shrink();
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