# 📘 Setup MySQL Database & REST API - TPK Nilam Evaluasi WS

## 🔧 Prasyarat

1. **XAMPP** atau **WAMP** atau **MAMP** (sudah terinstall)
2. **PHPMyAdmin** (termasuk dalam XAMPP/WAMP)
3. **PHP 7.4+**
4. **MySQL 5.7+**

---

## 📊 Langkah 1: Setup Database MySQL

### A. Buka PHPMyAdmin
1. Jalankan XAMPP Control Panel
2. Start **Apache** dan **MySQL**
3. Buka browser, akses `http://localhost/phpmyadmin`

### B. Import Database

**Opsi 1: Import File SQL**
1. Di PHPMyAdmin, klik tab **"Import"**
2. Klik **"Choose File"**
3. Pilih file: `database_mysql.sql`
4. Klik **"Go"** untuk import

**Opsi 2: Manual Copy-Paste**
1. Di PHPMyAdmin, klik tab **"SQL"**
2. Buka file `database_mysql.sql` dengan text editor
3. Copy semua isi file
4. Paste ke SQL query box
5. Klik **"Go"**

### C. Verifikasi Database
Setelah import berhasil, Anda akan melihat:
- ✅ Database: `evaluasiws`
- ✅ Tabel: `evaluasi` (dengan 7 sample data)
- ✅ Tabel: `users` (dengan 2 user default)
- ✅ View: `view_statistik`, `view_statistik_shift`, `view_statistik_pelayaran`

---

## 🚀 Langkah 2: Setup REST API

### A. Copy File API ke htdocs
1. Copy folder `api_php` ke folder XAMPP:
   ```
   C:\xampp\htdocs\api_php\
   ```

2. Struktur folder seharusnya:
   ```
   C:\xampp\htdocs\api_php\
   ├── config.php
   ├── index.php
   ├── .htaccess
   └── endpoints\
       ├── evaluasi.php
       ├── statistics.php
       └── search.php
   ```

### B. Konfigurasi Database Connection
Buka file `config.php` dan sesuaikan:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');  // Isi jika MySQL Anda ada password
define('DB_NAME', 'evaluasiws');
```

### C. Test API
Buka browser dan akses:
```
http://localhost/api_php/index.php
```

Jika berhasil, Anda akan melihat response JSON:
```json
{
  "success": true,
  "message": "TPK Nilam Evaluasi WS API v1.0",
  "data": {
    "endpoints": { ... }
  }
}
```

---

## 📡 Endpoint API

### Base URL
```
http://localhost/evaluasi_ws/index.php
```

### 1. Test Connection
```
GET http://localhost/evaluasi_ws/index.php?request=test
```

### 2. Get All Evaluasi
```
GET http://localhost/evaluasi_ws/index.php?request=evaluasi
```

### 3. Get Evaluasi by ID
```
GET http://localhost/evaluasi_ws/index.php?request=evaluasi&id=1
```

### 4. Create New Evaluasi
```
POST http://localhost/evaluasi_ws/index.php?request=evaluasi
Content-Type: application/json

{
  "tanggal": "09/02/2026",
  "shift": "Shift 1",
  "kapal": "MV Test Ship",
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

### 5. Update Evaluasi
```
PUT http://localhost/evaluasi_ws/index.php?request=evaluasi&id=1
Content-Type: application/json

{
  "tanggal": "09/02/2026",
  "shift": "Shift 1",
  "kapal": "MV Updated Ship",
  ...
}
```

### 6. Delete Evaluasi
```
DELETE http://localhost/evaluasi_ws/index.php?request=evaluasi&id=1
```

### 7. Get Statistics
```
GET http://localhost/evaluasi_ws/index.php?request=statistics
```

### 8. Search Evaluasi
```
GET http://localhost/evaluasi_ws/index.php?request=search&q=ocean
```

---

## 🧪 Testing API dengan Postman

### 1. Install Postman
Download dari: https://www.postman.com/downloads/

### 2. Import Collection
1. Buka Postman
2. Klik **"Import"**
3. Copy-paste JSON collection (lihat file `postman_collection.json`)

### 3. Test Endpoints
Jalankan setiap request untuk memastikan API berjalan dengan baik.

---

## 🔒 Keamanan (Opsional)

### Enable API Key Authentication
Uncomment baris ini di setiap endpoint:
```php
validateApiKey(); // Uncomment untuk enable authentication
```

Lalu, tambahkan header di setiap request:
```
Authorization: Bearer TPK-NILAM-2026
```

---

## 🌐 Koneksi dari Flutter App

### A. Tambah Package HTTP ke Flutter
Edit `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### B. Buat Service Class
```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost/evaluasi_ws/index.php';
  
  Future<List<EvaluasiData>> getAllEvaluasi() async {
    final response = await http.get(
      Uri.parse('$baseUrl?request=evaluasi'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Process data...
    }
  }
  
  // More methods...
}
```

### C. Untuk Testing di Real Device
Ganti `localhost` dengan IP address komputer Anda:
```dart
static const String baseUrl = 'http://192.168.1.100/evaluasi_ws/index.php';
```

**Cara cek IP:**
- Windows: `ipconfig` di Command Prompt
- Mac/Linux: `ifconfig` di Terminal

---

## 📊 Struktur Database

### Tabel: evaluasi
| Field | Type | Description |
|-------|------|-------------|
| id | INT(11) | PRIMARY KEY, AUTO_INCREMENT |
| tanggal | VARCHAR(20) | Tanggal evaluasi |
| shift | VARCHAR(50) | Shift kerja |
| kapal | VARCHAR(100) | Nama kapal |
| pelayaran | VARCHAR(50) | Nama pelayaran |
| target_bongkar | INT(11) | Target bongkar (ton) |
| realisasi_bongkar | INT(11) | Realisasi bongkar (ton) |
| target_muat | INT(11) | Target muat (ton) |
| realisasi_muat | INT(11) | Realisasi muat (ton) |
| persen_bongkar | DECIMAL(5,2) | Persentase bongkar |
| persen_muat | DECIMAL(5,2) | Persentase muat |
| keterangan | TEXT | Keterangan |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diupdate |

---

## 🔍 Troubleshooting

### Error: "Access denied for user 'root'"
**Solusi:** Edit `config.php`, sesuaikan DB_USER dan DB_PASS

### Error: "Database evaluasiws not found"
**Solusi:** Import ulang file `database_mysql.sql`

### Error: "404 Not Found" saat akses API
**Solusi:** 
1. Pastikan Apache sudah running
2. Pastikan folder `api_php` ada di `htdocs`
3. Cek file `.htaccess` sudah ada

### API tidak bisa diakses dari Flutter App
**Solusi:**
1. Ganti `localhost` dengan IP address komputer
2. Pastikan device dan komputer dalam 1 jaringan WiFi
3. Matikan firewall atau allow port 80

---

## 📝 Catatan Penting

### Perbedaan SQLite vs MySQL

| Fitur | SQLite (Mobile) | MySQL (Server) |
|-------|----------------|----------------|
| Lokasi | Local device | Remote server |
| Sinkronisasi | ❌ Tidak ada | ✅ Real-time |
| Multi-user | ❌ Tidak support | ✅ Support |
| Backup | Manual | Otomatis |
| Akses | Offline only | Online/Offline |

### Rekomendasi Arsitektur

**Untuk Production:**
1. ✅ Gunakan MySQL + REST API untuk data terpusat
2. ✅ Gunakan SQLite sebagai cache offline
3. ✅ Implementasi sync mechanism
4. ✅ Add authentication & authorization

---

## 🎯 Next Steps

### 1. Integrate API ke Flutter App
- Install package `http`
- Buat service layer
- Update UI untuk fetch dari API

### 2. Add Authentication
- Implement login/register
- Use JWT tokens
- Secure API endpoints

### 3. Deploy to Server
- Upload ke hosting
- Setup domain
- Configure SSL/HTTPS

---

## 📞 Support

Jika ada masalah, check:
1. Apache & MySQL status di XAMPP
2. Console error di browser (F12)
3. PHP error logs di `xampp/apache/logs/error.log`

---

**Status Setup:**
- ✅ Database SQL Script
- ✅ REST API PHP
- ✅ Sample Data
- ✅ Documentation
- ⏳ Flutter Integration (Next)
