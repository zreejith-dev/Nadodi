import 'package:flutter/material.dart';
import '../../../shared/services/data_service.dart';
import '../../../shared/models/place.dart';

class HiddenSpotsProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  String _selectedDistrict = '';
  String _selectedDifficulty = '';
  String _searchQuery = '';

  List<HiddenSpot> get spots => _dataService.hiddenSpots;
  List<HiddenSpot> get filteredSpots => _applyFilters(_dataService.hiddenSpots);
  List<String> get districts => _dataService.hiddenSpots.map((s) => s.district).toSet().toList()..sort();
  List<String> get difficulties => const ['Easy', 'Moderate', 'Hard'];

  String get selectedDistrict => _selectedDistrict;
  String get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;

  void setDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDistrict = '';
    _selectedDifficulty = '';
    _searchQuery = '';
    notifyListeners();
  }

  List<HiddenSpot> _applyFilters(List<HiddenSpot> allSpots) {
    return allSpots.where((spot) {
      final matchesDistrict = _selectedDistrict.isEmpty || spot.district == _selectedDistrict;
      final matchesDifficulty = _selectedDifficulty.isEmpty || spot.difficulty == _selectedDifficulty;
      final matchesSearch = _searchQuery.isEmpty ||
          spot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spot.district.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spot.type.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDistrict && matchesDifficulty && matchesSearch;
    }).toList();
  }
}