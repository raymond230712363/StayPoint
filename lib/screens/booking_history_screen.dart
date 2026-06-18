import 'package:flutter/material.dart';
import '../api_service.dart';
import '../constants/themes.dart';
import 'review_form_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String email;

  const BookingHistoryScreen({super.key, required this.email});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  static const _tabs = ['pending', 'paid', 'completed', 'cancelled'];
  String _status = 'pending';
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
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
    final result = await ApiService.cancelBooking(
      email: widget.email,
      bookingId: booking['id'],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              (result['success'] == true
                  ? 'Booking dibatalkan'
                  : 'Gagal membatalkan booking'),
        ),
        backgroundColor: result['success'] == true
            ? Colors.green
            : Colors.redAccent,
      ),
    );
    if (result['success'] == true) _loadBookings();
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
                  return ChoiceChip(
                    selected: selected,
                    label: Text(tab[0].toUpperCase() + tab.substring(1)),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primaryBg : Colors.white,
                    ),
                    onSelected: (_) {
                      setState(() => _status = tab);
                      _loadBookings();
                    },
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StateCard(
            message: _error!,
            actionText: 'Retry',
            onAction: _loadBookings,
          ),
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
        onCancel: () => _cancel(_bookings[index]),
        onReview: () => _review(_bookings[index]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onCancel;
  final VoidCallback onReview;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final room = booking['room'] ?? {};
    final canReview =
        booking['status'] == 'completed' && booking['review'] == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: canReview
              ? Colors.amber.withOpacity(0.55)
              : Colors.white.withOpacity(0.08),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room['room_name'] ?? '-',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.66),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (canReview)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: AppColors.primaryBg,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                booking['status'] ?? '-',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (booking['status'] == 'pending')
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel Booking'),
                ),
              if (canReview)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onReview,
                  child: const Text('Review Now'),
                ),
            ],
          ),
        ],
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

  const _StateCard({
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}
