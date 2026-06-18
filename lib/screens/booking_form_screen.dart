import 'package:flutter/material.dart';
import '../api_service.dart';
import '../constants/themes.dart';
import 'booking_success_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  final String email;

  const BookingFormScreen({super.key, required this.room, required this.email});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Map<String, dynamic>> _addons = [];
  final Map<int, int> _selectedAddons = {};

  @override
  void initState() {
    super.initState();
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ApiService.getAddons();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _addons = List<Map<String, dynamic>>.from(result['addons'] ?? []);
      } else {
        _error = result['message'] ?? 'Gagal mengambil addon';
      }
    });
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays.clamp(0, 999);
  }

  int get _roomTotal =>
      _nights * (int.tryParse(widget.room['price_per_night'].toString()) ?? 0);

  int get _addonTotal {
    var total = 0;
    for (final addon in _addons) {
      final id = addon['id'] as int;
      final qty = _selectedAddons[id] ?? 0;
      total += qty * (int.tryParse(addon['price'].toString()) ?? 0);
    }
    return total;
  }

  int get _grandTotal => _roomTotal + _addonTotal;

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? now)
          : (_checkOut ?? now.add(const Duration(days: 1))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut == null || !_checkOut!.isAfter(picked)) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_checkIn == null || _checkOut == null || _nights < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih check-in dan check-out yang valid.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ApiService.createBooking(
      email: widget.email,
      roomId: widget.room['id'],
      checkIn: _date(_checkIn!),
      checkOut: _date(_checkOut!),
      addons: _selectedAddons.entries
          .where((entry) => entry.value > 0)
          .map((entry) => {'id': entry.key, 'quantity': entry.value})
          .toList(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            booking: Map<String, dynamic>.from(result['booking']),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Booking gagal'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Request to Book'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : RefreshIndicator(
                onRefresh: _loadAddons,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_error != null)
                      _InlineState(
                        message: _error!,
                        actionText: 'Retry',
                        onAction: _loadAddons,
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: _DateCard(
                            label: 'Check In',
                            value: _checkIn == null
                                ? 'Pick date'
                                : _date(_checkIn!),
                            onTap: () => _pickDate(isCheckIn: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateCard(
                            label: 'Check Out',
                            value: _checkOut == null
                                ? 'Pick date'
                                : _date(_checkOut!),
                            onTap: () => _pickDate(isCheckIn: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SummaryRow(
                      label: 'Room',
                      value: widget.room['room_name'] ?? '-',
                    ),
                    _SummaryRow(label: 'Night', value: '$_nights night'),
                    _SummaryRow(
                      label: 'Room Total',
                      value: _formatPrice(_roomTotal),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Add-ons',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_addons.isEmpty)
                      Text(
                        'Addon belum tersedia.',
                        style: TextStyle(color: Colors.white.withOpacity(0.62)),
                      )
                    else
                      ..._addons.map(_buildAddonTile),
                    const Divider(color: Colors.white24, height: 34),
                    _SummaryRow(
                      label: 'Addon Total',
                      value: _formatPrice(_addonTotal),
                    ),
                    _SummaryRow(
                      label: 'Total Payment',
                      value: _formatPrice(_grandTotal),
                      strong: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Confirm and Pay',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAddonTile(Map<String, dynamic> addon) {
    final id = addon['id'] as int;
    final qty = _selectedAddons[id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon['name'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatPrice(addon['price'] ?? 0),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: qty == 0
                ? null
                : () => setState(() => _selectedAddons[id] = qty - 1),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedAddons[id] = qty + 1),
            icon: const Icon(Icons.add_circle, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatPrice(dynamic value) {
    final price = int.tryParse(value.toString()) ?? 0;
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.65)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: strong ? FontWeight.bold : FontWeight.w500,
              fontSize: strong ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineState extends StatelessWidget {
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const _InlineState({
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}
