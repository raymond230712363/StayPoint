import 'package:flutter/material.dart';
import 'package:staypoint/services/api_service.dart';
import 'package:staypoint/models/hotel_detail_model.dart';
import 'package:staypoint/models/room_model.dart';
import 'package:staypoint/widgets/room_card.dart';
import 'package:staypoint/widgets/state_widgets.dart' as state;
import 'booking_page.dart';

class HotelDetailPage extends StatefulWidget {
  final int hotelId;
  final ApiService apiService;

  const HotelDetailPage({
    Key? key,
    required this.hotelId,
    required this.apiService,
  }) : super(key: key);

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late Future<HotelDetailModel> _hotelDetailFuture;

  @override
  void initState() {
    super.initState();
    _hotelDetailFuture = widget.apiService.fetchHotelDetail(widget.hotelId);
  }

  void _refreshDetail() {
    setState(() {
      _hotelDetailFuture = widget.apiService.fetchHotelDetail(widget.hotelId);
    });
  }

  void _selectRoom(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          room: room,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
        elevation: 0,
      ),
      body: FutureBuilder<HotelDetailModel>(
        future: _hotelDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const state.LoadingWidget(message: 'Loading hotel details...');
          }

          if (snapshot.hasError) {
            return state.ErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _refreshDetail,
            );
          }

          if (!snapshot.hasData) {
            return const state.EmptyWidget(message: 'Hotel not found');
          }

          final hotelDetail = snapshot.data!;
          final hotel = hotelDetail.hotel;
          final rooms = hotelDetail.rooms;
          final facilities = hotelDetail.facilities;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshDetail();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hotel.thumbnail != null)
                        Image.network(
                          hotel.thumbnail!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel, size: 80),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hotel.location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hotel.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            if (facilities.isNotEmpty) ...[
                              const Text(
                                'Facilities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (var facility in facilities)
                                    Chip(
                                      label: Text(facility.name),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Text(
                              'Available Rooms',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (rooms.isEmpty)
                  SliverFillRemaining(
                    child: const state.EmptyWidget(message: 'No rooms available'),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final room = rooms[index];
                        return RoomCard(
                          room: room,
                          onSelect: () => _selectRoom(room),
                        );
                      },
                      childCount: rooms.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
