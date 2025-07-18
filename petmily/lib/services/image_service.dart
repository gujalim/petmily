import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  // 이미지 선택 (카메라 또는 갤러리)
  static Future<File?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }
  
  // 이미지 선택 다이얼로그
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이미지 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFF48FB1)),
                title: const Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(context: context, source: ImageSource.gallery);
                  if (file != null) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFF48FB1)),
                title: const Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(context: context, source: ImageSource.camera);
                  if (file != null) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
            ],
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
  
  // 이미지를 Base64로 인코딩하여 로컬 저장
  static Future<String?> saveImageLocally(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      print('이미지 저장 중 오류: $e');
      return null;
    }
  }
  
  // Base64 문자열을 이미지로 디코딩
  static Image? decodeImageFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.error,
            color: Colors.red,
            size: 50,
          );
        },
      );
    } catch (e) {
      print('이미지 디코딩 중 오류: $e');
      return null;
    }
  }
  
  // 이미지 크기 조정 (메모리 효율성)
  static Future<Uint8List> resizeImage(File imageFile, {int maxWidth = 800, int maxHeight = 800}) async {
    final bytes = await imageFile.readAsBytes();
    // 실제 이미지 리사이징은 더 복잡하므로, 여기서는 기본 바이트를 반환
    // 실제 구현에서는 image 패키지를 사용하여 리사이징
    return bytes;
  }
} 