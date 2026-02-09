# 🚢 TPK Nilam - Work Shift Evaluation System

Sistem evaluasi work shift berbasis Flutter dengan database MySQL dan REST API untuk TPK Nilam.

## 📱 Features

### ✅ **Mobile App (Flutter)**
- **Input Tab**
  - Form untuk input data kapal (nama, shift, pelayaran)
  - Tracking target dan realisasi bongkar/muat
  - Real-time statistics cards
  - Recent activity log
  
- **Monitoring Tab**
  - Interactive line charts dengan multiple datasets
  - Period filtering (minggu, bulan, tahun)
  - Pelayaran filtering
  - Quick statistics cards
  - Searchable data table

### ✅ **Database & Backend**
- **SQLite (Local Mobile Database)**
  - Penyimpanan data offline di device
  - Automatic database initialization
  - CRUD operations support
  
- **MySQL (Server Database)**
  - Database terpusat di server
  - Multi-user support
  - Real-time data sync
  - Backup & restore support
  
- **REST API (PHP)**
  - RESTful API endpoints
  - JSON response format
  - CRUD operations
  - Search & statistics endpoints

### ✅ **Design**
- Dark theme dengan gradient backgrounds
- Animated transitions
- Responsive layout
- Custom color scheme modern

## 📦 Project Structure

```
evaluasiws/
├── lib/
│   ├── main.dart                 # Main application file
│   ├── models/
│   │   └── evaluasi_data.dart   # Data model class
│   └── database/
│       └── database_helper.dart  # SQLite database helper
│
├── api_php/                      # REST API Backend
│   ├── config.php               # Database configuration
│   ├── index.php                # API router
│   ├── .htaccess                # Apache rewrite rules
│   └── endpoints/
│       ├── evaluasi.php         # CRUD endpoints
│       ├── statistics.php       # Statistics endpoint
│       └── search.php           # Search endpoint
│
├── database_mysql.sql           # MySQL database schema & data
├── postman_collection.json      # API testing collection
├── backup_database.bat          # Database backup script
│
├── QUISetup MySQL Database (Optional)

**Untuk setup database MySQL & REST API, ikuti guide:**
- 📘 [`QUICKSTART.md`](QUICKSTART.md) - Quick setup (5 menit)
- 📚 [`SETUP_MYSQL_API.md`](SETUP_MYSQL_API.md) - Detailed guide

### 4. CKSTART.md               # Quick setup guide
├── SETUP_MYSQL_API.md          # Detailed API setup guide
└── DATABASE_INFO.md            # Database documentation
```

## 🚀 Quick Setup

### Option 1: Mobile Only (SQLite)
Untuk development dan testing offline:

```bash
flutter pub get
flutter run
```

Data akan disimpan di SQLite local database.

### Option 2: Full Stack (MySQL + API)

**Lihat file: [`QUICKSTART.md`](QUICKSTART.md) untuk setup lengkap**

1. Import database ke PHPMyAdmin
2. Copy folder `api_php` ke `htdocs`
3. Test API di browser
4. Update Flutter app untuk connect ke API

---

## 📖 Detailed Setup

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Font Setup

Download and place the following fonts in a `fonts/` directory at the root of your project:

**Outfit Font:**
- https://fonts.google.com/specimen/Outfit
- Download: Regular (400), Bold (700), ExtraBold (800)
- Place as: `fonts/Outfit-Regular.ttf`, `fonts/Outfit-Bold.ttf`, `fonts/Outfit-ExtraBold.ttf`

**JetBrains Mono Font:**
- https://fonts.google.com/specimen/JetBrains+Mono
- Download: Regular (400), Bold (700)
- Place as: `fonts/JetBrainsMono-Regular.ttf`, `fonts/JetBrainsMono-Bold.ttf`

Or comment out the fonts section in `pubspec.yaml` to use system default fonts.

### 3. Run the App

```bash
flutter run
```

## Dependencies

- **fl_chart** (^0.66.0) - For interactive charts
- **intl** (^0.18.1) - For date/time formatting

## Project Structure

```
lib/
  └── main.dart          # Main application file with all UI components

fonts/                   # Font files (to be added)
  ├── Outfit-Regular.ttf
  ├── Outfit-Bold.ttf
  ├── Outfit-ExtraBold.ttf
  ├── JetBrainsMono-Regular.ttf
  └── JetBrainsMono-Bold.ttf
```

## Key Differences from HTML Version

### Converted Components:

1. **Header**
   - Real-time clock using Timer
   - Gradient text effects using ShaderMask
   - Animated gradient border

2. **Tab Navigation**
   - TabController for smooth tab switching
   - Animated transitions between tabs

3. **Forms**
   - TextField widgets with custom styling
   - DropdownButton for shift/pelayaran selection
   - Form validation

4. **Charts**
   - Chart.js replaced with fl_chart package
   - Interactive line charts with multiple datasets
   - Dashed lines for targets, solid lines for realizations
   - Dynamic data based on period selection

5. **Data Table**
   - DataTable widget with search functionality
   - Color-coded percentage indicators
   - Horizontal scrolling for large tables

6. **Statistics Cards**
   - Animated containers with gradients
   - Icon integration
   - Percentage indicators with color coding

### Not Implemented:

- Data persistence (use shared_preferences, hive, or sqflite for local storage)
- Backend integration (add http package for API calls)
- Export functionality (add pdf/excel export packages if needed)
- Advanced animations (can be enhanced with Flutter animations)

## Customization

### Colors

Edit the `AppColors` class in `main.dart` to customize the color scheme:

```dart
class AppColors {
  static const primary = Color(0xFF0A4D68);
  static const secondary = Color(0xFF05BFDB);
  // ... etc
}
```

### Chart Data

Chart data methods can be modified to fetch from an API:
- `_getTargetBongkarData()`
- `_getRealisasiBongkarData()`
- `_getTargetMuatData()`
- `_getRealisasiMuatData()`

### Adding Data Persistence

```dart
// Add to pubspec.yaml:
// shared_preferences: ^2.2.0

// Save data:
final prefs = await SharedPreferences.getInstance();
await prefs.setString('data', jsonEncode(_dataTable));

// Load data:
final dataString = prefs.getString('data');
if (dataString != null) {
  _dataTable = List<Map<String, dynamic>>.from(jsonDecode(dataString));
}
```

## Performance Notes

- Charts rebuild on period/filter changes
- Search filters table rows in real-time
- Timer updates clock every second (optimized)
- Large datasets may need pagination

## Future Enhancements

1. Add data persistence with local database
2. Implement backend API integration
3. Add export to PDF/Excel functionality
4. Add user authentication
5. Implement push notifications for low performance alerts
6. Add more chart types (bar, pie, etc.)
7. Implement data backup/restore
8. Add print functionality for reports

## License

This is a conversion of an internal evaluation system for TPK Nilam.

## Support

For Flutter-specific issues, refer to:
- Flutter Documentation: https://flutter.dev/docs
- fl_chart Documentation: https://pub.dev/packages/fl_chart