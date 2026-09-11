import 'package:flutter/material.dart';
import '../../../shared/services/data_service.dart';
import '../../../shared/models/place.dart';

class PlacesProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  String _selectedCategory = '';
  String _selectedDistrict = '';
  String _searchQuery = '';
  bool _isLoading = false;

  List<TouristPlace> get places => _dataService.places;
  List<TouristPlace> get filteredPlaces => _applyFilters(_dataService.places);
  List<TouristPlace> get savedPlaces => _dataService.getSavedPlaces();
  List<String> get categories => _dataService.getCategories();
  List<String> get districts => _dataService.getDistricts();
  
  String get selectedCategory => _selectedCategory;
  String get selectedDistrict => _selectedDistrict;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    await _dataService.loadLocalData();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = '';
    _selectedDistrict = '';
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> toggleBookmark(TouristPlace place) async {
    await _dataService.toggleBookmark(place.id, 'place');
    notifyListeners();
  }

  bool isBookmarked(int placeId) {
    return _dataService.isBookmarked(placeId, 'place');
  }

  List<TouristPlace> _applyFilters(List<TouristPlace> allPlaces) {
    return allPlaces.where((place) {
      final matchesCategory = _selectedCategory.isEmpty || place.category == _selectedCategory;
      final matchesDistrict = _selectedDistrict.isEmpty || place.district == _selectedDistrict;
      final matchesSearch = _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          place.district.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          place.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesDistrict && matchesSearch;
    }).toList();
  }
}