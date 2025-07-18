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

  // 사용자 ID 가져오기
  static String? get currentUserId => _auth.currentUser?.uid;

  // Pet 데이터를 Firestore에 저장
  static Future<void> savePet(Pet pet) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('사용자가 로그인되지 않음 - 로컬 저장소만 사용');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(pet.id)
          .set(pet.toJson());
    } catch (e) {
      print('Firebase Pet 저장 중 오류 (로컬 저장소 사용): $e');
      // Firebase 오류 시 예외를 던지지 않고 로컬 저장소만 사용
    }
  }

  // Pet 데이터를 Firestore에서 불러오기
  static Future<List<Pet>> loadPets() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('사용자가 로그인되지 않음 - 빈 리스트 반환');
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();

      return snapshot.docs
          .map((doc) => Pet.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Firebase Pet 불러오기 중 오류 (빈 리스트 반환): $e');
      return [];
    }
  }

  // Pet 데이터 업데이트
  static Future<void> updatePet(Pet pet) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('사용자가 로그인되지 않음 - 로컬 저장소만 사용');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(pet.id)
          .update(pet.toJson());
    } catch (e) {
      print('Firebase Pet 업데이트 중 오류 (로컬 저장소 사용): $e');
      // Firebase 오류 시 예외를 던지지 않고 로컬 저장소만 사용
    }
  }

  // Pet 데이터 삭제
  static Future<void> deletePet(String petId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('사용자가 로그인되지 않음 - 로컬 저장소만 사용');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .delete();
    } catch (e) {
      print('Firebase Pet 삭제 중 오류 (로컬 저장소 사용): $e');
      // Firebase 오류 시 예외를 던지지 않고 로컬 저장소만 사용
    }
  }

  // 이미지를 Firebase Storage에 업로드
  static Future<String> uploadImage(File imageFile, String petId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('사용자가 로그인되지 않았습니다.');

      final ref = _storage
          .ref()
          .child('users/$userId/pets/$petId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 중 오류: $e');
      rethrow;
    }
  }

  // 이미지를 Firebase Storage에서 삭제
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('이미지 삭제 중 오류: $e');
      rethrow;
    }
  }

  // 실시간 업데이트 리스너
  static Stream<List<Pet>> petsStream() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('사용자가 로그인되지 않음 - 빈 스트림 반환');
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Pet.fromJson(doc.data()))
              .toList());
    } catch (e) {
      print('Firebase 실시간 업데이트 리스너 오류 (빈 스트림 반환): $e');
      return Stream.value([]);
    }
  }
} 