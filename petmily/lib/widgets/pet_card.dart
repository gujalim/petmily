import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pet image or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getPetColor(pet.species),
                borderRadius: BorderRadius.circular(30),
              ),
              child: pet.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        pet.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              _getPetEmoji(pet.species),
                              style: const TextStyle(fontSize: 30),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        _getPetEmoji(pet.species),
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Pet information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} • ${pet.age}살 • ${pet.gender == 'male' ? '수컷' : '암컷'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.weight}kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Action button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  context.go('/pet/${pet.id}');
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
                padding: const EdgeInsets.all(8),
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
} 