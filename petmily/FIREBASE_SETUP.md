# Firebase 설정 가이드

## 1. Firebase 프로젝트 생성

### 1단계: Firebase Console 접속
1. [Firebase Console](https://console.firebase.google.com/) 접속
2. Google 계정으로 로그인

### 2단계: 새 프로젝트 생성
1. "프로젝트 추가" 클릭
2. 프로젝트 이름: `petmily-app`
3. Google Analytics 활성화 (선택사항)
4. "프로젝트 만들기" 클릭

### 3단계: 앱 등록
1. 웹 앱 추가: `</>` 아이콘 클릭
2. 앱 닉네임: `Petmily Web`
3. "앱 등록" 클릭

## 2. Firebase 설정 파일

### 웹 설정
Firebase Console에서 제공하는 설정을 `lib/firebase_options.dart`에 저장:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.petmily',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.petmily',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
  );
}
```

## 3. Firebase 서비스 활성화

### Authentication
1. Firebase Console → Authentication
2. "시작하기" 클릭
3. "이메일/비밀번호" 제공업체 활성화
4. "저장" 클릭

### Firestore Database
1. Firebase Console → Firestore Database
2. "데이터베이스 만들기" 클릭
3. 보안 규칙: "테스트 모드에서 시작" 선택
4. 위치: `asia-northeast3 (서울)` 선택
5. "완료" 클릭

### Storage
1. Firebase Console → Storage
2. "시작하기" 클릭
3. 보안 규칙: "테스트 모드에서 시작" 선택
4. 위치: `asia-northeast3 (서울)` 선택
5. "완료" 클릭

## 4. 보안 규칙 설정

### Firestore 보안 규칙
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자별 데이터 접근 규칙
    match /users/{userId}/pets/{petId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 사용자 프로필 접근 규칙
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage 보안 규칙
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 사용자별 이미지 접근 규칙
    match /users/{userId}/pets/{petId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 5. 앱에서 Firebase 설정 업데이트

### main.dart 수정
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const PetmilyApp());
}
```

## 6. 환경 변수 설정 (선택사항)

### .env 파일 생성
```
FIREBASE_API_KEY=your-api-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_APP_ID=your-app-id
```

## 7. 테스트

### 로컬 테스트
```bash
flutter run -d chrome
```

### 배포 테스트
```bash
flutter build web
firebase deploy
```

## 8. 모니터링 및 분석

### Firebase Analytics
1. Firebase Console → Analytics
2. 이벤트 추적 설정
3. 사용자 행동 분석

### Firebase Crashlytics
1. Firebase Console → Crashlytics
2. 앱 크래시 모니터링
3. 성능 최적화

## 9. 비용 관리

### 무료 티어 한도
- **Firestore**: 1GB 저장소, 50,000 읽기/일, 20,000 쓰기/일
- **Storage**: 5GB 저장소, 1GB 다운로드/일
- **Authentication**: 무제한 사용자
- **Hosting**: 10GB 저장소, 360MB/일 전송

### 예상 비용 (사용자 증가 시)
- **1,000 사용자**: $0-25/월
- **10,000 사용자**: $25-100/월
- **100,000 사용자**: $100-500/월

## 10. 보안 체크리스트

- [ ] Authentication 활성화
- [ ] Firestore 보안 규칙 설정
- [ ] Storage 보안 규칙 설정
- [ ] API 키 보안 설정
- [ ] 도메인 제한 설정
- [ ] HTTPS 강제 설정
- [ ] 정기적인 보안 감사 