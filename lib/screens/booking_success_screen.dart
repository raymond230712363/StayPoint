import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/themes.dart';
import 'main_navigation.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String username; 
  final String email;    

  const BookingSuccessScreen({
    super.key, 
    required this.booking,
    required this.username,
    required this.email,
  });

  // === FUNGSI SAKRAL BUAT GENERATE DAN DOWNLOAD PDF RECEIPT ===
  Future<void> _downloadReceiptPdf(BuildContext context) async {
    final pdf = pw.Document();
    final room = booking['room'] ?? {};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'STAYPOINT BOOKING RECEIPT',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text('Terima kasih atas pemesanan Anda, $username!'),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 14),

                pw.Text('Detail Penginapan:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Kode Booking: ${booking['booking_code'] ?? '-'}'),
                pw.Text('Hotel: ${room['hotel']?['name'] ?? '-'}'),
                pw.Text('Tipe Kamar: ${room['room_name'] ?? '-'}'),
                pw.SizedBox(height: 14),

                pw.Text('Detail Waktu:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Check In: ${booking['check_in'] ?? '-'}'),
                pw.Text('Check Out: ${booking['check_out'] ?? '-'}'),
                pw.SizedBox(height: 14),
                pw.Divider(),
                pw.SizedBox(height: 14),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text((booking['status'] ?? 'SUCCESS').toString().toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Pembayaran:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(_formatPrice(booking['total_price'] ?? 0), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt-StayPoint-${booking['booking_code'] ?? booking['id']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = booking['room'] ?? {};
    final String currentStatus = (booking['status'] ?? '').toString().toLowerCase();

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
                      value: room['hotel']?['name'] ?? '-',
                    ),
                    _Row(
                      label: 'Room',
                      value: room['room_name'] ?? '-',
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

              // === TOMBOL DOWNLOAD RECEIPT PDF SEPERTI YANG KAMU MAU JESS ===
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _downloadReceiptPdf(context),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Download Receipt PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

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
                  onPressed: () {
                    // Jika diklik dari history booking (back manual), cukup pop aja biar ga ngerusak tumpukan page
                    if (currentStatus == 'completed') {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainNavigation(
                            username: username,
                            email: email,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Text(currentStatus == 'completed' ? 'Back' : 'Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPrice(dynamic value) {
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