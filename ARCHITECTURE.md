# 🏗️ System Architecture - TPK Nilam Evaluasi WS

## 📐 Architecture Overview

### Deployment Options

#### **Option 1: Standalone Mobile (SQLite)**
```
┌─────────────────────────────────────┐
│     Flutter Mobile App              │
│  ┌───────────────────────────────┐  │
│  │    UI Layer (main.dart)       │  │
│  └───────────┬───────────────────┘  │
│              │                       │
│  ┌───────────▼───────────────────┐  │
│  │   Database Layer              │  │
│  │   (database_helper.dart)      │  │
│  └───────────┬───────────────────┘  │
│              │                       │
│  ┌───────────▼───────────────────┐  │
│  │   SQLite Database             │  │
│  │   (evaluasi_ws.db)            │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘

✅ Pros: Simple, offline-ready, no server needed
❌ Cons: No sync, single device only
```

#### **Option 2: Client-Server (MySQL + REST API)**
```
┌──────────────────────┐         ┌────────────────────────┐
│  Flutter Mobile App  │         │   Web Server           │
│                      │         │   (XAMPP/Apache)       │
│  ┌────────────────┐  │         │                        │
│  │  UI Layer      │  │         │  ┌──────────────────┐  │
│  └────────┬───────┘  │         │  │   REST API       │  │
│           │          │         │  │   (PHP)          │  │
│  ┌────────▼───────┐  │  HTTP   │  └────────┬─────────┘  │
│  │  API Service   │◄─┼─────────┼───────────┘            │
│  │  Layer         │  │  JSON   │                        │
│  └────────┬───────┘  │         │  ┌──────────────────┐  │
│           │          │         │  │   MySQL Database │  │
│  ┌────────▼───────┐  │         │  │   (evaluasiws)   │  │
│  │  SQLite Cache  │  │         │  └──────────────────┘  │
│  │  (Optional)    │  │         │                        │
│  └────────────────┘  │         └────────────────────────┘
└──────────────────────┘

✅ Pros: Multi-user, centralized, real-time sync
❌ Cons: Needs server, internet connection
```

---

## 🗂️ Database Schema

### SQLite (Mobile) Schema
```sql
CREATE TABLE evaluasi(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tanggal TEXT,
  shift TEXT,
  kapal TEXT,
  pelayaran TEXT,
  targetBongkar INTEGER,
  realisasiBongkar INTEGER,
  targetMuat INTEGER,
  realisasiMuat INTEGER,
  persenBongkar REAL,
  persenMuat REAL,
  keterangan TEXT
);
```

### MySQL (Server) Schema
```sql
CREATE TABLE evaluasi (
  id INT(11) PRIMARY KEY AUTO_INCREMENT,
  tanggal VARCHAR(20),
  shift VARCHAR(50),
  kapal VARCHAR(100),
  pelayaran VARCHAR(50),
  target_bongkar INT(11),
  realisasi_bongkar INT(11),
  target_muat INT(11),
  realisasi_muat INT(11),
  persen_bongkar DECIMAL(5,2),
  persen_muat DECIMAL(5,2),
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## 🔄 Data Flow

### Local (SQLite) Flow
```
User Input
    ↓
Form Validation
    ↓
Calculate Percentages
    ↓
Create EvaluasiData Object
    ↓
DatabaseHelper.insertEvaluasi()
    ↓
SQLite Database
    ↓
Reload UI Data
```

### Server (MySQL + API) Flow
```
User Input
    ↓
Form Validation
    ↓
Calculate Percentages
    ↓
Create JSON Payload
    ↓
HTTP POST Request
    ↓
API Endpoint (evaluasi.php)
    ↓
Validate & Sanitize
    ↓
MySQL Database
    ↓
JSON Response
    ↓
Update UI
```

---

## 🌐 REST API Endpoints

### Base URL
```
http://localhost/api_php/index.php
```

### Endpoints Map
```
GET    /index.php?request=evaluasi           # Get all evaluasi
GET    /index.php?request=evaluasi&id={id}   # Get one evaluasi
POST   /index.php?request=evaluasi           # Create evaluasi
PUT    /index.php?request=evaluasi&id={id}   # Update evaluasi
DELETE /index.php?request=evaluasi&id={id}   # Delete evaluasi
GET    /index.php?request=statistics         # Get statistics
GET    /index.php?request=search&q={query}   # Search evaluasi
```

### Request/Response Example

**POST Create Evaluasi:**
```http
POST /api_php/index.php?request=evaluasi
Content-Type: application/json

{
  "tanggal": "09/02/2026",
  "shift": "Shift 1",
  "kapal": "MV Ocean Star",
  "pelayaran": "Pelayaran 1",
  "target_bongkar": 650,
  "realisasi_bongkar": 615,
  "target_muat": 690,
  "realisasi_muat": 680,
  "persen_bongkar": 94.62,
  "persen_muat": 98.55,
  "keterangan": "Normal"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Data created successfully",
  "data": {
    "id": 8
  }
}
```

---

## 🔐 Security Considerations

### Current Implementation
- ❌ No authentication (development mode)
- ❌ No input sanitization on client
- ✅ PDO prepared statements (SQL injection protection)
- ✅ JSON-only responses
- ✅ CORS headers enabled

### Production Recommendations
```php
// 1. Enable API Key Authentication
validateApiKey(); // Uncomment in endpoints

// 2. Use HTTPS
// Configure SSL certificate

// 3. Add Rate Limiting
// Implement request throttling

// 4. Input Validation
// Validate all input fields

// 5. User Authentication
// Implement login system with JWT
```

---

## 📊 Performance Optimization

### Mobile App
```dart
// 1. Lazy Loading
ListView.builder() // Instead of Column with children

// 2. Caching
SharedPreferences // Cache static data

// 3. Debouncing
Timer.debounce() // For search input

// 4. Image Optimization
CachedNetworkImage // Cache images
```

### API Backend
```php
// 1. Database Indexing
CREATE INDEX idx_tanggal ON evaluasi(tanggal);

// 2. Response Caching
// Use Redis or Memcached

// 3. Query Optimization
// Use prepared statements, LIMIT results

// 4. Compression
// Enable gzip compression
```

---

## 🚀 Scalability Path

### Phase 1: Current (MVP)
- ✅ Flutter Mobile App
- ✅ SQLite local storage
- ✅ MySQL database
- ✅ PHP REST API

### Phase 2: Enhanced
- ⏳ User authentication
- ⏳ Real-time sync
- ⏳ Offline-first architecture
- ⏳ Push notifications

### Phase 3: Enterprise
- ⏳ Cloud deployment (AWS/Azure)
- ⏳ Load balancing
- ⏳ CDN for assets
- ⏳ Analytics & monitoring

---

## 🛠️ Technology Stack

### Frontend (Mobile)
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** setState (can upgrade to Provider/Riverpod)
- **Charts:** fl_chart
- **Database:** sqflite

### Backend (Server)
- **Language:** PHP 7.4+
- **Database:** MySQL 5.7+
- **Server:** Apache (XAMPP)
- **API Style:** REST
- **Format:** JSON

### Development Tools
- **IDE:** VS Code, Android Studio
- **Version Control:** Git
- **API Testing:** Postman
- **Database Admin:** PHPMyAdmin

---

## 📈 Future Enhancements

### Short Term (1-2 bulan)
- [ ] User authentication system
- [ ] Export to Excel/PDF
- [ ] Data visualization improvements
- [ ] Multi-language support (ID/EN)

### Medium Term (3-6 bulan)
- [ ] Real-time dashboard
- [ ] Mobile push notifications
- [ ] Advanced reporting
- [ ] Admin panel (web)

### Long Term (6+ bulan)
- [ ] Machine learning predictions
- [ ] IoT sensor integration
- [ ] Cloud deployment
- [ ] Mobile app for iOS

---

## 🔄 Development Workflow

```
┌─────────────────┐
│  Requirements   │
│   Gathering     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Database      │◄──── Design schema
│   Design        │      Create migrations
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   API           │◄──── Create endpoints
│   Development   │      Write tests
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Mobile App    │◄──── UI/UX design
│   Development   │      API integration
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Testing       │◄──── Unit tests
│                 │      Integration tests
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Deployment    │◄──── Alpha testing
│                 │      Beta release
└─────────────────┘
```

---

## 📞 Support & Maintenance

### Regular Tasks
- [ ] Daily database backup
- [ ] Weekly performance monitoring
- [ ] Monthly security updates
- [ ] Quarterly feature review

### Monitoring
- Server uptime
- API response time
- Database size
- User activity logs

---

**Current Version:** 1.0.0  
**Last Updated:** February 9, 2026  
**Status:** ✅ Production Ready (MVP)
