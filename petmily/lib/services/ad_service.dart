import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  // TODO: 실제 AdMob ID로 교체하세요!
  // AdMob 콘솔에서 발급받은 실제 광고 ID를 아래에 입력하세요.
  
  static String get bannerAdUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/6300978111'; // TODO: 웹용 실제 광고 ID로 교체
      // 예시: 'ca-app-pub-XXXXXXXXXX/WEB_BANNER_ID'
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-4904148120097894/4395973131'; // Android용 실제 광고 ID
      // 예시: 'ca-app-pub-XXXXXXXXXX/ANDROID_BANNER_ID'
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4904148120097894/5171048508'; // iOS용 실제 광고 ID
      // 예시: 'ca-app-pub-XXXXXXXXXX/IOS_BANNER_ID'
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/1033173712'; // TODO: 웹용 실제 광고 ID로 교체
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // TODO: Android용 실제 광고 ID로 교체
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // TODO: iOS용 실제 광고 ID로 교체
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544/5224354917'; // TODO: 웹용 실제 광고 ID로 교체
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // TODO: Android용 실제 광고 ID로 교체
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // TODO: iOS용 실제 광고 ID로 교체
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // 앱 ID (AndroidManifest.xml, Info.plist에 설정)
  static String get appId {
    if (kIsWeb) {
      return 'ca-app-pub-3940256099942544~3347511713'; // TODO: 웹용 실제 앱 ID로 교체
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544~3347511713'; // TODO: Android용 실제 앱 ID로 교체
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4904148120097894~4915897632'; // iOS용 실제 앱 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static Future<void> initialize() async {
    if (kIsWeb) {
      // 웹에서는 광고 초기화를 건너뜀 (웹뷰나 네이티브 웹 광고 사용)
      print('웹 환경에서는 별도 광고 초기화가 필요합니다.');
      return;
    }
    
    print('AdService: 광고 초기화 시작');
    try {
      await MobileAds.instance.initialize();
      print('AdService: 광고 초기화 성공');
    } catch (e) {
      print('AdService: 광고 초기화 실패: $e');
    }
  }

  static BannerAd createBannerAd() {
    if (kIsWeb) {
      throw UnsupportedError('웹에서는 createBannerAd를 사용할 수 없습니다. WebAdWidget을 사용하세요.');
    }
    
    print('AdService: 배너 광고 생성 - adUnitId: $bannerAdUnitId');
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('배너 광고가 로드되었습니다.');
        },
        onAdFailedToLoad: (ad, error) {
          print('배너 광고 로드 실패: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('배너 광고가 열렸습니다.');
        },
        onAdClosed: (ad) {
          print('배너 광고가 닫혔습니다.');
        },
      ),
    );
  }

  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    if (kIsWeb) {
      print('웹에서는 전면 광고를 지원하지 않습니다.');
      return;
    }
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('전면 광고가 로드되었습니다.');
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: $error');
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (kIsWeb) {
      print('웹에서는 전면 광고를 지원하지 않습니다.');
      return;
    }
    
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('전면 광고가 로드되지 않았습니다.');
    }
  }

  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd() async {
    if (kIsWeb) {
      print('웹에서는 보상형 광고를 지원하지 않습니다.');
      return;
    }
    
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('보상형 광고가 로드되었습니다.');
        },
        onAdFailedToLoad: (error) {
          print('보상형 광고 로드 실패: $error');
        },
      ),
    );
  }

  static Future<void> showRewardedAd() async {
    if (kIsWeb) {
      print('웹에서는 보상형 광고를 지원하지 않습니다.');
      return;
    }
    
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
        },
      );
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('보상 획득: ${reward.type} ${reward.amount}');
        },
      );
    } else {
      print('보상형 광고가 로드되지 않았습니다.');
    }
  }
} 