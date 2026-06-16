# Quick Start Guide

## 🎯 1 Minute Setup

### Step 1: Open Terminal
```bash
cd c:/wilson/StayPoint
```

### Step 2: Find Your PC's IP Address
**Windows:**
```bash
ipconfig
```
Look for IPv4 Address (e.g., 192.168.1.100)

### Step 3: Update API URL
Edit `lib/constants/app_constants.dart`:
```dart
// Change this line:
const String baseUrl = 'http://192.168.1.100:8000/api';
```

### Step 4: Install Dependencies
```bash
flutter pub get
```

### Step 5: Run App
```bash
flutter run
```

## ✅ What Should Happen

1. App starts showing hotels tab
2. Hotels list loads from API
3. Tap hotel to see details
4. Select room to book
5. Choose dates and submit
6. See booking confirmation
7. Check booking history in second tab

## 🔴 Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Check Laravel server is running on port 8000 |
| No hotels showing | Verify IP address in app_constants.dart |
| Image errors | Check image URLs are correct in database |
| Booking fails | Ensure hotel has available rooms (stock > 0) |
| History shows nothing | Need to implement authentication first |

## 📝 Next Steps

1. **Add Authentication** - Implement login/token storage
2. **Add Addons** - Let users select add-ons during booking
3. **Payment Gateway** - Integrate payment processor
4. **Reviews** - Add review functionality
5. **Notifications** - Add push notifications
6. **Offline Mode** - Cache data locally

---

**Ready to code?** Start with the pages and expand functionality!
