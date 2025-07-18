import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load pets when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    // TODO: Implement actual ad loading when AdMob is set up
    // _bannerAd = BannerAd(
    //   adUnitId: _getBannerAdUnitId(),
    //   size: AdSize.banner,
    //   request: const AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (ad) {
    //       setState(() {
    //         _isAdLoaded = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //     },
    //   ),
    // );
    // _bannerAd!.load();
  }

  String _getBannerAdUnitId() {
    // Test ad unit ID - replace with your actual ad unit ID
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Petmily',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (petProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    petProvider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => petProvider.loadPets(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (petProvider.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '아직 등록된 Petmily가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '새로운 Petmily를 등록해보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/add-pet'),
                    icon: const Icon(Icons.add),
                    label: const Text('새 Petmily 등록'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '안녕하세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${petProvider.pets.length}마리의 반려동물과 함께하고 있어요',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                                const Text(
                        'My Petmily',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/add-pet'),
                            icon: const Text('🐾', style: TextStyle(fontSize: 16)),
                            label: const Text(
                              '새 가족',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: petProvider.pets.length,
                                itemBuilder: (context, index) {
                                  final pet = petProvider.pets[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: PetCard(pet: pet),
                                  );
                                },
                              ),
                            ),
                            // Ad Banner removed - using new home screen
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Floating action button removed - moved to top right
    );
  }
} 