import 'package:flutter/material.dart';
import '../api_service.dart';
import '../constants/themes.dart';
import 'booking_form_screen.dart';
import 'review_form_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  final String email;
  final String username;

  const RoomDetailScreen({super.key, required this.room, required this.email, required this.username});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Map<String, dynamic> _room = widget.room;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom({bool silent = false}) async {
    final roomId = _room['id'];
    if (roomId == null) return;

    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    final result = await ApiService.getRoom(roomId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _room = Map<String, dynamic>.from(result['room']);
      } else {
        _error = result['message'] ?? 'Gagal mengambil detail kamar';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = List<Map<String, dynamic>>.from(_room['images'] ?? []);
    final facilities = List<Map<String, dynamic>>.from(
      _room['facilities'] ?? [],
    );
    final reviews = List<Map<String, dynamic>>.from(_room['reviews'] ?? []);
    final imageUrl = images.isNotEmpty
        ? images.first['image_url']
        : (_room['hotel']?['thumbnail'] ??
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
    final rating = (_room['average_rating'] ?? 0).toString();
    final reviewCount = (_room['review_count'] ?? reviews.length).toString();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : RefreshIndicator(
                onRefresh: _loadRoom,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 28),
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28),
                          ),
                          child: Image.network(
                            imageUrl,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(height: 280, color: Colors.white12),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_error != null)
                            _ErrorBox(message: _error!, onRetry: _loadRoom),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _room['room_name'] ?? 'Room',
                                      style: AppTextStyle.heading,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _room['hotel']?['name'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating ($reviewCount)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _room['description'] ??
                                'Kamar nyaman untuk liburan dan perjalanan bisnis.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: facilities.isEmpty
                                ? [
                                    _FacilityChip(name: 'Wifi'),
                                    _FacilityChip(name: 'Breakfast'),
                                    _FacilityChip(name: 'AC'),
                                  ]
                                : facilities
                                      .map(
                                        (facility) => _FacilityChip(
                                          name: facility['name'] ?? '-',
                                        ),
                                      )
                                      .toList(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatPrice(_room['price_per_night'] ?? 0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingFormScreen(
                                        room: _room,
                                        email: widget.email,
                                        username: widget.username,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Select Room'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (reviews.isEmpty)
                            Text(
                              'Belum ada review untuk kamar ini.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            )
                          else
                            ...reviews.map(
                              (review) => _ReviewCard(
                                review: review,
                                currentEmail: widget.email,
                                onEdit: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReviewFormScreen(
                                        booking: Map<String, dynamic>.from(review['booking'] ?? {}),
                                        email: widget.email,
                                        review: Map<String, dynamic>.from(review),
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (updated == true) {
                                    _loadRoom(silent: true);
                                  }
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.primaryBg,
                                      title: const Text('Delete Review', style: TextStyle(color: Colors.white)),
                                      content: const Text('Are you sure you want to delete this review?', style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (confirm == true) {
                                    final res = await ApiService.deleteReview(
                                      email: widget.email,
                                      reviewId: review['id'],
                                    );
                                    if (!context.mounted) return;
                                    if (res['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Review deleted!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _loadRoom(silent: true);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res['message'] ?? 'Gagal menghapus review'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatPrice(dynamic value) {
    final price = int.tryParse(value.toString()) ?? 0;
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }
}

class _FacilityChip extends StatelessWidget {
  final String name;
  const _FacilityChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final String currentEmail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.review,
    required this.currentEmail,
    this.onEdit,
    this.onDelete,
  });

  String _getPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final uri = Uri.parse(ApiService.baseUrl);
    final host = '${uri.scheme}://${uri.host}:${uri.port}';
    return '$host$path';
  }

  @override
  Widget build(BuildContext context) {
    final isOwnReview = review['user']?['email'] == currentEmail;
    final photo = review['photo'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review['user']?['name'] ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              Text(
                '${review['rating']}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          if ((review['comment'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review['comment'],
              style: TextStyle(color: Colors.white.withOpacity(0.72)),
            ),
          ],
          if (photo != null && photo.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _getPhotoUrl(photo),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ],
          if (isOwnReview) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton.icon(
                //   onPressed: onEdit,
                //   icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.blueAccent),
                //   label: const Text('Edit', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                // ),
                // const SizedBox(width: 8),
                // TextButton.icon(
                //   onPressed: onDelete,
                //   icon: const Icon(Icons.delete_rounded, size: 16, color: Colors.redAccent),
                //   label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                // ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
