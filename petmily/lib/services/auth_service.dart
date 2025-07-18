import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자
  static User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호로 회원가입
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('회원가입 중 오류: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호로 로그인
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('로그인 중 오류: $e');
      rethrow;
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('로그아웃 중 오류: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('비밀번호 재설정 중 오류: $e');
      rethrow;
    }
  }

  // 사용자 정보 업데이트
  static Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      print('프로필 업데이트 중 오류: $e');
      rethrow;
    }
  }

  // 에러 메시지 변환
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '해당 이메일로 등록된 사용자가 없습니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'invalid-email':
        return '올바르지 않은 이메일 형식입니다.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
} 