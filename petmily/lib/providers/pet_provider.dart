import 'package:flutter/foundation.dart';
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get pet by ID
  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new pet
  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  // Update pet
  void updatePet(Pet updatedPet) {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      notifyListeners();
    }
  }

  // Delete pet
  void deletePet(String id) {
    _pets.removeWhere((pet) => pet.id == id);
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load pets (placeholder for API integration)
  Future<void> loadPets() async {
    setLoading(true);
    clearError();
    
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // For now, add some sample data
      if (_pets.isEmpty) {
        _pets = [
          Pet(
            id: '1',
            name: '멍멍이',
            species: 'dog',
            breed: '골든 리트리버',
            birthDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
            weight: 25.5,
            gender: 'male',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Pet(
            id: '2',
            name: '냥냥이',
            species: 'cat',
            breed: '페르시안',
            birthDate: DateTime.now().subtract(const Duration(days: 365 * 1)),
            weight: 4.2,
            gender: 'female',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      setError('반려동물 정보를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  }
} 