import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/storage_service.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;
  final StorageService _storageService = StorageService();

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
  Future<void> addPet(Pet pet) async {
    try {
      _pets.add(pet);
      await _storageService.savePet(pet);
      notifyListeners();
    } catch (e) {
      setError('Petmily 추가에 실패했습니다.');
    }
  }

  // Update pet
  Future<void> updatePet(Pet updatedPet) async {
    try {
      final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
      if (index != -1) {
        _pets[index] = updatedPet;
        await _storageService.savePet(updatedPet);
        notifyListeners();
      }
    } catch (e) {
      setError('Petmily 정보 수정에 실패했습니다.');
    }
  }

  // Delete pet
  Future<void> deletePet(String id) async {
    try {
      _pets.removeWhere((pet) => pet.id == id);
      await _storageService.deletePet(id);
      notifyListeners();
    } catch (e) {
      setError('Petmily 삭제에 실패했습니다.');
    }
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

  // Load pets from storage
  Future<void> loadPets() async {
    setLoading(true);
    clearError();
    
    try {
      _pets = await _storageService.loadPets();
      
      // If no pets exist, add sample data
      if (_pets.isEmpty) {
        _pets = [
          Pet(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
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
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
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
        
        // Save sample data
        await _storageService.savePets(_pets);
      }
    } catch (e) {
      setError('Petmily 정보를 불러오는데 실패했습니다.');
    } finally {
      setLoading(false);
    }
  }
} 