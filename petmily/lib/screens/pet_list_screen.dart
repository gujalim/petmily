import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/pet_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/pet_card.dart';
import '../widgets/banner_ad_widget.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Petmily'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: '홈으로',
          ),
        ],
      ),
      body: Consumer2<PetProvider, AuthProvider>(
        builder: (context, petProvider, authProvider, child) {
          // 인증되지 않은 사용자는 로그인 화면으로 리다이렉트
          if (!authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/auth');
            });
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (petProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (petProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    petProvider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => petProvider.loadPets(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (petProvider.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 Petmily가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '새로운 Petmily를 등록해보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/add-pet'),
                    icon: const Text('🐾', style: TextStyle(fontSize: 16)),
                    label: const Text(
                      '새 Petmily',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Add Pet Button at the top
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/add-pet'),
                  icon: const Text('🐾', style: TextStyle(fontSize: 16)),
                  label: const Text(
                    '새 Petmily',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              
              // Pet List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: petProvider.pets.length,
                  itemBuilder: (context, index) {
                    final pet = petProvider.pets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PetCard(pet: pet),
                    );
                  },
                ),
              ),
              
              // Ad Banner
              const BannerAdWidget(),
            ],
          );
        },
      ),
      // Floating action button removed - moved to top
    );
  }
} 