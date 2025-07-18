import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../widgets/banner_ad_widget.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _selectedCategory = 'hospital';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'hospital',
      'name': '병원',
      'icon': '🏥',
      'color': Colors.red,
    },
    {
      'id': 'store',
      'name': '용품점',
      'icon': '🛍️',
      'color': Colors.blue,
    },
    {
      'id': 'park',
      'name': '산책코스',
      'icon': '🌳',
      'color': Colors.green,
    },
    {
      'id': 'hotel',
      'name': '호텔/케어',
      'icon': '🏨',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Move camera to current position
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 가져올 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 탐색'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: '홈으로',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['id'];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                      _searchNearbyPlaces(category['name']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? category['color'].withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? category['color']
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category['icon'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              color: isSelected 
                                  ? category['color']
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Map Placeholder
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '지도 영역',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Google Maps API 키 설정 후\n실제 지도가 표시됩니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Sample places
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '주변 ${_getCategoryDisplayName(_selectedCategory)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildSamplePlace('행복한 동물병원', '반려동물 전문 진료', '🏥'),
                                const SizedBox(height: 8),
                                _buildSamplePlace('펫마트', '반려동물 용품 전문점', '🛍️'),
                                const SizedBox(height: 8),
                                _buildSamplePlace('반려동물 공원', '산책하기 좋은 공원', '🌳'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
          // Ad Banner
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Set<Marker> _getMarkers() {
    Set<Marker> markers = {};
    
    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: '현재 위치',
            snippet: '여기에 있습니다',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Add sample nearby places (in real app, these would come from API)
    _getSamplePlaces().forEach((place) {
      markers.add(
        Marker(
          markerId: MarkerId(place['id']),
          position: LatLng(place['lat'], place['lng']),
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['address'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getCategoryColor(place['category']),
          ),
        ),
      );
    });

    return markers;
  }

  List<Map<String, dynamic>> _getSamplePlaces() {
    if (_currentPosition == null) return [];

    // Sample places around current location
    return [
      {
        'id': 'hospital1',
        'name': '행복한 동물병원',
        'address': '반려동물 전문 진료',
        'lat': _currentPosition!.latitude + 0.001,
        'lng': _currentPosition!.longitude + 0.001,
        'category': 'hospital',
      },
      {
        'id': 'store1',
        'name': '펫마트',
        'address': '반려동물 용품 전문점',
        'lat': _currentPosition!.latitude - 0.001,
        'lng': _currentPosition!.longitude + 0.002,
        'category': 'store',
      },
      {
        'id': 'park1',
        'name': '반려동물 공원',
        'address': '산책하기 좋은 공원',
        'lat': _currentPosition!.latitude + 0.002,
        'lng': _currentPosition!.longitude - 0.001,
        'category': 'park',
      },
    ];
  }

  double _getCategoryColor(String category) {
    switch (category) {
      case 'hospital':
        return BitmapDescriptor.hueRed;
      case 'store':
        return BitmapDescriptor.hueBlue;
      case 'park':
        return BitmapDescriptor.hueGreen;
      case 'hotel':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  void _searchNearbyPlaces(String category) {
    // TODO: Implement actual search using Google Places API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('주변 $category 검색 중...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'hospital':
        return '병원';
      case 'store':
        return '용품점';
      case 'park':
        return '산책코스';
      case 'hotel':
        return '호텔/케어';
      default:
        return category;
    }
  }

  Widget _buildSamplePlace(String name, String description, String icon) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }
} 