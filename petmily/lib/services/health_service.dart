import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record.dart';

class HealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 건강 기록 추가
  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      await _firestore.collection('health_records').add(record.toFirestore());
      print('건강 기록이 추가되었습니다.');
    } catch (e) {
      print('건강 기록 추가 실패: $e');
      rethrow;
    }
  }

  // 특정 반려동물의 건강 기록 가져오기
  Future<List<HealthRecord>> getHealthRecords(String petId) async {
    try {
      print('건강 기록 가져오기 시작 - petId: $petId');
      
      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .get();

      print('Firestore 쿼리 결과 - 문서 수: ${snapshot.docs.length}');
      
      List<HealthRecord> records = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      // 메모리에서 날짜순으로 정렬
      records.sort((a, b) => b.date.compareTo(a.date));

      print('변환된 건강 기록 수: ${records.length}');
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        print('기록 $i: ${record.date} - 체중: ${record.weight}, 활동: ${record.activityMinutes}분');
      }

      return records;
    } catch (e) {
      print('건강 기록 가져오기 실패: $e');
      return [];
    }
  }

  // 특정 날짜의 건강 기록 가져오기
  Future<HealthRecord?> getHealthRecordByDate(String petId, DateTime date) async {
    try {
      print('특정 날짜 기록 가져오기 - petId: $petId, date: $date');
      
      // 날짜의 시작과 끝 설정 (하루 전체)
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      
      print('검색 범위: $startOfDay ~ $endOfDay');

      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .limit(1)
          .get();

      print('특정 날짜 쿼리 결과 - 문서 수: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final record = HealthRecord.fromFirestore(snapshot.docs.first);
        print('찾은 기록: ${record.toFirestore()}');
        return record;
      } else {
        print('해당 날짜의 기록을 찾을 수 없습니다.');
        return null;
      }
    } catch (e) {
      print('특정 날짜 건강 기록 가져오기 실패: $e');
      return null;
    }
  }

  // 건강 기록 업데이트
  Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      print('건강 기록 업데이트 시작 - ID: ${record.id}');
      print('업데이트할 데이터: ${record.toFirestore()}');
      
      // 모든 필드를 명시적으로 업데이트
      Map<String, dynamic> updateData = {
        'petId': record.petId,
        'date': Timestamp.fromDate(record.date),
        'weight': record.weight,
        'activityMinutes': record.activityMinutes,
        'activityType': record.activityType,
        'notes': record.notes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      print('실제 업데이트할 데이터: $updateData');
      
      await _firestore
          .collection('health_records')
          .doc(record.id)
          .update(updateData);
      
      print('건강 기록이 업데이트되었습니다.');
    } catch (e) {
      print('건강 기록 업데이트 실패: $e');
      rethrow;
    }
  }

  // 건강 기록 삭제
  Future<void> deleteHealthRecord(String recordId) async {
    try {
      await _firestore.collection('health_records').doc(recordId).delete();
      print('건강 기록이 삭제되었습니다.');
    } catch (e) {
      print('건강 기록 삭제 실패: $e');
      rethrow;
    }
  }

  // 체중 변화 추이 가져오기 (최근 30일)
  Future<List<HealthRecord>> getWeightHistory(String petId) async {
    try {
      DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      print('체중 변화 추이 가져오기 시작 - petId: $petId, 30일 전: $thirtyDaysAgo');
      
      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .get();

      print('체중 변화 추이 쿼리 결과 - 문서 수: ${snapshot.docs.length}');

      List<HealthRecord> records = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      // 메모리에서 날짜 필터링 (최근 30일)
      List<HealthRecord> recentRecords = records.where((record) => 
        record.date.isAfter(thirtyDaysAgo)
      ).toList();

      // 메모리에서 weight가 null이 아닌 기록만 필터링
      List<HealthRecord> weightRecords = recentRecords.where((record) => 
        record.weight != null
      ).toList();
      
      // 날짜순으로 정렬
      weightRecords.sort((a, b) => a.date.compareTo(b.date));
      
      print('최근 30일 기록 수: ${recentRecords.length}');
      print('체중 기록 수: ${weightRecords.length}');
      
      return weightRecords;
    } catch (e) {
      print('체중 변화 추이 가져오기 실패: $e');
      return [];
    }
  }

  // 활동량 통계 가져오기 (최근 7일)
  Future<Map<String, dynamic>> getActivityStats(String petId) async {
    try {
      DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      print('활동량 통계 가져오기 시작 - petId: $petId, 7일 전: $sevenDaysAgo');
      
      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('petId', isEqualTo: petId)
          .get();

      print('활동량 통계 쿼리 결과 - 문서 수: ${snapshot.docs.length}');

      List<HealthRecord> records = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      // 메모리에서 날짜 필터링 (최근 7일)
      List<HealthRecord> recentRecords = records.where((record) => 
        record.date.isAfter(sevenDaysAgo)
      ).toList();

      // 메모리에서 activityMinutes가 null이 아닌 기록만 필터링
      List<HealthRecord> activityRecords = recentRecords.where((record) => 
        record.activityMinutes != null
      ).toList();
      
      print('최근 7일 기록 수: ${recentRecords.length}');
      print('활동량 기록 수: ${activityRecords.length}');

      int totalMinutes = 0;
      Map<String, int> activityTypeCount = <String, int>{};

      for (var record in activityRecords) {
        if (record.activityMinutes != null) {
          totalMinutes += record.activityMinutes!;
        }
        if (record.activityType != null) {
          final activityType = record.activityType!;
          activityTypeCount[activityType] = (activityTypeCount[activityType] ?? 0) + 1;
        }
      }

      final result = {
        'totalMinutes': totalMinutes,
        'averageMinutesPerDay': activityRecords.isNotEmpty ? totalMinutes / activityRecords.length : 0,
        'activityTypeCount': activityTypeCount,
        'recordCount': activityRecords.length,
      };

      print('활동량 통계 결과: $result');
      return result;
    } catch (e) {
      print('활동량 통계 가져오기 실패: $e');
      return {
        'totalMinutes': 0,
        'averageMinutesPerDay': 0,
        'activityTypeCount': <String, int>{},
        'recordCount': 0,
      };
    }
  }

  // 특정 날짜의 건강 기록 생성 또는 가져오기
  Future<HealthRecord> getOrCreateTodayRecord(String petId, DateTime date) async {
    try {
      print('특정 날짜 기록 생성/가져오기 - petId: $petId, date: $date');
      
      HealthRecord? existingRecord = await getHealthRecordByDate(petId, date);

      if (existingRecord != null) {
        print('기존 기록 발견 - ID: ${existingRecord.id}');
        return existingRecord;
      }

      print('새로운 기록 생성');
      // 새로운 기록 생성
      HealthRecord newRecord = HealthRecord(
        id: '', // Firestore에서 자동 생성
        petId: petId,
        date: date,
        weight: null,
        activityMinutes: null,
        activityType: null,
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Firestore에 저장
      DocumentReference docRef = await _firestore
          .collection('health_records')
          .add(newRecord.toFirestore());

      final createdRecord = newRecord.copyWith(id: docRef.id);
      print('새로운 기록 생성 완료 - ID: ${createdRecord.id}');
      return createdRecord;
    } catch (e) {
      print('특정 날짜 기록 생성/가져오기 실패: $e');
      rethrow;
    }
  }
} 