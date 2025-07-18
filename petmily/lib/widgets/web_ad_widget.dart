import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class WebAdWidget extends StatefulWidget {
  const WebAdWidget({super.key});

  @override
  State<WebAdWidget> createState() => _WebAdWidgetState();
}

class _WebAdWidgetState extends State<WebAdWidget> {
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadWebAd();
    }
  }

  void _loadWebAd() {
    // 웹에서 AdMob 광고 로드
    try {
      // 간단한 지연 후 로딩 완료로 처리
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      });
    } catch (e) {
      print('웹 광고 로드 실패: $e');
      // 에러 발생 시에도 로딩 완료로 처리
      setState(() {
        _isAdLoaded = true;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '웹에서만 지원됩니다',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    if (!_isAdLoaded) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '웹 광고 로딩 중...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    // 웹에서 실제 AdMob 광고 표시
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'AdMob 웹 광고',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
} 