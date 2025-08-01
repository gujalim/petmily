import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../models/pet.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load pets when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Petmily',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              print('Auth state in home: ${authProvider.isAuthenticated}, User: ${authProvider.user?.email}');
              return authProvider.isAuthenticated
                  ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          context.go('/auth');
                        }
                      },
                      tooltip: '로그아웃',
                    )
                  : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => context.go('/auth'),
                      tooltip: '로그인',
                    );
            },
          ),
        ],
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          return Column(
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Text(
                          authProvider.isAuthenticated 
                              ? '안녕하세요, ${authProvider.user?.email ?? '사용자'}님!'
                              : '안녕하세요!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (!authProvider.isAuthenticated) {
                          return const Text(
                            '로그인하여 Petmily를 관리해보세요!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          );
                        }
                        
                        return Text(
                          petProvider.pets.isEmpty 
                              ? '새로운 Petmily를 등록해보세요!'
                              : '${petProvider.pets.length}마리의 Petmily와 함께하고 있어요',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Main menu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // My Pets Card
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return _buildMenuCard(
                            context,
                            title: 'My Petmily',
                            subtitle: !authProvider.isAuthenticated
                                ? '로그인하여 Petmily 관리하기'
                                : petProvider.pets.isEmpty 
                                    ? '새로운 Petmily를 등록해보세요'
                                    : '${petProvider.pets.length}마리의 Petmily 관리하기',
                            icon: Icons.pets,
                            iconColor: const Color(0xFFFFB74D),
                            onTap: () {
                              if (!authProvider.isAuthenticated) {
                                context.go('/auth');
                              } else {
                                context.go('/pets');
                              }
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nearby Search Card
                      _buildMenuCard(
                        context,
                        title: '주변 탐색',
                        subtitle: '병원, 용품점, 산책코스 찾기',
                        icon: Icons.map,
                        iconColor: const Color(0xFF81C784),
                        onTap: () => context.go('/nearby'),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (!authProvider.isAuthenticated) {
                            return const SizedBox.shrink();
                          }
                          
                          return Column(
                            children: [
                              const Text(
                                '빠른 액션',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      title: '새 Petmily',
                                      icon: '🐾',
                                      onTap: () => context.go('/add-pet'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      title: '건강 체크',
                                      icon: '🏥',
                                      onTap: () {
                                        if (petProvider.pets.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('먼저 Petmily를 등록해주세요!'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        } else if (petProvider.pets.length == 1) {
                                          // 반려동물이 1마리면 바로 건강 체크 화면으로 이동
                                          context.go('/health-check/${petProvider.pets.first.id}');
                                        } else {
                                          // 반려동물이 여러 마리면 선택 화면으로 이동
                                          _showPetSelectionDialog(context, petProvider.pets);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Ad Banner
              const BannerAdWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPetSelectionDialog(BuildContext context, List<Pet> pets) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('건강 체크할 Petmily 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF48FB1),
                    child: Text(
                      pet.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(pet.name),
                  subtitle: Text('${pet.species} • ${pet.breed}'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/health-check/${pet.id}');
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
} 