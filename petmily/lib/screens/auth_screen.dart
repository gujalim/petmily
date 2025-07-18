import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (_isLogin) {
          await authProvider.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        } else {
          await authProvider.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        }

        // 인증 상태 확인 후 홈으로 이동
        if (mounted) {
          // 잠시 대기하여 인증 상태 업데이트 확인
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (authProvider.isAuthenticated) {
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isLogin ? '로그인되었습니다! 🎉' : '회원가입되었습니다! 🎉'),
                backgroundColor: const Color(0xFFF48FB1),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 및 제목
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.pets,
                            size: 80,
                            color: Color(0xFFF48FB1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Petmily',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF48FB1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLogin ? '로그인' : '회원가입',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 폼
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 이메일 필드
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              prefixIcon: Icon(Icons.email, color: Color(0xFFF48FB1)),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '이메일을 입력해주세요';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return '올바른 이메일 형식을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호 필드
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFFF48FB1)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFFF48FB1),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해주세요';
                              }
                              if (!_isLogin && value.length < 6) {
                                return '비밀번호는 6자 이상이어야 합니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호 확인 필드 (회원가입 시에만)
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: '비밀번호 확인',
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFFF48FB1)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    color: const Color(0xFFF48FB1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '비밀번호를 다시 입력해주세요';
                                }
                                if (value != _passwordController.text) {
                                  return '비밀번호가 일치하지 않습니다';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 제출 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF48FB1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      _isLogin ? '로그인' : '회원가입',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 모드 전환 버튼
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _emailController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? '계정이 없으신가요? 회원가입'
                                  : '이미 계정이 있으신가요? 로그인',
                              style: const TextStyle(color: Color(0xFFF48FB1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 