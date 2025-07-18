import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  
  String _selectedSpecies = 'dog';
  String _selectedGender = 'male';
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));
  String? _imageUrl;

  final List<String> _speciesList = ['dog', 'cat', 'bird', 'fish', 'rabbit', 'hamster'];
  final List<String> _genderList = ['male', 'female'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _selectedSpecies,
        breed: _breedController.text,
        birthDate: _selectedBirthDate,
        imageUrl: _imageUrl,
        weight: double.parse(_weightController.text),
        gender: _selectedGender,
        microchipId: _microchipController.text.isEmpty ? null : _microchipController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<PetProvider>().addPet(pet);
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pet image section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getPetColor(_selectedSpecies),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            _getPetIcon(_selectedSpecies),
                            color: Colors.white,
                            size: 60,
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement image picker
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 추가'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pet name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Species selection
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: '종류 *',
                border: OutlineInputBorder(),
              ),
              items: _speciesList.map((String species) {
                return DropdownMenuItem<String>(
                  value: species,
                  child: Text(_getSpeciesDisplayName(species)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSpecies = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Breed
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: '품종 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '품종을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birth date
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '생년월일 *',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_selectedBirthDate),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '체중 (kg) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '체중을 입력해주세요';
                }
                if (double.tryParse(value) == null) {
                  return '올바른 숫자를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender selection
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '성별 *',
                border: OutlineInputBorder(),
              ),
              items: _genderList.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender == 'male' ? '수컷' : '암컷'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Microchip ID (optional)
            TextFormField(
              controller: _microchipController,
              decoration: const InputDecoration(
                labelText: '마이크로칩 ID (선택사항)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _savePet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '반려동물 등록',
                style: TextStyle(fontSize: 16),
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
        return Colors.orange;
      case 'cat':
        return Colors.purple;
      case 'bird':
        return Colors.blue;
      case 'fish':
        return Colors.cyan;
      case 'rabbit':
        return Colors.pink;
      case 'hamster':
        return Colors.brown;
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
      case 'rabbit':
        return Icons.pets;
      case 'hamster':
        return Icons.pets;
      default:
        return Icons.pets;
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
} 