# Petmily - 반려동물 관리 앱

Petmily는 반려동물을 더 쉽게 관리할 수 있도록 도와주는 모바일 애플리케이션입니다.

## 기능

- 반려동물 정보 등록 및 관리
- 반려동물 목록 조회
- 반려동물 상세 정보 보기
- 반려동물 사진 업로드

## 기술 스택

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: Go Router
- **HTTP Client**: http package
- **Local Storage**: Shared Preferences

## 개발 환경 설정

### 필수 요구사항

- Flutter SDK (3.0.6 이상)
- Android Studio / VS Code
- Android SDK (안드로이드 개발용)

### 설치 및 실행

1. 의존성 설치:
```bash
flutter pub get
```

2. 앱 실행:
```bash
flutter run
```

3. 안드로이드 에뮬레이터 또는 실제 기기에서 테스트

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── models/                # 데이터 모델
│   └── pet.dart          # 반려동물 모델
├── providers/             # 상태 관리
│   └── pet_provider.dart # 반려동물 상태 관리
├── screens/               # 화면
│   ├── home_screen.dart  # 홈 화면
│   ├── pet_list_screen.dart # 반려동물 목록
│   └── add_pet_screen.dart # 반려동물 등록
├── widgets/               # 재사용 가능한 위젯
│   └── pet_card.dart     # 반려동물 카드
├── services/              # API 서비스 (예정)
└── utils/                 # 유틸리티 함수 (예정)
```

## 백엔드 API

이 앱은 Node.js 백엔드 API와 연동됩니다. 백엔드 프로젝트는 별도로 관리됩니다.

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.
