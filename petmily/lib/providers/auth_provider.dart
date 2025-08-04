import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    AuthService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '알 수 없는 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '알 수 없는 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOut();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '알 수 없는 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 