import 'package:flutter/material.dart';
import '../constants/themes.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Colors.green,
                child: Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed', style: AppTextStyle.heading),
              const SizedBox(height: 8),
              Text(
                'Your reservation has been successfully saved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.65)),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _Row(
                      label: 'Booking Code',
                      value: booking['booking_code'] ?? '-',
                    ),
                    _Row(
                      label: 'Hotel',
                      value: booking['room']?['hotel']?['name'] ?? '-',
                    ),
                    _Row(
                      label: 'Room',
                      value: booking['room']?['room_name'] ?? '-',
                    ),
                    _Row(label: 'Check In', value: booking['check_in'] ?? '-'),
                    _Row(
                      label: 'Check Out',
                      value: booking['check_out'] ?? '-',
                    ),
                    _Row(
                      label: 'Total Payment',
                      value: _formatPrice(booking['total_price'] ?? 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if ((booking['qr_code'] ?? '').toString().isNotEmpty)
                Image.network(
                  booking['qr_code'],
                  height: 130,
                  width: 130,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Back to Home'),
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

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.62)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
