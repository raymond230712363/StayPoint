# StayPoint Flutter App - Integration Complete

## Project Structure

```
lib/
├── main.dart                          # App entry point with bottom navigation
├── constants/
│   └── app_constants.dart             # API base URL and endpoints
├── models/
│   ├── hotel_model.dart               # Hotel list model
│   ├── room_model.dart                # Room and facility models
│   ├── hotel_detail_model.dart        # Hotel detail response model
│   ├── booking_model.dart             # Booking request/response models
│   └── booking_history_model.dart     # Booking history model
├── services/
│   └── api_service.dart               # API communication service
├── pages/
│   ├── hotel_list_page.dart           # Hotels listing with FutureBuilder
│   ├── hotel_detail_page.dart         # Hotel details, rooms & facilities
│   ├── booking_page.dart              # Date selection & booking submission
│   └── booking_history_page.dart      # User's booking history
└── widgets/
    ├── hotel_card.dart                # Reusable hotel card
    ├── room_card.dart                 # Reusable room card
    ├── custom_textfield.dart          # Reusable text field
    └── state_widgets.dart             # Loading, Error, Empty widgets
```

## Key Features Implemented

✅ **Hotel Listing**
- Fetches from `GET /api/hotels`
- Displays thumbnail, name, location
- Pull-to-refresh functionality
- Navigate to detail page on tap

✅ **Hotel Details**
- Fetches from `GET /api/hotels/{id}`
- Shows hotel info, description
- Displays all rooms with images
- Shows available facilities as chips
- Room stock status (Available/Sold Out)

✅ **Booking System**
- Date picker for check-in/check-out
- Automatic night calculation
- Real-time price calculation
- Submits to `POST /api/bookings`
- Shows booking code on success
- Error handling with user feedback

✅ **Booking History**
- Fetches from `GET /api/bookings/history`
- Shows booking code, hotel, room
- Status badge with color coding
- Check-in/check-out dates
- Total price display

## Setup Instructions

### 1. Update API Base URL
Edit `lib/constants/app_constants.dart`:
```dart
const String baseUrl = 'http://YOUR_SERVER_IP:8000/api';
```
Replace `YOUR_SERVER_IP` with your actual Laravel server IP/domain.

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

## Architecture Decisions

### Clean Architecture
- **Models**: Data classes with fromJson/toJson methods
- **Services**: API communication layer (ApiService)
- **Pages**: UI screens using FutureBuilder for async operations
- **Widgets**: Reusable UI components

### State Management
- FutureBuilder for async data loading
- setState for simple UI updates
- Proper error handling and loading states

### API Integration
- Centralized ApiService with token support
- Proper headers and content types
- Timeout configuration (30 seconds)
- Error handling with meaningful messages

## API Endpoints Used

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | `/api/hotels` | No | List all hotels |
| GET | `/api/hotels/{id}` | No | Get hotel details with rooms |
| POST | `/api/bookings` | Yes* | Create new booking |
| GET | `/api/bookings/history` | Yes | Get user's booking history |

*Currently no auth required in demo, add token to ApiService when needed

## How to Add Authentication

1. After user login, store token:
```dart
final apiService = ApiService(token: userToken);
```

2. The ApiService will automatically include Bearer token in protected routes

3. Add token to BookingHistoryPage navigation:
```dart
BookingHistoryPage(
  apiService: ApiService(token: savedToken),
)
```

## Material 3 Features

- Modern color scheme with ColorScheme.fromSeed
- Rounded corners (BorderRadius.circular(12))
- Elevated buttons with Material 3 styling
- Cards with shadows and elevation
- Bottom navigation bar
- Proper spacing and padding

## Null Safety

- All models use non-nullable fields with ? for optional
- FutureBuilder handles null states
- Null-coalescing operators (??) used throughout
- Type safety maintained across all files

## Error Handling

- Try-catch blocks in all API calls
- User-friendly error messages
- Retry functionality on error
- Network timeout handling
- Validation for form inputs

## Future Enhancements

1. Add addon selection on booking page
2. Implement QR code display for bookings
3. Add room image gallery/carousel
4. Implement search and filter functionality
5. Add reviews section
6. Implement payment gateway integration
7. Add notification system
8. Implement local caching with Hive/GetStorage

## Testing the App

1. Start with hotel listing (appears immediately)
2. Tap on a hotel to see details
3. Select a room and tap "Select Room"
4. Choose check-in and check-out dates
5. Complete booking (you'll need valid auth token)
6. View booking history to see your bookings

## Troubleshooting

**Connection refused error:**
- Check API server is running
- Verify base URL in app_constants.dart
- Check firewall allows connections
- Use `http://` not `https://` for local testing

**Token errors on booking history:**
- Implement proper login flow
- Store token after successful login
- Pass token to ApiService constructor

**Image loading issues:**
- Check image URLs are accessible
- Error widget shows as fallback
- Verify network connectivity

## Notes

- The app uses `http` package (not https for local testing)
- FutureBuilder handles loading, error, and data states
- All dates are formatted as 'yyyy-MM-dd' for API compatibility
- Prices are handled as strings from API and converted to double
- Time zone: Make sure API and app use same timezone
