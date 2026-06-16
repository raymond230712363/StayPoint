import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staypoint/services/api_service.dart';
import 'package:staypoint/models/room_model.dart';
import 'package:staypoint/models/booking_model.dart';
import 'package:staypoint/widgets/custom_textfield.dart';
import 'package:staypoint/widgets/state_widgets.dart' as state;

class BookingPage extends StatefulWidget {
  final RoomModel room;
  final ApiService apiService;

  const BookingPage({
    Key? key,
    required this.room,
    required this.apiService,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late TextEditingController _checkInController;
  late TextEditingController _checkOutController;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInController = TextEditingController();
    _checkOutController = TextEditingController();
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isCheckIn,
  ) async {
    final now = DateTime.now();
    final firstDate = isCheckIn ? now : (_checkInDate ?? now);
    final lastDate = DateTime(now.year + 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          _checkInController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        } else {
          _checkOutDate = pickedDate;
          _checkOutController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both check-in and check-out dates')),
      );
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out date must be after check-in date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingRequest = BookingRequestModel(
        roomId: widget.room.id,
        checkIn: DateFormat('yyyy-MM-dd').format(_checkInDate!),
        checkOut: DateFormat('yyyy-MM-dd').format(_checkOutDate!),
      );

      final response = await widget.apiService.createBooking(bookingRequest);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your booking has been created!'),
                const SizedBox(height: 16),
                Text(
                  'Booking Code: ${response.bookingCode}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nights = _checkInDate != null && _checkOutDate != null
        ? _checkOutDate!.difference(_checkInDate!).inDays
        : 0;
    final totalPrice = nights > 0 ? widget.room.pricePerNight * nights : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.roomName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${widget.room.pricePerNight.toStringAsFixed(2)}/night',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.room.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Dates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Check-in Date',
                    controller: _checkInController,
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                    suffixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please select check-in date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Check-out Date',
                    controller: _checkOutController,
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                    suffixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please select check-out date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Number of Nights:'),
                              Text(
                                nights.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price per Night:'),
                              Text(
                                '\$${widget.room.pricePerNight.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Price:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Complete Booking'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
