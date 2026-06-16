# Implementation Examples & Patterns

## 1. Adding Authentication Token

### Modify main.dart to Include Auth
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final ApiService _apiService;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await storage.read(key: 'auth_token');
    setState(() {
      _token = token;
      _apiService = ApiService(token: token);
    });
  }

  // Rest of the code...
}
```

## 2. Creating a Booking with Addons

### Extended Booking Page Example
```dart
class _BookingPageState extends State<BookingPage> {
  List<AddonModel> selectedAddons = [];

  Future<void> _submitBooking() async {
    final addons = selectedAddons
        .map((addon) => AddonRequestModel(
              addonId: addon.id,
              quantity: addon.quantity,
            ))
        .toList();

    final bookingRequest = BookingRequestModel(
      roomId: widget.room.id,
      checkIn: DateFormat('yyyy-MM-dd').format(_checkInDate!),
      checkOut: DateFormat('yyyy-MM-dd').format(_checkOutDate!),
      addons: addons.isNotEmpty ? addons : null,
    );

    // Submit booking
    await widget.apiService.createBooking(bookingRequest);
  }
}
```

## 3. Error Handling Pattern

### Global Error Handler
```dart
class ApiService {
  Future<T> _handleRequest<T>(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: connectionTimeout),
      );

      switch (response.statusCode) {
        case 200:
        case 201:
          return jsonDecode(response.body);
        case 404:
          throw NotFoundException('Resource not found');
        case 422:
          final errors = jsonDecode(response.body)['errors'];
          throw ValidationException(errors);
        case 401:
          throw UnauthorizedException('Token expired');
        default:
          throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    }
  }
}
```

## 4. Caching Implementation

### Add Local Caching
```dart
import 'package:get_storage/get_storage.dart';

class CachedApiService extends ApiService {
  final GetStorage _storage = GetStorage();

  Future<List<HotelModel>> fetchHotels({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.read<List>('hotels');
      if (cached != null) {
        return cached
            .map((e) => HotelModel.fromJson(e))
            .toList();
      }
    }

    final hotels = await super.fetchHotels();
    await _storage.write('hotels', 
      hotels.map((e) => e.toJson()).toList());
    
    return hotels;
  }
}
```

## 5. State Management with Riverpod (Optional)

### Hotel Provider Example
```dart
import 'package:riverpod/riverpod.dart';

final apiServiceProvider = Provider((ref) {
  final token = ref.watch(authTokenProvider);
  return ApiService(token: token);
});

final hotelsProvider = FutureProvider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchHotels();
});

// Use in page:
class HotelListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotels = ref.watch(hotelsProvider);
    
    return hotels.when(
      data: (data) => ListView(children: ...),
      loading: () => const LoadingWidget(),
      error: (err, st) => const ErrorWidget(),
    );
  }
}
```

## 6. Image Upload Implementation

### Add to ApiService
```dart
Future<String> uploadImage(File imageFile) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );

    request.files.add(
      http.MultipartFile(
        'image',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: imageFile.path.split('/').last,
      ),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send();
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(await response.stream.bytesToString());
      return responseData['image_url'];
    }
    throw Exception('Failed to upload image');
  } catch (e) {
    throw Exception('Error uploading image: $e');
  }
}
```

## 7. Rating & Review Implementation

### Add Review Model and Page
```dart
class ReviewModel {
  final int id;
  final int roomId;
  final int bookingId;
  final int rating;
  final String comment;
  final String? photo;

  ReviewModel({...});

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      if (photo != null) 'photo': photo,
    };
  }
}

// In ApiService:
Future<void> submitReview(ReviewModel review) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/reviews'),
    headers: _buildHeaders(isJson: true, includeToken: true),
    body: jsonEncode(review.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to submit review');
  }
}
```

## 8. Advanced Date Validation

### Date Range Validation Utility
```dart
class DateValidator {
  static bool isValidCheckout(DateTime checkIn, DateTime checkOut) {
    return checkOut.isAfter(checkIn);
  }

  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  static bool isMinimumStayMet(DateTime checkIn, DateTime checkOut, int minNights) {
    return calculateNights(checkIn, checkOut) >= minNights;
  }

  static bool isWithinBookingWindow(DateTime checkIn, {int maxDaysInFuture = 365}) {
    final now = DateTime.now();
    return checkIn.isAfter(now) && 
           checkIn.difference(now).inDays <= maxDaysInFuture;
  }
}
```

## 9. Search & Filter Implementation

### Add Search to HotelListPage
```dart
class HotelListPage extends StatefulWidget {
  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  late TextEditingController _searchController;
  List<HotelModel> filteredHotels = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(_filterHotels);
  }

  void _filterHotels() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredHotels = _allHotels
          .where((hotel) =>
              hotel.name.toLowerCase().contains(query) ||
              hotel.location.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Search hotels...',
          controller: _searchController,
          suffixIcon: const Icon(Icons.search),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              return HotelCard(
                hotel: filteredHotels[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 10. Pagination Implementation

### Add Pagination to Hotels
```dart
class HotelListPage extends StatefulWidget {
  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  int _currentPage = 1;
  late Future<List<HotelModel>> _hotelsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
        _hotelsFuture = widget.apiService.fetchHotels(page: _currentPage);
      });
    }
  }
}
```

---

These patterns can be integrated into your existing code as needed!
