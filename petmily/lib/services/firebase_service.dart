import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 반려동물 저장
  static Future<void> savePet(Pet pet) async {
    try {
      await _firestore.collection('pets').add({
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'birthDate': pet.birthDate != null ? Timestamp.fromDate(pet.birthDate!) : null,
        'weight': pet.weight,
        'imageUrl': pet.imageUrl,
        'userId': _auth.currentUser?.uid,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      print('반려동물 저장 성공');
    } catch (e) {
      print('반려동물 저장 실패: $e');
      rethrow;
    }
  }

  // 반려동물 업데이트
  static Future<void> updatePet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).update({
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'birthDate': pet.birthDate != null ? Timestamp.fromDate(pet.birthDate!) : null,
        'weight': pet.weight,
        'imageUrl': pet.imageUrl,
        'updatedAt': Timestamp.now(),
      });
      print('반려동물 업데이트 성공');
    } catch (e) {
      print('반려동물 업데이트 실패: $e');
      rethrow;
    }
  }

  // 반려동물 삭제
  static Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
      print('반려동물 삭제 성공');
    } catch (e) {
      print('반려동물 삭제 실패: $e');
      rethrow;
    }
  }

  // 반려동물 목록 로드
  static Future<List<Pet>> loadPets() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('사용자 인증 정보가 없습니다.');
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .get();

      List<Pet> pets = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Pet(
          id: doc.id,
          name: data['name'] ?? '',
          species: data['species'] ?? '',
          breed: data['breed'] ?? '',
          birthDate: data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : DateTime.now(),
          weight: data['weight']?.toDouble() ?? 0.0,
          gender: data['gender'] ?? 'unknown',
          imageUrl: data['imageUrl'],
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
          updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
        );
      }).toList();
      
      // 클라이언트에서 정렬
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pets;
    } catch (e) {
      print('반려동물 목록 로드 실패: $e');
      return [];
    }
  }

  // 이미지 업로드
  static Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      Reference ref = _storage.ref().child('pet_images/$fileName');
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('이미지 업로드 성공: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      rethrow;
    }
  }

  // 이미지 삭제
  static Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('이미지 삭제 성공');
    } catch (e) {
      print('이미지 삭제 실패: $e');
      rethrow;
    }
  }
} 