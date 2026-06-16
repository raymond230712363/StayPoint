# API Service Configuration

## Base URL Configuration

The API service connects to your Laravel backend. Update this file to point to your server:

**File:** `lib/constants/app_constants.dart`

### For Local Testing:
```dart
const String baseUrl = 'http://192.168.x.x:8000/api';
```
Replace `192.168.x.x` with your PC's local IP address.

### For Production:
```dart
const String baseUrl = 'https://your-domain.com/api';
```

### Finding Your PC's Local IP:

**Windows (Command Prompt):**
```
ipconfig
```
Look for IPv4 Address under your active connection (usually 192.168.x.x)

**Mac/Linux (Terminal):**
```
ifconfig
```

## AndroidManifest.xml Configuration

For HTTP (local testing), add this to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

This allows unencrypted HTTP traffic. Remove or set to false for production with HTTPS.

## iOS Configuration

For HTTP (local testing), add this to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Remove this for production.

## API Response Examples

### Hotel List Response
```json
[
  {
    "id": 1,
    "name": "Luxury Hotel",
    "location": "Jakarta",
    "thumbnail": "https://example.com/image.jpg"
  }
]
```

### Hotel Detail Response
```json
{
  "hotel": {
    "id": 1,
    "name": "Luxury Hotel",
    "location": "Jakarta",
    "description": "...",
    "thumbnail": "..."
  },
  "rooms": [
    {
      "id": 1,
      "hotel_id": 1,
      "room_name": "Room 101",
      "description": "...",
      "capacity": 2,
      "price_per_night": "150.00",
      "stock": 5,
      "images": [],
      "facilities": []
    }
  ],
  "facilities": []
}
```

### Create Booking Request
```json
{
  "room_id": 1,
  "check_in": "2024-07-15",
  "check_out": "2024-07-20",
  "addons": [
    {
      "addon_id": 1,
      "quantity": 2
    }
  ]
}
```

### Create Booking Response
```json
{
  "message": "Booking created successfully",
  "booking_code": "BK-XXXXX"
}
```

### Booking History Response
```json
[
  {
    "booking_code": "BK-XXXXX",
    "hotel": "Luxury Hotel",
    "room": "Room 101",
    "check_in": "2024-07-15",
    "check_out": "2024-07-20",
    "total_price": "950.00",
    "status": "paid"
  }
]
```

## Timeout Settings

Default timeout is 30 seconds. Adjust in `app_constants.dart`:
```dart
const int connectionTimeout = 30;
const int receiveTimeout = 30;
```

## Adding Authentication

To add Bearer token authentication:

```dart
// After user login
final token = 'your_user_token';
final apiService = ApiService(token: token);

// Then use apiService with protected endpoints
```

The token is automatically added to requests that require authentication.

## CORS Issues

If you see CORS errors, add this middleware to your Laravel app:

**app/Http/Middleware/CorsMiddleware.php** or in your API routes:

```php
Route::middleware('cors')->group(function () {
    // Your API routes
});
```

Or use package `laravel-cors` and configure it to allow your app's origin.
