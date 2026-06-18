import 'package:flutter/material.dart';
import '../api_service.dart';
import '../constants/themes.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String email;

  const HomeScreen({super.key, required this.username, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = [
    'All',
    'Hotel',
    'Resort',
    'Villa',
    'Apartment',
  ];
  int _selectedCategoryIndex = 0;

  // === 1. DEKLARASI FALLBACK DATA BIAR REGION UNDER VERTIVAL GAK ERROR UNDEFINED ===
  final List<Map<String, dynamic>> _popularHotelsFallback = [];
  final List<Map<String, dynamic>> _nearbyHotelsFallback = [];

  bool _isLoadingHotels = false;
  String? _hotelError;
  List<Map<String, dynamic>> _apiHotels = [];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoadingHotels = true;
      _hotelError = null;
    });

    final result = await ApiService.getHotels();
    if (!mounted) return;
    setState(() {
      _isLoadingHotels = false;
      if (result['success'] == true) {
        _apiHotels = _mapHotels(
          List<Map<String, dynamic>>.from(result['hotels'] ?? []),
        );
      } else {
        _hotelError = result['message'] ?? 'Gagal mengambil hotel';
      }
    });
  }

  List<Map<String, dynamic>> _mapHotels(List<Map<String, dynamic>> hotels) {
    return hotels.map((hotel) {
      final rooms = List<Map<String, dynamic>>.from(hotel['rooms'] ?? []);
      final room = rooms.isNotEmpty ? rooms.first : <String, dynamic>{};
      final images = List<Map<String, dynamic>>.from(room['images'] ?? []);
      return {
        'name': hotel['name'] ?? '-',
        'location': hotel['location'] ?? '-',
        'price': _formatPrice(room['price_per_night'] ?? 0),
        'rating': room['average_rating'] ?? 0,
        'image': hotel['thumbnail'] ??
            (images.isNotEmpty
                ? images.first['image_url']
                : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80'),
        'room': room,
      };
    }).toList();
  }

  void _openRoom(Map<String, dynamic> hotel) {
    final room = hotel['room'];
    if (room is! Map<String, dynamic> || room['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room belum tersedia untuk hotel ini.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailScreen(room: room, email: widget.email, username: widget.username),
      ),
    );
  }

  String _formatPrice(dynamic value) {
    final price = int.tryParse(value.toString()) ?? 0;
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // === 2. SINKRONKAN VARIABLE DENGAN FALLBACK YANG SUDAH DIDEKLARASIKAN ===
    final popularHotels = _apiHotels.isNotEmpty ? _apiHotels : _popularHotelsFallback;
    final nearbyHotels = _apiHotels.length > 2
        ? _apiHotels.skip(2).toList()
        : _nearbyHotelsFallback;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ==================== HEADER SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Babarsari',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 16),
                            Stack(
                              children: [
                                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hi, ${widget.username}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Lets find the best hotels\naround the world",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== SEARCH BAR ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search your hotel...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.tune_rounded, color: Colors.white.withOpacity(0.6)),
                    ],
                  ),
                ),
              ),
              if (_isLoadingHotels)
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: LinearProgressIndicator(color: Colors.white),
                )
              else if (_hotelError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_hotelError!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        TextButton(onPressed: _loadHotels, child: const Text('Retry')),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),

              // ==================== POPULAR HOTELS SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular hotels',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 280,
                child: popularHotels.isEmpty
                    ? Center(child: Text("Belum ada hotel populer di database", style: TextStyle(color: Colors.white.withOpacity(0.5))))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: popularHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = popularHotels[index];
                          return InkWell(
                            onTap: () => _openRoom(hotel),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 220,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                                        child: Image.network(
                                          hotel['image'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hotel['name'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_rounded, color: Colors.white.withOpacity(0.5), size: 12),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    hotel['location'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.king_bed_rounded, color: Colors.white.withOpacity(0.6), size: 14),
                                                const SizedBox(width: 2),
                                                Text('2 beds', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                                const SizedBox(width: 10),
                                                Icon(Icons.wifi, color: Colors.white.withOpacity(0.6), size: 14),
                                                const SizedBox(width: 2),
                                                Text('wifi', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                                      child: Text(
                                        '${hotel['price']}/Day',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black38,
                                      child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

              // ==================== NEARBY HOTELS SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby hotels',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              nearbyHotels.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text("Belum ada hotel terdekat di database", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: nearbyHotels.length,
                      itemBuilder: (context, index) {
                        final hotel = nearbyHotels[index];
                        return InkWell(
                          onTap: () => _openRoom(hotel),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    hotel['image'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel['name'],
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_rounded, color: Colors.white.withOpacity(0.5), size: 12),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hotel['location'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${hotel['price']}/Day',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          hotel['rating'].toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}