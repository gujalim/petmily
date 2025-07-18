import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/image_service.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: '홈으로',
          ),
          IconButton(
            onPressed: () => context.push('/edit-pet/${pet.id}'),
            icon: const Icon(Icons.edit),
            tooltip: '편집',
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet image and basic info
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
                      children: [
                        // Pet image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _getPetColor(pet.species),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: _buildPetImage(pet),
                        ),
                        const SizedBox(height: 16),
                        // Pet name
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Pet breed and age
                        Text(
                          '${pet.breed} • ${pet.age}살',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Pet details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '기본 정보',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Info cards
                        _buildInfoCard(
                          context,
                          '종류',
                          _getSpeciesDisplayName(pet.species),
                          Icons.pets,
                        ),
                        const SizedBox(height: 8),
                        
                        _buildInfoCard(
                          context,
                          '성별',
                          pet.gender == 'male' ? '수컷' : '암컷',
                          pet.gender == 'male' ? Icons.male : Icons.female,
                        ),
                        const SizedBox(height: 8),
                        
                        _buildInfoCard(
                          context,
                          '체중',
                          '${pet.weight}kg',
                          Icons.monitor_weight,
                        ),
                        const SizedBox(height: 8),
                        
                        _buildInfoCard(
                          context,
                          '생년월일',
                          DateFormat('yyyy년 MM월 dd일').format(pet.birthDate),
                          Icons.cake,
                        ),
                        
                        if (pet.microchipId != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            context,
                            '마이크로칩 ID',
                            pet.microchipId!,
                            Icons.qr_code,
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Registration info
                        const Text(
                          '등록 정보',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoCard(
                          context,
                          '등록일',
                          DateFormat('yyyy년 MM월 dd일').format(pet.createdAt),
                          Icons.calendar_today,
                        ),
                        const SizedBox(height: 8),
                        
                        _buildInfoCard(
                          context,
                          '최종 수정일',
                          DateFormat('yyyy년 MM월 dd일').format(pet.updatedAt),
                          Icons.update,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ad Banner
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return const Color(0xFFFFB74D); // 파스텔 오렌지
      case 'cat':
        return const Color(0xFFE1BEE7); // 파스텔 보라
      case 'bird':
        return const Color(0xFF81C784); // 파스텔 그린
      case 'fish':
        return const Color(0xFF81D4FA); // 파스텔 블루
      case 'rabbit':
        return const Color(0xFFF8BBD9); // 파스텔 핑크
      case 'hamster':
        return const Color(0xFFD7CCC8); // 파스텔 브라운
      default:
        return const Color(0xFFE0E0E0); // 파스텔 그레이
    }
  }

  String _getPetEmoji(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐈';
      case 'bird':
        return '🐦';
      case 'fish':
        return '🐠';
      case 'rabbit':
        return '🐰';
      case 'hamster':
        return '🐹';
      default:
        return '🐾';
    }
  }

  String _getSpeciesDisplayName(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return '강아지';
      case 'cat':
        return '고양이';
      case 'bird':
        return '새';
      case 'fish':
        return '물고기';
      case 'rabbit':
        return '토끼';
      case 'hamster':
        return '햄스터';
      default:
        return species;
    }
  }

  Widget _buildPetImage(Pet pet) {
    // Base64 이미지가 있으면 표시
    if (pet.imageBase64 != null) {
      final image = ImageService.decodeImageFromBase64(pet.imageBase64);
      if (image != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: image,
        );
      }
    }
    
    // URL 이미지가 있으면 표시
    if (pet.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          pet.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                _getPetEmoji(pet.species),
                style: const TextStyle(fontSize: 60),
              ),
            );
          },
        ),
      );
    }
    
    // 기본 이모지 표시
    return Center(
      child: Text(
        _getPetEmoji(pet.species),
        style: const TextStyle(fontSize: 60),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Petmily 삭제'),
          content: Text('${pet.name}을(를) 정말로 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final petProvider = Provider.of<PetProvider>(context, listen: false);
                await petProvider.deletePet(pet.id);
                if (context.mounted) {
                  context.go('/pets');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name}이(가) 삭제되었습니다.'),
                      backgroundColor: const Color(0xFFF48FB1),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
} 