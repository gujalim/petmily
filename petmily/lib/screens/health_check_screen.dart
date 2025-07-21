import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../models/pet.dart';
import '../services/health_service.dart';
import 'health_history_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';

class HealthCheckScreen extends StatefulWidget {
  final Pet pet;

  const HealthCheckScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  final HealthService _healthService = HealthService();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  HealthRecord? _selectedDateRecord;
  bool _isLoading = true;
  String _selectedActivityType = '산책';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _activityTypes = [
    '산책',
    '놀이',
    '운동',
    '훈련',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedDateRecord();
  }

  Future<void> _loadSelectedDateRecord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('=== 선택된 날짜 기록 로드 시작 ===');
      print('반려동물 ID: ${widget.pet.id}');
      print('선택된 날짜: $_selectedDate');
      
      HealthRecord record = await _healthService.getOrCreateTodayRecord(widget.pet.id, _selectedDate);
      
      print('로드된 기록: ${record.toFirestore()}');
      print('기록 ID: ${record.id}');
      print('체중: ${record.weight}, 활동: ${record.activityMinutes}, 유형: ${record.activityType}');
      
      setState(() {
        _selectedDateRecord = record;
        
        // 기존 데이터가 있으면 표시, 없으면 초기화
        if (record.weight != null) {
          _weightController.text = record.weight.toString();
          print('체중 필드 설정: ${record.weight}');
        } else {
          _weightController.clear();
          print('체중 필드 초기화');
        }
        
        if (record.activityMinutes != null) {
          _activityController.text = record.activityMinutes.toString();
          print('활동 필드 설정: ${record.activityMinutes}');
        } else {
          _activityController.clear();
          print('활동 필드 초기화');
        }
        
        if (record.activityType != null && record.activityType!.isNotEmpty) {
          _selectedActivityType = record.activityType!;
          print('활동 유형 설정: ${record.activityType}');
        } else {
          _selectedActivityType = '산책';
          print('활동 유형 초기화: 산책');
        }
        
        if (record.notes != null && record.notes!.isNotEmpty) {
          _notesController.text = record.notes!;
          print('메모 필드 설정: ${record.notes}');
        } else {
          _notesController.clear();
          print('메모 필드 초기화');
        }
      });
      
      print('=== 선택된 날짜 기록 로드 완료 ===');
    } catch (e) {
      print('선택된 날짜의 기록 로드 실패: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        // locale: const Locale('ko', 'KR'), // 한국어 로케일 제거
      );
      
      if (picked != null && picked != _selectedDate) {
        print('날짜 변경: ${_selectedDate} → ${picked}');
        
        // 현재 입력된 데이터를 임시 저장
        final currentWeight = _weightController.text;
        final currentActivity = _activityController.text;
        final currentActivityType = _selectedActivityType;
        final currentNotes = _notesController.text;
        
        setState(() {
          _selectedDate = picked;
          _isLoading = true;
        });
        
        // 데이터 로드
        await _loadSelectedDateRecord();
        
        // 만약 새 날짜에 데이터가 없고, 현재 입력된 데이터가 있다면 유지
        if (_selectedDateRecord != null && 
            _selectedDateRecord!.weight == null && 
            _selectedDateRecord!.activityMinutes == null &&
            (currentWeight.isNotEmpty || currentActivity.isNotEmpty || currentNotes.isNotEmpty)) {
          
          print('새 날짜에 데이터가 없고 현재 입력 데이터가 있음 - 입력 데이터 유지');
          setState(() {
            if (currentWeight.isNotEmpty) {
              _weightController.text = currentWeight;
            }
            if (currentActivity.isNotEmpty) {
              _activityController.text = currentActivity;
            }
            if (currentActivityType.isNotEmpty) {
              _selectedActivityType = currentActivityType;
            }
            if (currentNotes.isNotEmpty) {
              _notesController.text = currentNotes;
            }
          });
        }
      }
    } catch (e) {
      print('날짜 선택 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('날짜 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveHealthRecord() async {
    if (_selectedDateRecord == null) return;

    try {
      print('=== 건강 기록 저장 시작 ===');
      print('선택된 날짜: $_selectedDate');
      print('현재 기록 ID: ${_selectedDateRecord!.id}');
      
      double? weight = _weightController.text.isNotEmpty 
          ? double.tryParse(_weightController.text) 
          : null;
      int? activityMinutes = _activityController.text.isNotEmpty 
          ? int.tryParse(_activityController.text) 
          : null;

      print('입력된 데이터 - 체중: $weight, 활동: $activityMinutes, 유형: $_selectedActivityType, 메모: ${_notesController.text}');

      HealthRecord updatedRecord = _selectedDateRecord!.copyWith(
        weight: weight,
        activityMinutes: activityMinutes,
        activityType: _selectedActivityType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        updatedAt: DateTime.now(),
      );

      print('업데이트할 기록: ${updatedRecord.toFirestore()}');
      await _healthService.updateHealthRecord(updatedRecord);
      
      print('저장 완료, 현재 상태 업데이트');
      setState(() {
        _selectedDateRecord = updatedRecord;
      });

      // 저장 후 데이터 재로드 제거 (입력 필드가 초기화되는 문제 해결)
      print('저장 완료 - 데이터 재로드 생략');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(_selectedDate)} 건강 기록이 저장되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _isTodayOrYesterday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAtSameMomentAs(today)) {
      return '오늘 기록';
    } else if (selectedDate.isAtSameMomentAs(yesterday)) {
      return '어제 기록';
    } else {
      return DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);
    }
  }

  String _getDateDisplayText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAtSameMomentAs(today)) {
      return '오늘';
    } else if (selectedDate.isAtSameMomentAs(yesterday)) {
      return '어제';
    } else {
      return DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);
    }
  }

  void _showPetSelectionDialog(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pets = petProvider.pets;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('건강 체크할 Petmily 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pets.length,
              itemBuilder: (context, index) {
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
                      // 다른 반려동물을 선택한 경우 해당 반려동물의 건강 체크 화면으로 이동
                      context.go('/health-check/${pet.id}');
                    }
                  },
                );
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.pet.name} 건강 체크'),
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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/health-history/${widget.pet.id}');
            },
            tooltip: '건강 기록 보기',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 선택
                  Container(
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
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFF48FB1),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '날짜 선택',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getDateDisplayText(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFF48FB1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final yesterday = today.subtract(const Duration(days: 1));
                            final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                            
                            if (selectedDate.isAtSameMomentAs(today) || selectedDate.isAtSameMomentAs(yesterday)) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isTodayOrYesterday(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 체중 입력
                  _buildInputCard(
                    title: '체중 기록',
                    icon: Icons.monitor_weight,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '체중을 입력하세요 (kg)',
                        suffixText: 'kg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 활동량 입력
                  _buildInputCard(
                    title: '활동량 기록',
                    icon: Icons.directions_run,
                    child: Column(
                      children: [
                        // 활동 유형 선택
                        DropdownButtonFormField<String>(
                          value: _selectedActivityType,
                          decoration: const InputDecoration(
                            labelText: '활동 유형',
                            border: OutlineInputBorder(),
                          ),
                          items: _activityTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedActivityType = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // 활동 시간 입력
                        TextField(
                          controller: _activityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '활동 시간을 입력하세요',
                            suffixText: '분',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 메모 입력
                  _buildInputCard(
                    title: '메모',
                    icon: Icons.note,
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '특이사항이나 메모를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveHealthRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48FB1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '건강 기록 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 통계 정보
                  KeyedSubtree(
                    key: ValueKey('stats_${_selectedDateRecord?.id}_${_selectedDateRecord?.updatedAt}'),
                    child: _buildStatsCard(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, color: const Color(0xFFF48FB1)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    print('=== 통계 카드 빌드 ===');
    print('현재 기록: ${_selectedDateRecord?.toFirestore()}');
    
    // 현재 입력된 데이터를 가져오기
    double? currentWeight = _weightController.text.isNotEmpty 
        ? double.tryParse(_weightController.text) 
        : _selectedDateRecord?.weight;
    int? currentActivity = _activityController.text.isNotEmpty 
        ? int.tryParse(_activityController.text) 
        : _selectedDateRecord?.activityMinutes;
    
    print('현재 입력된 데이터 - 체중: $currentWeight, 활동: $currentActivity');
    
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
                '오늘의 기록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '체중',
                  currentWeight != null 
                      ? '${currentWeight} kg' 
                      : '기록 없음',
                  Icons.monitor_weight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '활동',
                  currentActivity != null 
                      ? '${currentActivity}분' 
                      : '기록 없음',
                  Icons.directions_run,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFF48FB1), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _activityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 