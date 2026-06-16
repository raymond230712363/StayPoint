import 'package:flutter/material.dart';
import 'package:staypoint/services/api_service.dart';
import 'package:staypoint/models/hotel_model.dart';
import 'package:staypoint/widgets/hotel_card.dart';
import 'package:staypoint/widgets/state_widgets.dart' as state;
import 'hotel_detail_page.dart';

class HotelListPage extends StatefulWidget {
  final ApiService apiService;

  const HotelListPage({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  late Future<List<HotelModel>> _hotelsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('HotelListPage initState - apiService: ${widget.apiService}');
    _hotelsFuture = widget.apiService.fetchHotels();
  }

  void _refreshHotels() {
    setState(() {
      _hotelsFuture = widget.apiService.fetchHotels();
    });
  }

  void _navigateToDetail(int hotelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailPage(
          hotelId: hotelId,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Hotels'),
        elevation: 0,
      ),
      body: FutureBuilder<List<HotelModel>>(
        future: _hotelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const state.LoadingWidget(message: 'Loading hotels...');
          }

          if (snapshot.hasError) {
            debugPrint('HotelListPage Error: ${snapshot.error}');
            return state.ErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _refreshHotels,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const state.EmptyWidget(message: 'No hotels available');
          }

          final hotels = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshHotels();
            },
            child: ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return HotelCard(
                  name: hotel.name,
                  location: hotel.location,
                  thumbnail: hotel.thumbnail,
                  onTap: () => _navigateToDetail(hotel.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
