# Petmily 앱 배포 가이드

## 1. 비용 효율적인 클라우드 서비스 옵션

### 백엔드 서비스 (무료 티어 포함)

#### Firebase (Google)
- **Firestore Database**: 1GB 저장소, 50,000 읽기/일, 20,000 쓰기/일 무료
- **Authentication**: 무제한 사용자 인증
- **Cloud Storage**: 5GB 무료 저장소 (이미지 저장용)
- **Cloud Functions**: 125,000 호출/월 무료
- **Hosting**: 무료 (웹 버전)

**월 예상 비용**: $0 (초기 단계), $25-50 (사용자 증가 시)

#### Supabase (PostgreSQL 기반)
- **Database**: 500MB 무료
- **Authentication**: 무제한
- **Storage**: 1GB 무료
- **Edge Functions**: 500,000 호출/월 무료

**월 예상 비용**: $0 (초기 단계), $25 (성장 시)

#### PlanetScale (MySQL 기반)
- **Database**: 1GB 무료, 무제한 브랜치
- **Connection**: 1,000 연결/월 무료

**월 예상 비용**: $0 (초기 단계), $29 (성장 시)

### 이미지 저장소

#### Cloudinary
- **무료 티어**: 25 크레딧/월 (약 25GB 저장소)
- **기능**: 자동 이미지 최적화, 리사이징

#### AWS S3 + CloudFront
- **S3**: 5GB 무료
- **CloudFront**: 1TB 전송 무료

## 2. Google Play Store 배포 가이드

### 1단계: 개발자 계정 등록
1. [Google Play Console](https://play.google.com/console) 접속
2. $25 일회성 등록비 결제
3. 개발자 계정 정보 입력

### 2단계: 앱 준비
```bash
# 앱 서명 키 생성
keytool -genkey -v -keystore petmily-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias petmily

# 앱 빌드
flutter build appbundle --release
```

### 3단계: 앱 정보 설정
- **앱 이름**: Petmily
- **패키지명**: com.yourcompany.petmily
- **버전**: 1.0.0
- **최소 SDK**: API 21 (Android 5.0)

### 4단계: 스토어 등록 정보
- **앱 설명**: "귀여운 반려동물 관리 앱"
- **스크린샷**: 2-8장 (다양한 화면)
- **아이콘**: 512x512 PNG
- **분류**: 생활/라이프스타일

### 5단계: 개인정보 처리방침
- [App Privacy Policy Generator](https://app-privacy-policy-generator.firebaseapp.com/) 사용
- 웹사이트에 정책 페이지 호스팅

## 3. iOS App Store 배포 (선택사항)

### 요구사항
- Apple Developer Program ($99/년)
- Mac 컴퓨터 (Xcode 필요)
- iOS 앱 빌드 및 테스트

### 단계
1. Apple Developer 계정 등록
2. Xcode에서 iOS 앱 빌드
3. App Store Connect에서 앱 등록
4. 심사 제출 및 승인 대기

## 4. 수익화 전략

### 광고 수익
- **AdMob**: Google의 모바일 광고 플랫폼
- **Facebook Audience Network**: 소셜 미디어 광고
- **Unity Ads**: 게임 광고 네트워크

### 프리미엄 기능
- **무료 버전**: 기본 Petmily 관리 (3마리까지)
- **프리미엄 버전**: 무제한, 고급 기능
  - 건강 기록 관리
  - 수의사 상담 연결
  - 반려동물 보험 정보
  - 고급 통계 및 분석

### 구독 모델
- **월 $2.99**: 프리미엄 기능
- **년 $24.99**: 30% 할인

## 5. 마케팅 전략

### 소셜 미디어
- Instagram: 귀여운 반려동물 사진과 앱 기능
- TikTok: 짧은 앱 사용 영상
- YouTube: 앱 리뷰 및 사용법

### 인플루언서 협업
- 반려동물 전문 인플루언서
- 펫샵 및 동물병원 파트너십

### ASO (App Store Optimization)
- 키워드 최적화: "반려동물", "펫 관리", "강아지", "고양이"
- 리뷰 및 평점 관리
- 정기적인 업데이트

## 6. 예상 비용 및 수익

### 초기 개발 비용
- **개발자 계정**: $25 (Google Play)
- **클라우드 서비스**: $0-50/월
- **마케팅**: $100-500/월

### 예상 수익 (1년 후)
- **다운로드**: 10,000-50,000
- **광고 수익**: $100-500/월
- **프리미엄 구독**: $200-1,000/월
- **총 수익**: $3,600-18,000/년

## 7. 다음 단계

1. **백엔드 구현**: Firebase/Supabase 선택 및 설정
2. **이미지 업로드**: Cloudinary 연동
3. **푸시 알림**: 건강 관리 알림 기능
4. **소셜 기능**: Petmily 커뮤니티
5. **AI 기능**: 반려동물 건강 분석
6. **IoT 연동**: 스마트 피더, 카메라 연동

## 8. 기술 스택 권장사항

### 현재 (로컬 저장소)
- Flutter + SharedPreferences
- Provider 상태 관리

### 다음 단계 (클라우드)
- Flutter + Firebase
- Cloud Firestore (데이터베이스)
- Firebase Auth (인증)
- Cloud Storage (이미지)
- Cloud Functions (서버리스)

### 고급 기능
- Flutter + Supabase
- PostgreSQL (고급 쿼리)
- Real-time subscriptions
- Row Level Security 