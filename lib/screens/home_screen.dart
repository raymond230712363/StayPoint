import 'package:flutter/material.dart';
import '../constants/themes.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username}); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Hotel', 'Resort', 'Villa', 'Apartment'];
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _popularHotels = [
    {
      'name': 'Hill Side Villa',
      'location': 'W A Silva mawatha, Colombo 06',
      'price': 'Rp 600.000',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80',
    },
    {
      'name': 'Apurva Kempinski',
      'location': 'HR Muhammad, Surabaya',
      'price': 'Rp 500.000',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&q=80',
    },
  ];

  // ==================== DATA DUMMY BARU: NEARBY HOTELS (Vertikal) ====================
  final List<Map<String, dynamic>> _nearbyHotels = [
    {
      'name': 'Kandy Palace',
      'location': 'Sitimulyo, Yogyakarta',
      'price': 'Rp 450.000',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=500&q=80',
    },
    {
      'name': 'Madiun Garden Hotel',
      'location': 'Pahlawan Street, Madiun',
      'price': 'Rp 350.000',
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              // ==================== 1. HEADER SECTION (Sesuai Figma Baru) ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Lokasi & Ikon Atas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dropdown Lokasi Kiri
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Babarsari', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        // Ikon Chat & Lonceng Kanan
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 16),
                            Stack(
                              children: [
                                Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Teks Sapaan Dinamis
                    Text(
                      'Hi, ${widget.username}', 
                      style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 16),
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

              // ==================== 2. SEARCH BAR ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white.withAlpha(150)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search your hotel...',
                            hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.tune_rounded, color: Colors.white.withAlpha(150)),
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
              
              // Card List Hotel Horizontal (Popular)
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _popularHotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _popularHotels[index];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gambar Hotel
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                                child: Image.network(
                                  hotel['image'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Detail Singkat Bawah
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
                                        Icon(Icons.location_on_rounded, color: Colors.white.withAlpha(120), size: 12),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            hotel['location'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Fasilitas Ringkas ala Figma
                                    Row(
                                      children: [
                                        Icon(Icons.king_bed_rounded, color: Colors.white.withAlpha(150), size: 14),
                                        const SizedBox(width: 2),
                                        Text('2 beds', style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10)),
                                        const SizedBox(width: 10),
                                        Icon(Icons.wifi, color: Colors.white.withAlpha(150), size: 14),
                                        const SizedBox(width: 2),
                                        Text('wifi', style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          // Badge Harga di Atas Gambar
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                              child: Text('${hotel['price']}/Day', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          // Tombol Love/Favorite Kanan Atas
                          Positioned(
                            right: 12,
                            top: 12,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black38,
                              child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ==================== NEARBY HOTELS (Vertikal) ====================
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
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: _nearbyHotels.length,
                itemBuilder: (context, index) {
                  final hotel = _nearbyHotels[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                    ),
                    child: Row(
                      children: [
                        // Foto Hotel Kotak Kiri
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
                        // Detail Tengah
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
                                  Icon(Icons.location_on_rounded, color: Colors.white.withAlpha(120), size: 12),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hotel['location'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 12),
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

                        // Rating Bintang Kanan Atas
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
                        )
                      ],
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