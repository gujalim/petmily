import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String petId;
  final DateTime date;
  final double? weight;
  final int? activityMinutes;
  final String? activityType;
  final String? notes;
  final String? imageUrl;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.date,
    this.weight,
    this.activityMinutes,
    this.activityType,
    this.notes,
    this.imageUrl,
  });

  // Firestore에서 데이터 로드
  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      id: doc.id,
      petId: data['petId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      weight: data['weight']?.toDouble(),
      activityMinutes: data['activityMinutes'],
      activityType: data['activityType'],
      notes: data['notes'],
      imageUrl: data['imageUrl'],
    );
  }

  // Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'activityMinutes': activityMinutes,
      'activityType': activityType,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  // 로컬 모드용 Map 변환
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      date: DateTime.parse(map['date']),
      weight: map['weight']?.toDouble(),
      activityMinutes: map['activityMinutes'],
      activityType: map['activityType'],
      notes: map['notes'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'activityMinutes': activityMinutes,
      'activityType': activityType,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  // 복사본 생성
  HealthRecord copyWith({
    String? id,
    String? petId,
    DateTime? date,
    double? weight,
    int? activityMinutes,
    String? activityType,
    String? notes,
    String? imageUrl,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      activityMinutes: activityMinutes ?? this.activityMinutes,
      activityType: activityType ?? this.activityType,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 