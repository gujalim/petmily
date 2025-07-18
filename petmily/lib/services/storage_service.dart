import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class StorageService {
  static const String _petsKey = 'pets';
  
  // Pet 목록 저장
  Future<void> savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = pets.map((pet) => pet.toJson()).toList();
    await prefs.setString(_petsKey, jsonEncode(petsJson));
  }
  
  // Pet 목록 불러오기
  Future<List<Pet>> loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsString = prefs.getString(_petsKey);
    
    if (petsString == null) {
      return [];
    }
    
    try {
      final petsJson = jsonDecode(petsString) as List;
      return petsJson.map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      print('Error loading pets: $e');
      return [];
    }
  }
  
  // 단일 Pet 저장 (기존 목록에 추가하거나 업데이트)
  Future<void> savePet(Pet pet) async {
    final pets = await loadPets();
    final existingIndex = pets.indexWhere((p) => p.id == pet.id);
    
    if (existingIndex != -1) {
      pets[existingIndex] = pet;
    } else {
      pets.add(pet);
    }
    
    await savePets(pets);
  }
  
  // Pet 삭제
  Future<void> deletePet(String id) async {
    final pets = await loadPets();
    pets.removeWhere((pet) => pet.id == id);
    await savePets(pets);
  }
  
  // 모든 데이터 삭제
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petsKey);
  }
} 