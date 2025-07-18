import 'package:flutter/material.dart';
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
                          return Icon(
                            _getPetIcon(pet.species),
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getPetIcon(pet.species),
                      color: Colors.white,
                      size: 30,
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
            IconButton(
              onPressed: () {
                // TODO: Navigate to pet detail screen
              },
              icon: const Icon(Icons.arrow_forward_ios),
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Colors.orange;
      case 'cat':
        return Colors.purple;
      case 'bird':
        return Colors.blue;
      case 'fish':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getPetIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.water;
      default:
        return Icons.pets;
    }
  }
} 