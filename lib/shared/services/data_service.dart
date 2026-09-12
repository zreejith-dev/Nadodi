import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';
import '../../core/config/supabase_config.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Local cache
  List<TouristPlace> _places = [];
  List<Hotel> _hotels = [];
  List<Restaurant> _restaurants = [];
  List<HiddenSpot> _hiddenSpots = [];
  bool _isLoaded = false;

  // Getters
  List<TouristPlace> get places => _places;
  List<Hotel> get hotels => _hotels;
  List<Restaurant> get restaurants => _restaurants;
  List<HiddenSpot> get hiddenSpots => _hiddenSpots;
  bool get isLoaded => _isLoaded;

  // Load local JSON assets first (offline-first), then sync with Supabase
  Future<void> loadLocalData() async {
    if (_isLoaded) return;
    
    try {
      await Future.wait([
        _loadPlaces(),
        _loadHotels(),
        _loadRestaurants(),
        _loadHiddenSpots(),
      ]);
      _isLoaded = true;
      
      // Sync with cloud if authenticated
      if (_supabase.auth.currentUser != null) {
        await syncWithCloud();
      }
    } catch (e) {
      debugPrint('Error loading local data: $e');
      _loadDefaults();
    }
  }

  Future<void> _loadPlaces() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/places.json');
      final jsonData = jsonDecode(jsonString) as List;
      _places = jsonData.map((p) => TouristPlace.fromJson(p)).toList();
    } catch (e) {
      debugPrint('Error loading places: $e');
      _places = _defaultPlaces();
    }
  }

  Future<void> _loadHotels() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/hotels.json');
      final jsonData = jsonDecode(jsonString) as List;
      _hotels = jsonData.map((h) => Hotel.fromJson(h)).toList();
    } catch (e) {
      debugPrint('Error loading hotels: $e');
      _hotels = _defaultHotels();
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonData = jsonDecode(jsonString) as List;
      _restaurants = jsonData.map((r) => Restaurant.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Error loading restaurants: $e');
      _restaurants = _defaultRestaurants();
    }
  }

  Future<void> _loadHiddenSpots() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/hidden_spots.json');
      final jsonData = jsonDecode(jsonString) as List;
      _hiddenSpots = jsonData.map((s) => HiddenSpot.fromJson(s)).toList();
    } catch (e) {
      debugPrint('Error loading hidden spots: $e');
      _hiddenSpots = _defaultHiddenSpots();
    }
  }

  // Sync bookmarks and trips with Supabase
  Future<void> syncWithCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _syncBookmarks(user.id);
      await _syncTrips(user.id);
    } catch (e) {
      debugPrint('Cloud sync error: $e');
    }
  }

  Future<void> _syncBookmarks(String userId) async {
    final response = await _supabase
        .from(SupabaseConfig.userBookmarksTable)
        .select()
        .eq('user_id', userId);
    
    for (final item in response) {
      final placeId = item['place_id'] as int;
      final placeType = item['place_type'] as String;
      
      if (placeType == 'place') {
        final idx = _places.indexWhere((p) => p.id == placeId);
        if (idx != -1) _places[idx] = _places[idx].copyWith(isSaved: true);
      }
    }
  }

  Future<void> _syncTrips(String userId) async {
    // Trips are loaded on-demand in Profile screen
  }

  // Bookmark operations with Supabase sync
  Future<void> toggleBookmark(int placeId, String placeType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final existing = await _supabase
          .from(SupabaseConfig.userBookmarksTable)
          .select()
          .eq('user_id', user.id)
          .eq('place_id', placeId)
          .eq('place_type', placeType)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from(SupabaseConfig.userBookmarksTable)
            .delete()
            .eq('id', existing['id']);
      } else {
        await _supabase
            .from(SupabaseConfig.userBookmarksTable)
            .insert({
              'user_id': user.id,
              'place_id': placeId,
              'place_type': placeType,
            });
      }

      // Update local cache
      if (placeType == 'place') {
        final idx = _places.indexWhere((p) => p.id == placeId);
        if (idx != -1) {
          _places[idx] = _places[idx].copyWith(isSaved: existing == null);
        }
      }
    } catch (e) {
      debugPrint('Bookmark error: $e');
    }
  }

  bool isBookmarked(int placeId, String placeType) {
    switch (placeType) {
      case 'place':
        return _places.any((p) => p.id == placeId && p.isSaved);
      default:
        return false;
    }
  }

  // Fetch nearby places using PostGIS
  Future<List<TouristPlace>> getNearbyPlaces(double lat, double lng, {int radius = 50000}) async {
    try {
      final response = await _supabase.rpc('get_nearby_places', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_meters': radius,
        'limit_count': 20,
      });
      return (response as List).map((p) => TouristPlace.fromJson(p)).toList();
    } catch (e) {
      debugPrint('Nearby places error: $e');
      return [];
    }
  }

  Future<List<Hotel>> getNearbyHotels(double lat, double lng, {int radius = 50000}) async {
    try {
      final response = await _supabase.rpc('get_nearby_hotels', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_meters': radius,
        'limit_count': 20,
      });
      return (response as List).map((h) => Hotel.fromJson(h)).toList();
    } catch (e) {
      debugPrint('Nearby hotels error: $e');
      return [];
    }
  }

  Future<List<Restaurant>> getNearbyRestaurants(double lat, double lng, {int radius = 50000}) async {
    try {
      final response = await _supabase.rpc('get_nearby_restaurants', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_meters': radius,
        'limit_count': 20,
      });
      return (response as List).map((r) => Restaurant.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Nearby restaurants error: $e');
      return [];
    }
  }

  Future<List<HiddenSpot>> getNearbyHiddenSpots(double lat, double lng, {int radius = 50000}) async {
    try {
      final response = await _supabase.rpc('get_nearby_hidden_spots', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_meters': radius,
        'limit_count': 20,
      });
      return (response as List).map((s) => HiddenSpot.fromJson(s)).toList();
    } catch (e) {
      debugPrint('Nearby hidden spots error: $e');
      return [];
    }
  }

  // Filter helpers
  List<TouristPlace> getPlacesByDistrict(String district) {
    return _places.where((p) => p.district == district).toList();
  }

  List<TouristPlace> getPlacesByCategory(String category) {
    return _places.where((p) => p.category == category).toList();
  }

  List<String> getDistricts() {
    final districts = _places.map((p) => p.district).toSet().toList();
    districts.sort();
    return districts;
  }

  List<String> getCategories() {
    final categories = _places.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<TouristPlace> searchPlaces(String query) {
    final q = query.toLowerCase();
    return _places.where((p) => 
      p.name.toLowerCase().contains(q) ||
      p.district.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q)
    ).toList();
  }

  List<TouristPlace> getSavedPlaces() {
    return _places.where((p) => p.isSaved).toList();
  }

  // Default fallback data
  void _loadDefaults() {
    _places = _defaultPlaces();
    _hotels = _defaultHotels();
    _restaurants = _defaultRestaurants();
    _hiddenSpots = _defaultHiddenSpots();
    _isLoaded = true;
  }

  List<TouristPlace> _defaultPlaces() => [
    const TouristPlace(id: 1, name: 'Munnar', category: 'Hill Station', district: 'Idukki', rating: 4.8, 
      description: 'Beautiful hill station with tea gardens', latitude: 10.0889, longitude: 77.0595),
    const TouristPlace(id: 2, name: 'Alleppey Backwaters', category: 'Backwaters', district: 'Alappuzha', rating: 4.7,
      description: 'Serene backwaters perfect for houseboat rides', latitude: 9.4981, longitude: 76.3388),
    const TouristPlace(id: 3, name: 'Fort Kochi', category: 'Historical', district: 'Ernakulam', rating: 4.6,
      description: 'Historic fort with cultural heritage', latitude: 9.9667, longitude: 76.2333),
  ];

  List<Hotel> _defaultHotels() => [
    const Hotel(id: 1, name: 'Grand Resort Munnar', type: 'Resort', district: 'Idukki', priceRange: '₹6000+', rating: 4.7),
    const Hotel(id: 2, name: 'Backwater Homestay', type: 'Homestay', district: 'Alappuzha', priceRange: '₹1500-3000', rating: 4.5),
  ];

  List<Restaurant> _defaultRestaurants() => [
    const Restaurant(id: 1, name: 'Spice Kitchen', cuisine: 'Kerala', district: 'Ernakulam', rating: 4.6),
    const Restaurant(id: 2, name: 'Seafood Paradise', cuisine: 'Seafood', district: 'Alappuzha', rating: 4.5),
  ];

  List<HiddenSpot> _defaultHiddenSpots() => [
    const HiddenSpot(id: 1, name: 'Secret Waterfall Trail', type: 'Secret Waterfall', district: 'Wayanad', difficulty: 'Moderate', rating: 4.7),
    const HiddenSpot(id: 2, name: 'Forest Trek Adventure', type: 'Local Trek', district: 'Palakkad', difficulty: 'Hard', rating: 4.6),
  ];
}