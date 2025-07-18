import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'web_ad_widget.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // 웹에서는 광고를 로드하지 않음
    if (kIsWeb) {
      return;
    }

    print('BannerAdWidget: 광고 로드 시작');
    
    _bannerAd = AdService.createBannerAd()
      ..load().then((_) {
        print('BannerAdWidget: 광고 로드 성공');
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      }).catchError((error) {
        print('배너 광고 로드 실패: $error');
        if (mounted) {
          setState(() {
            _isLoaded = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 웹에서는 WebAdWidget 사용
    if (kIsWeb) {
      return const WebAdWidget();
    }

    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '광고 로딩 중...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
} 