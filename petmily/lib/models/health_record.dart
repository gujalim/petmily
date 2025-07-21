import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String petId;
  final DateTime date;
  final double? weight; // 체중 (kg)
  final int? activityMinutes; // 활동 시간 (분)
  final String? activityType; // 활동 유형 (산책, 놀이, 운동 등)
  final String? notes; // 메모
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.date,
    this.weight,
    this.activityMinutes,
    this.activityType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('HealthRecord 변환 - 문서 ID: ${doc.id}');
      print('HealthRecord 변환 - 데이터: $data');
      
      final record = HealthRecord(
        id: doc.id,
        petId: data['petId'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        weight: data['weight']?.toDouble(),
        activityMinutes: data['activityMinutes'],
        activityType: data['activityType'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
      
      print('HealthRecord 변환 완료 - 날짜: ${record.date}, 체중: ${record.weight}, 활동: ${record.activityMinutes}');
      return record;
    } catch (e) {
      print('HealthRecord 변환 에러: $e');
      rethrow;
    }
  }

  // Firestore에 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'activityMinutes': activityMinutes,
      'activityType': activityType,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // 복사본 생성 (업데이트용)
  HealthRecord copyWith({
    String? id,
    String? petId,
    DateTime? date,
    double? weight,
    int? activityMinutes,
    String? activityType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      activityMinutes: activityMinutes ?? this.activityMinutes,
      activityType: activityType ?? this.activityType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 