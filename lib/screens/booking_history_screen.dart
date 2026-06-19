import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../constants/themes.dart';
import 'review_form_screen.dart';
import 'booking_form_screen.dart';
import 'booking_success_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String email;
  final String username;

  const BookingHistoryScreen({super.key, required this.email, required this.username});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  static const _tabs = ['pending', 'paid', 'completed', 'cancelled'];
  String _status = 'pending';
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];
  
  List<String> _bannedReviewIds = [];

  @override
  void initState() {
    super.initState();
    _bannedReviewIds.clear();
    _loadBannedReviews().then((_) => _loadBookings());
  }

  Future<void> _loadBannedReviews() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bannedReviewIds = prefs.getStringList('banned_reviews_list') ?? [];
    });
  }

  Future<void> _saveBannedReview(int reviewId) async {
    final prefs = await SharedPreferences.getInstance();
    final idStr = reviewId.toString();
    if (!_bannedReviewIds.contains(idStr)) {
      _bannedReviewIds.add(idStr);
      await prefs.setStringList('banned_reviews_list', _bannedReviewIds);
      setState(() {});
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ApiService.getBookings(widget.email, status: _status);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _bookings = List<Map<String, dynamic>>.from(result['bookings'] ?? []);
      } else {
        _error = result['message'] ?? 'Gagal mengambil history booking';
      }
    });
  }

  Future<void> _cancel(Map<String, dynamic> booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBg,
        title: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to cancel this booking?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await ApiService.cancelBooking(
      email: widget.email,
      bookingId: booking['id'],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              (result['success'] == true ? 'Booking dibatalkan' : 'Gagal membatalkan booking'),
        ),
        backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
    if (result['success'] == true) _loadBookings();
  }

  Future<void> _payNow(Map<String, dynamic> booking) async {
    setState(() {
      _isLoading = true;
    });
    final result = await ApiService.updateBooking(
      email: widget.email,
      bookingId: booking['id'],
      paymentStatus: 'paid',
      status: 'paid',
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              (result['success'] == true ? 'Pembayaran berhasil!' : 'Gagal melakukan pembayaran'),
        ),
        backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
    if (result['success'] == true) _loadBookings();
  }

  Future<void> _editBooking(Map<String, dynamic> booking) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormScreen(
          email: widget.email,
          username: widget.username,
          booking: booking,
        ),
      ),
    );
    if (updated == true) _loadBookings();
  }

  Future<void> _review(Map<String, dynamic> booking) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(booking: booking, email: widget.email),
      ),
    );
    if (created == true) _loadBookings();
  }

  Future<void> _deleteReview(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBg,
        title: const Text('Hapus Review', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus review ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    final result = await ApiService.deleteReview(
      email: widget.email,
      reviewId: bookingId,
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? (result['success'] == true ? 'Review berhasil dihapus' : 'Gagal menghapus review')),
        backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
    if (result['success'] == true) _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text('Booking History', style: AppTextStyle.heading),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final selected = tab == _status;
                  return InkWell(
                    onTap: () {
                      setState(() => _status = tab);
                      _loadBookings();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tab[0].toUpperCase() + tab.substring(1),
                          style: TextStyle(
                            color: selected ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(onRefresh: _loadBookings, child: _body()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StateCard(message: _error!, actionText: 'Retry', onAction: _loadBookings),
        ],
      );
    }

    if (_bookings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StateCard(
            message: 'Belum ada booking ${_status.toLowerCase()}.',
            actionText: 'Refresh',
            onAction: _loadBookings,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _bookings.length,
      itemBuilder: (context, index) => _BookingCard(
        booking: _bookings[index],
        email: widget.email,
        username: widget.username,
        bannedReviewIds: _bannedReviewIds,
        onCancel: () => _cancel(_bookings[index]),
        onReview: () => _review(_bookings[index]),
        onDeleteReview: () => _deleteReview(_bookings[index]['id']),
        onEdit: () => _editBooking(_bookings[index]),
        onMarkAsEdited: (id) => _saveBannedReview(id),
        onRefreshHistory: _loadBookings,
        onPay: () => _payNow(_bookings[index]), 
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String email;
  final String username; 
  final List<String> bannedReviewIds;
  final VoidCallback onCancel;
  final VoidCallback onReview;
  final VoidCallback onDeleteReview;
  final VoidCallback onEdit;
  final VoidCallback onPay; // Register parameter pay
  final Function(int) onMarkAsEdited;
  final VoidCallback onRefreshHistory;

  const _BookingCard({
    required this.booking,
    required this.email,
    required this.username, 
    required this.bannedReviewIds,
    required this.onCancel,
    required this.onReview,
    required this.onDeleteReview,
    required this.onEdit,
    required this.onPay,
    required this.onMarkAsEdited,
    required this.onRefreshHistory,
  });

  @override
  Widget build(BuildContext context) {
    final room = booking['room'] ?? {};
    
    final String currentStatus = (booking['status'] ?? '').toString().toLowerCase();
    final bool hasReview = booking['review'] != null && 
                           booking['review'].toString() != 'null' && 
                           booking['review'].toString().trim().isNotEmpty && 
                           booking['review'].toString() != '[]';
    
    final canReview = currentStatus == 'completed' && !hasReview;
    
    final int reviewId = hasReview ? (int.tryParse(booking['review']['id'].toString()) ?? 0) : 0;
    final bool isAlreadyEdited = bannedReviewIds.contains(reviewId.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: currentStatus == 'completed'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSuccessScreen(
                      booking: Map<String, dynamic>.from(booking),
                      username: username,
                      email: email,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: canReview ? Colors.amber.withOpacity(0.55) : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['hotel']?['name'] ?? '-',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room['room_name'] ?? '-',
                          style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (canReview)
                    InkWell(
                      onTap: onReview,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(color: AppColors.primaryBg, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (currentStatus == 'completed' && hasReview) ...[
                    if (!isAlreadyEdited)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit_rounded, color: Colors.lightBlueAccent, size: 22),
                        onPressed: () async {
                          final proceed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.primaryBg,
                              title: const Text('Peringatan Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              content: const Text(
                                'Anda hanya memiliki kesempatan mengedit review ini sebanyak 1 kali. Apakah Anda ingin melanjutkan?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Lanjutkan', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (proceed == true) {
                            if (!context.mounted) return;
                            Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewFormScreen(
                                  booking: booking,
                                  email: email,
                                  review: booking['review'],
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                onMarkAsEdited(reviewId);
                                onRefreshHistory();
                              }
                            });
                          }
                        },
                      ),
                    if (!isAlreadyEdited) const SizedBox(width: 14),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22),
                      onPressed: onDeleteReview,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${booking['check_in']} - ${booking['check_out']}',
                style: TextStyle(color: Colors.white.withOpacity(0.72)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatPrice(booking['total_price'] ?? 0),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    booking['status'] ?? '-',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              
              // === BALIKIN TOMBOL PENDING SAKRAL YANG KETINGGALAN ===
              if (currentStatus == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: onEdit,
                      child: const Text('Edit Booking', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: onCancel,
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      ),
                      onPressed: onPay,
                      child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
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

class _StateCard extends StatelessWidget {
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const _StateCard({required this.message, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}