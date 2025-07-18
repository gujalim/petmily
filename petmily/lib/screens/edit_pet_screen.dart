import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../services/image_service.dart';
import '../widgets/banner_ad_widget.dart';

class EditPetScreen extends StatefulWidget {
  final Pet pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _microchipController;
  late String _selectedSpecies;
  late String _selectedGender;
  late DateTime _selectedBirthDate;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _weightController = TextEditingController(text: widget.pet.weight.toString());
    _microchipController = TextEditingController(text: widget.pet.microchipId ?? '');
    _selectedSpecies = widget.pet.species;
    _selectedGender = widget.pet.gender;
    _selectedBirthDate = widget.pet.birthDate;
  }

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
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      
      String? imageBase64;
      if (_selectedImageFile != null) {
        imageBase64 = await ImageService.saveImageLocally(_selectedImageFile!);
      }
      
      final updatedPet = widget.pet.copyWith(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        weight: double.parse(_weightController.text),
        gender: _selectedGender,
        microchipId: _microchipController.text.trim().isEmpty 
            ? null 
            : _microchipController.text.trim(),
        imageBase64: imageBase64 ?? widget.pet.imageBase64,
        updatedAt: DateTime.now(),
      );

      await petProvider.updatePet(updatedPet);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Petmily 정보가 수정되었습니다! 🎉'),
            backgroundColor: Color(0xFFF48FB1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petmily 정보 수정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF48FB1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Banner Ad
                const BannerAdWidget(),
                
                // Pet Image
                GestureDetector(
                  onTap: () async {
                    final file = await ImageService.showImagePickerDialog(context);
                    if (file != null) {
                      setState(() {
                        _selectedImageFile = file;
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF48FB1), width: 2),
                    ),
                    child: _buildImageWidget(),
                  ),
                ),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: '이름',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Species Selection
                _buildDropdownField(
                  label: '종류',
                  icon: Icons.category,
                  value: _selectedSpecies,
                  items: const [
                    DropdownMenuItem(value: 'dog', child: Text('🐕 강아지')),
                    DropdownMenuItem(value: 'cat', child: Text('🐱 고양이')),
                    DropdownMenuItem(value: 'bird', child: Text('🐦 새')),
                    DropdownMenuItem(value: 'fish', child: Text('🐠 물고기')),
                    DropdownMenuItem(value: 'other', child: Text('🐾 기타')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecies = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Breed Field
                _buildTextField(
                  controller: _breedController,
                  label: '품종',
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '품종을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Birth Date Field
                _buildDateField(),

                const SizedBox(height: 16),

                // Weight Field
                _buildTextField(
                  controller: _weightController,
                  label: '체중 (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '체중을 입력해주세요';
                    }
                    if (double.tryParse(value) == null) {
                      return '올바른 숫자를 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Gender Selection
                _buildDropdownField(
                  label: '성별',
                  icon: Icons.wc,
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('남성')),
                    DropdownMenuItem(value: 'female', child: Text('여성')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Microchip Field
                _buildTextField(
                  controller: _microchipController,
                  label: '마이크로칩 번호 (선택사항)',
                  icon: Icons.qr_code,
                ),

                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF48FB1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '수정 완료 💕',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF48FB1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFF48FB1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF48FB1), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFF48FB1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF48FB1), width: 1),
      ),
      child: ListTile(
        leading: const Icon(Icons.cake, color: Color(0xFFF48FB1)),
        title: const Text('생년월일'),
        subtitle: Text(
          DateFormat('yyyy년 MM월 dd일').format(_selectedBirthDate),
          style: const TextStyle(color: Color(0xFFF48FB1)),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildImageWidget() {
    // 선택된 이미지가 있으면 표시
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    }
    
    // 기존 이미지가 있으면 표시
    if (widget.pet.imageBase64 != null) {
      final image = ImageService.decodeImageFromBase64(widget.pet.imageBase64);
      if (image != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: image,
        );
      }
    }
    
    // 기본 플레이스홀더
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getPetIcon(_selectedSpecies),
          size: 64,
          color: const Color(0xFFF48FB1),
        ),
        const SizedBox(height: 8),
        const Text(
          '사진을 추가해주세요 📸',
          style: TextStyle(
            color: Color(0xFFF48FB1),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '터치하여 사진 선택',
          style: TextStyle(
            color: Color(0xFFF48FB1),
            fontSize: 12,
          ),
        ),
      ],
    );
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
        return Icons.water_drop;
      case 'rabbit':
        return Icons.pets;
      case 'hamster':
        return Icons.pets;
      default:
        return Icons.pets;
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