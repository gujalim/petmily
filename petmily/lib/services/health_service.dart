import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record.dart';

class HealthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 건강 기록 추가
  static Future<void> addHealthRecord(HealthRecord record) async {
    try {
      await _firestore.collection('health_records').add(record.toFirestore());
      print('건강 기록 추가 성공');
    } catch (e) {
      print('건강 기록 추가 실패: $e');
      rethrow;
    }
  }

  // 건강 기록 목록 가져오기
  static Future<List<HealthRecord>> getHealthRecords(String petId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .get();

      List<HealthRecord> records = snapshot.docs.map((doc) => HealthRecord.fromFirestore(doc)).toList();
      // 클라이언트에서 정렬
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      print('건강 기록 목록 가져오기 실패: $e');
      return [];
    }
  }

  // 특정 날짜의 건강 기록 가져오기
  static Future<HealthRecord?> getHealthRecordsByDate(String petId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return HealthRecord.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('특정 날짜 건강 기록 가져오기 실패: $e');
      return null;
    }
  }

  // 오늘 기록 가져오기 또는 생성
  static Future<HealthRecord> getOrCreateTodayRecord(String petId, DateTime date) async {
    try {
      HealthRecord? existingRecord = await getHealthRecordsByDate(petId, date);
      
      if (existingRecord != null) {
        return existingRecord;
      }

      // 새 기록 생성
      HealthRecord newRecord = HealthRecord(
        id: '', // Firestore에서 자동 생성
        petId: petId,
        date: date,
      );

      DocumentReference docRef = await _firestore.collection('health_records').add(newRecord.toFirestore());
      
      return newRecord.copyWith(id: docRef.id);
    } catch (e) {
      print('오늘 기록 가져오기/생성 실패: $e');
      rethrow;
    }
  }

  // 건강 기록 업데이트
  static Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      await _firestore.collection('health_records').doc(record.id).update(record.toFirestore());
      print('건강 기록 업데이트 성공');
    } catch (e) {
      print('건강 기록 업데이트 실패: $e');
      rethrow;
    }
  }

  // 건강 기록 삭제
  static Future<void> deleteHealthRecord(String recordId) async {
    try {
      await _firestore.collection('health_records').doc(recordId).delete();
      print('건강 기록 삭제 성공');
    } catch (e) {
      print('건강 기록 삭제 실패: $e');
      rethrow;
    }
  }

  // 날짜 범위로 건강 기록 가져오기
  static Future<List<HealthRecord>> getHealthRecordsByDateRange(String petId, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      List<HealthRecord> records = snapshot.docs.map((doc) => HealthRecord.fromFirestore(doc)).toList();
      // 클라이언트에서 정렬
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      print('날짜 범위 건강 기록 가져오기 실패: $e');
      return [];
    }
  }

  // 활동 통계 가져오기
  static Future<Map<String, dynamic>> getActivityStats(String petId) async {
    try {
      List<HealthRecord> records = await getHealthRecords(petId);
      
      if (records.isEmpty) {
        return {
          'totalActivityMinutes': 0,
          'averageActivityMinutes': 0,
          'totalRecords': 0,
        };
      }

      int totalActivityMinutes = records
          .where((r) => r.activityMinutes != null)
          .fold(0, (sum, record) => sum + (record.activityMinutes ?? 0));

      int recordsWithActivity = records.where((r) => r.activityMinutes != null).length;
      double averageActivityMinutes = recordsWithActivity > 0 ? totalActivityMinutes / recordsWithActivity : 0;

      return {
        'totalActivityMinutes': totalActivityMinutes,
        'averageActivityMinutes': averageActivityMinutes.round(),
        'totalRecords': records.length,
      };
    } catch (e) {
      print('활동 통계 가져오기 실패: $e');
      return {
        'totalActivityMinutes': 0,
        'averageActivityMinutes': 0,
        'totalRecords': 0,
      };
    }
  }

  // 건강 통계 가져오기
  static Future<Map<String, dynamic>> getHealthStatistics(String petId) async {
    try {
      List<HealthRecord> records = await getHealthRecords(petId);
      
      if (records.isEmpty) {
        return {
          'latestWeight': null,
          'averageWeight': null,
          'totalActivityMinutes': 0,
          'averageActivityMinutes': 0,
          'totalRecords': 0,
        };
      }

      // 체중 관련 통계
      List<HealthRecord> weightRecords = records.where((r) => r.weight != null).toList();
      double? latestWeight = weightRecords.isNotEmpty ? weightRecords.first.weight : null;
      double? averageWeight = weightRecords.isNotEmpty 
          ? weightRecords.map((r) => r.weight!).reduce((a, b) => a + b) / weightRecords.length 
          : null;

      // 활동 관련 통계
      List<HealthRecord> activityRecords = records.where((r) => r.activityMinutes != null).toList();
      int totalActivityMinutes = activityRecords.fold(0, (sum, record) => sum + (record.activityMinutes ?? 0));
      double averageActivityMinutes = activityRecords.isNotEmpty ? totalActivityMinutes / activityRecords.length : 0;

      return {
        'latestWeight': latestWeight,
        'averageWeight': averageWeight,
        'totalActivityMinutes': totalActivityMinutes,
        'averageActivityMinutes': averageActivityMinutes.round(),
        'totalRecords': records.length,
      };
    } catch (e) {
      print('건강 통계 가져오기 실패: $e');
      return {
        'latestWeight': null,
        'averageWeight': null,
        'totalActivityMinutes': 0,
        'averageActivityMinutes': 0,
        'totalRecords': 0,
      };
    }
  }
} 