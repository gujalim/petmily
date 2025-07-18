# Petmily Backend API

Petmily 반려동물 관리 앱의 백엔드 API 서버입니다.

## 기능

- 반려동물 정보 CRUD 작업
- RESTful API 제공
- MongoDB 데이터베이스 연동

## 기술 스택

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (Mongoose)
- **Authentication**: JWT (예정)
- **File Upload**: Multer (예정)

## 개발 환경 설정

### 필수 요구사항

- Node.js (16.x 이상)
- npm 또는 yarn
- MongoDB (로컬 또는 클라우드)

### 설치 및 실행

1. 의존성 설치:
```bash
npm install
```

2. 환경 변수 설정:
`.env` 파일을 생성하고 다음 내용을 추가하세요:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/petmily
JWT_SECRET=your_jwt_secret_key_here
NODE_ENV=development
```

3. 개발 서버 실행:
```bash
npm run dev
```

4. 프로덕션 서버 실행:
```bash
npm start
```

## API 엔드포인트

### 반려동물 관리

- `GET /api/pets` - 모든 반려동물 조회
- `GET /api/pets/:id` - 특정 반려동물 조회
- `POST /api/pets` - 새로운 반려동물 등록
- `PUT /api/pets/:id` - 반려동물 정보 수정
- `DELETE /api/pets/:id` - 반려동물 삭제

### 헬스 체크

- `GET /health` - 서버 상태 확인

## 프로젝트 구조

```
petmily-backend/
├── server.js              # 서버 진입점
├── routes/                # API 라우트
│   └── pets.js           # 반려동물 관련 라우트
├── models/                # 데이터베이스 모델 (예정)
├── middleware/            # 미들웨어 (예정)
├── controllers/           # 컨트롤러 (예정)
└── package.json           # 프로젝트 설정
```

## 데이터베이스 스키마

### Pet (반려동물)

```javascript
{
  id: String,
  name: String,
  species: String, // dog, cat, bird, fish, etc.
  breed: String,
  birthDate: Date,
  imageUrl: String,
  weight: Number,
  gender: String, // male, female
  microchipId: String,
  createdAt: Date,
  updatedAt: Date
}
```

## 개발 가이드

### 새로운 라우트 추가

1. `routes/` 폴더에 새 라우트 파일 생성
2. `server.js`에서 라우트 등록
3. API 문서 업데이트

### 데이터베이스 모델 추가

1. `models/` 폴더에 Mongoose 스키마 생성
2. 라우트에서 모델 사용
3. 마이그레이션 스크립트 작성 (필요시)

## 배포

### 환경 변수

프로덕션 환경에서는 다음 환경 변수를 설정하세요:

- `PORT`: 서버 포트
- `MONGODB_URI`: MongoDB 연결 문자열
- `JWT_SECRET`: JWT 시크릿 키
- `NODE_ENV`: 환경 설정 (production)

### Docker 배포 (예정)

```bash
docker build -t petmily-backend .
docker run -p 3000:3000 petmily-backend
```

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 