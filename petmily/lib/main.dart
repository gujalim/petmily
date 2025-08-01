import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';

import 'screens/new_home_screen.dart';
import 'screens/pet_list_screen.dart';
import 'screens/add_pet_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/edit_pet_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/health_check_screen.dart';
import 'screens/health_history_screen.dart';
import 'providers/pet_provider.dart';
import 'providers/auth_provider.dart';
import 'models/pet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 성공');
  } catch (e) {
    print('Firebase 초기화 실패 (로컬 모드로 실행): $e');
  }
  
  // 광고 초기화
  try {
    await AdService.initialize();
    print('광고 초기화 성공');
  } catch (e) {
    print('광고 초기화 실패: $e');
  }

  // 국제화 초기화
  try {
    await initializeDateFormatting('ko_KR', null);
    print('국제화 초기화 성공');
  } catch (e) {
    print('국제화 초기화 실패: $e');
  }
  
  runApp(const PetmilyApp());
}

class PetmilyApp extends StatelessWidget {
  const PetmilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = PetProvider();
            // 앱 시작 시 데이터 로드
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadPets();
            });
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'Petmily',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF48FB1), // 연한 핑크
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const NewHomeScreen(),
    ),
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetListScreen(),
    ),
    GoRoute(
      path: '/add-pet',
      builder: (context, state) => const AddPetScreen(),
    ),
    GoRoute(
      path: '/nearby',
      builder: (context, state) => const NearbyScreen(),
    ),
    GoRoute(
      path: '/health-check/:petId',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        final pet = petProvider.getPetById(petId);
        
        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text('Petmily를 찾을 수 없습니다.'),
            ),
          );
        }
        
        return HealthCheckScreen(pet: pet);
      },
    ),
    GoRoute(
      path: '/health-history/:petId',
      builder: (context, state) {
        final petId = state.pathParameters['petId']!;
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        final pet = petProvider.getPetById(petId);
        
        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text('Petmily를 찾을 수 없습니다.'),
            ),
          );
        }
        
        return HealthHistoryScreen(pet: pet);
      },
    ),
    GoRoute(
      path: '/pet/:id',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        final pet = petProvider.getPetById(petId);
        
        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text('Petmily를 찾을 수 없습니다.'),
            ),
          );
        }
        
        return PetDetailScreen(pet: pet);
      },
    ),
    GoRoute(
      path: '/edit-pet/:id',
      builder: (context, state) {
        final petId = state.pathParameters['id']!;
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        final pet = petProvider.getPetById(petId);
        
        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text('Petmily를 찾을 수 없습니다.'),
            ),
          );
        }
        
        return EditPetScreen(pet: pet);
      },
    ),
  ],
);
