import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../models/pet.dart';
import '../services/health_service.dart';
import '../providers/pet_provider.dart';

class HealthHistoryScreen extends StatefulWidget {
  final Pet pet;

  const HealthHistoryScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  final HealthService _healthService = HealthService();
  List<HealthRecord> _healthRecords = [];
  Map<String, dynamic> _activityStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('건강 기록 화면 - 데이터 로드 시작');
      print('반려동물 ID: ${widget.pet.id}');
      
      final records = await _healthService.getHealthRecords(widget.pet.id);
      final stats = await _healthService.getActivityStats(widget.pet.id);
      
      print('건강 기록 화면 - 로드된 기록 수: ${records.length}');
      print('건강 기록 화면 - 통계 데이터: $stats');
      
      setState(() {
        _healthRecords = records;
        _activityStats = stats;
      });
    } catch (e) {
      print('건강 데이터 로드 실패: $e');
      // 에러 발생 시 빈 데이터로 설정
      setState(() {
        _healthRecords = [];
        _activityStats = {
          'totalMinutes': 0,
          'averageMinutesPerDay': 0,
          'activityTypeCount': {},
          'recordCount': 0,
        };
      });
      
      // 사용자에게 에러 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('건강 데이터를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.pet.name} 건강 기록'),
        backgroundColor: const Color(0xFFF48FB1),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.pop();
            } catch (e) {
              print('뒤로가기 에러: $e');
              // 에러 발생 시 홈 화면으로 이동
              context.go('/');
            }
          },
        ),
        actions: [
          // 반려동물 변경 버튼
          IconButton(
            icon: const Icon(Icons.pets),
            onPressed: () => _showPetSelectionDialog(context),
            tooltip: '반려동물 변경',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHealthData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 통계 요약
                    _buildStatsSummary(),
                    const SizedBox(height: 20),
                    
                    // 체중 변화 차트
                    if (_healthRecords.any((record) => record.weight != null))
                      _buildWeightChart(),
                    
                    const SizedBox(height: 20),
                    
                    // 활동량 통계
                    _buildActivityStats(),
                    const SizedBox(height: 20),
                    
                    // 기록 목록
                    _buildRecordsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSummary() {
    final recordsWithWeight = _healthRecords.where((r) => r.weight != null).toList();
    final recordsWithActivity = _healthRecords.where((r) => r.activityMinutes != null).toList();
    
    double? latestWeight = recordsWithWeight.isNotEmpty ? recordsWithWeight.first.weight : null;
    double? averageWeight = recordsWithWeight.isNotEmpty 
        ? recordsWithWeight.map((r) => r.weight!).reduce((a, b) => a + b) / recordsWithWeight.length 
        : null;
    
    int totalActivityMinutes = recordsWithActivity.fold(0, (sum, record) => sum + (record.activityMinutes ?? 0));
    double averageActivityMinutes = recordsWithActivity.isNotEmpty 
        ? totalActivityMinutes / recordsWithActivity.length 
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFFF48FB1)),
              const SizedBox(width: 8),
              const Text(
                '건강 통계 요약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '최근 체중',
                  latestWeight != null ? '${latestWeight.toStringAsFixed(1)} kg' : '기록 없음',
                  Icons.monitor_weight,
                  const Color(0xFFF48FB1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '평균 체중',
                  averageWeight != null ? '${averageWeight.toStringAsFixed(1)} kg' : '기록 없음',
                  Icons.trending_up,
                  const Color(0xFF81C784),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '총 활동 시간',
                  '${totalActivityMinutes}분',
                  Icons.directions_run,
                  const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '평균 활동 시간',
                  '${averageActivityMinutes.toStringAsFixed(0)}분',
                  Icons.timer,
                  const Color(0xFF64B5F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    final weightRecords = _healthRecords
        .where((r) => r.weight != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weightRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFFF48FB1)),
              const SizedBox(width: 8),
              const Text(
                '체중 변화',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildSimpleWeightChart(weightRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleWeightChart(List<HealthRecord> weightRecords) {
    if (weightRecords.length < 2) {
      return const Center(
        child: Text(
          '체중 기록이 부족합니다.\n더 많은 기록을 추가해주세요!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final weights = weightRecords.map((r) => r.weight!).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: WeightChartPainter(
        weightRecords: weightRecords,
        minWeight: minWeight,
        maxWeight: maxWeight,
        weightRange: weightRange,
      ),
    );
  }

  Widget _buildActivityStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run, color: Color(0xFFF48FB1)),
              const SizedBox(width: 8),
              const Text(
                '활동량 통계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activityStats['activityTypeCount'] != null)
            ...(_buildActivityTypeList()).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildActivityTypeList() {
    try {
      final activityTypeCount = _activityStats['activityTypeCount'] as Map<dynamic, dynamic>;
      final recordCount = _activityStats['recordCount'] as int;
      
      return activityTypeCount.entries.map((entry) {
        final activityType = entry.key.toString();
        final count = entry.value as int;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  activityType,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: recordCount > 0 ? count / recordCount : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF48FB1)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${count}회',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList();
    } catch (e) {
      print('활동량 통계 처리 에러: $e');
      return [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '활동량 데이터를 불러올 수 없습니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }
  }

  Widget _buildRecordsList() {
    if (_healthRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.health_and_safety,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '아직 건강 기록이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '오늘부터 건강 체크를 시작해보세요!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '건강 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        ..._healthRecords.map((record) => _buildRecordCard(record)).toList(),
      ],
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(record.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTime(record.updatedAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (record.weight != null || record.activityMinutes != null)
            Row(
              children: [
                if (record.weight != null)
                  Expanded(
                    child: _buildRecordItem(
                      '체중',
                      '${record.weight} kg',
                      Icons.monitor_weight,
                      const Color(0xFFF48FB1),
                    ),
                  ),
                if (record.weight != null && record.activityMinutes != null)
                  const SizedBox(width: 16),
                if (record.activityMinutes != null)
                  Expanded(
                    child: _buildRecordItem(
                      '활동',
                      '${record.activityMinutes}분',
                      Icons.directions_run,
                      const Color(0xFFFFB74D),
                    ),
                  ),
              ],
            ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.notes!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);
    } catch (e) {
      // 한국어 로케일 에러 시 영어로 폴백
      return DateFormat('yyyy-MM-dd (E)', 'en_US').format(date);
    }
  }

  String _formatTime(DateTime time) {
    try {
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildRecordItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPetSelectionDialog(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pets = petProvider.pets;

    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('등록된 반려동물이 없습니다. 먼저 반려동물을 등록해주세요!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('반려동물 변경'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pets.length,
              itemBuilder: (BuildContext context, int index) {
                final pet = pets[index];
                final isCurrentPet = pet.id == widget.pet.id;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentPet 
                        ? const Color(0xFFF48FB1) 
                        : Colors.grey[300],
                    child: Text(
                      pet.name[0],
                      style: TextStyle(
                        color: isCurrentPet ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    pet.name,
                    style: TextStyle(
                      fontWeight: isCurrentPet ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('${pet.species} • ${pet.breed}'),
                  trailing: isCurrentPet 
                      ? const Icon(Icons.check, color: Color(0xFFF48FB1))
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (pet.id != widget.pet.id) {
                      // 다른 반려동물을 선택한 경우 해당 반려동물의 건강 기록 화면으로 이동
                      context.go('/health-history/${pet.id}');
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<HealthRecord> weightRecords;
  final double minWeight;
  final double maxWeight;
  final double weightRange;

  WeightChartPainter({
    required this.weightRecords,
    required this.minWeight,
    required this.maxWeight,
    required this.weightRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (weightRecords.length < 2) return;

      final paint = Paint()
        ..color = const Color(0xFFF48FB1)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final fillPaint = Paint()
        ..color = const Color(0xFFF48FB1).withOpacity(0.1)
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < weightRecords.length; i++) {
        final record = weightRecords[i];
        final x = (i / (weightRecords.length - 1)) * size.width;
        final y = size.height - ((record.weight! - minWeight) / weightRange) * size.height;

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // 점 그리기
      final dotPaint = Paint()
        ..color = const Color(0xFFF48FB1)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < weightRecords.length; i++) {
        final record = weightRecords[i];
        final x = (i / (weightRecords.length - 1)) * size.width;
        final y = size.height - ((record.weight! - minWeight) / weightRange) * size.height;

        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    } catch (e) {
      print('차트 그리기 에러: $e');
      // 에러 발생 시 빈 캔버스 유지
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 