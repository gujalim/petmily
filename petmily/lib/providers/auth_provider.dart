import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // 인증 상태 변경 리스너
    AuthService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // 로그인
  Future<void> signIn({required String email, required String password}) async {
    setLoading(true);
    clearError();

    try {
      await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setError(AuthService.getErrorMessage(e.code));
    } catch (e) {
      setError('로그인 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }

  // 회원가입
  Future<void> signUp({required String email, required String password}) async {
    setLoading(true);
    clearError();

    try {
      await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setError(AuthService.getErrorMessage(e.code));
    } catch (e) {
      setError('회원가입 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    setLoading(true);
    clearError();

    try {
      await AuthService.signOut();
    } catch (e) {
      setError('로그아웃 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    setLoading(true);
    clearError();

    try {
      await AuthService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      setError(AuthService.getErrorMessage(e.code));
    } catch (e) {
      setError('비밀번호 재설정 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    setLoading(true);
    clearError();

    try {
      await AuthService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      setError('프로필 업데이트 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }

  // 로딩 상태 설정
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 설정
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 