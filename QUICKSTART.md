# 🚀 Quick Start Guide - Setup Database & API

## ⚡ Setup Database (5 menit)

### 1. Buka PHPMyAdmin
- Jalankan XAMPP → Start **Apache** dan **MySQL**
- Buka browser → `http://localhost/phpmyadmin`

### 2. Import Database
- Klik tab **"Import"**
- Pilih file: **`database_mysql.sql`**
- Klik **"Go"**
- ✅ Database `evaluasiws` sudah siap!

---

## 🔧 Setup REST API (3 menit)

### 1. Copy Folder API
✅ **Folder sudah dibuat di:**
```
C:\xampp\htdocs\evaluasi_ws\
```

### 2. Edit Config (jika perlu)
Buka `C:\xampp\htdocs\evaluasi_ws\config.php`:
```php
define('DB_PASS', ''); // Isi jika MySQL ada password
```

### 3. Test API
Buka browser:
```
http://localhost/evaluasi_ws/index.php
```

✅ Jika muncul JSON response, API sudah berjalan!

---

## 🧪 Test API dengan Browser

### Get All Data
```
http://localhost/evaluasi_ws/index.php?request=evaluasi
```

### Get Statistics
```
http://localhost/evaluasi_ws/index.php?request=statistics
```

### Search Data
```
http://localhost/evaluasi_ws/index.php?request=search&q=ocean
```

---

## 📱 Koneksi dari Flutter App (Coming Soon)

Untuk menghubungkan Flutter app dengan MySQL API, edit base URL:

```dart
// Untuk testing di komputer yang sama
static const String baseUrl = 'http://localhost/evaluasi_ws/index.php';

// Untuk testing di HP/device lain (ganti dengan IP komputer)
static const String baseUrl = 'http://192.168.1.100/evaluasi_ws/index.php';
```

**Cara cek IP komputer:**
- Buka Command Prompt
- Ketik: `ipconfig`
- Lihat: IPv4 Address → contoh: 192.168.1.100

---

## 📊 Database Info

✅ **Database Name:** evaluasiws  
✅ **Table:** evaluasi  
✅ **Sample Data:** 7 records  
✅ **Users:** admin, operator1  
✅ **Password Default:** admin123  

---

## 🔍 Cek Data di PHPMyAdmin

1. Buka PHPMyAdmin
2. Klik database **"evaluasiws"**
3. Klik tabel **"evaluasi"**
4. Klik tab **"Browse"** untuk lihat data

---

## 💾 Backup Database

Double-click file:
```
backup_database.bat
```

Backup akan tersimpan di folder:
```
backups\evaluasiws_YYYYMMDD_HHMMSS.sql
```

---

## ❗ Troubleshooting

### API tidak bisa diakses (404)
✅ Pastikan folder `evaluasi_ws` ada di `C:\xampp\htdocs\`  
✅ Pastikan Apache sudah running di XAMPP

### Database connection error
✅ Pastikan MySQL sudah running di XAMPP  
✅ Check username/password di `config.php`

### Data tidak muncul
✅ Pastikan database sudah di-import  
✅ Check di PHPMyAdmin apakah tabel `evaluasi` ada

---

## 📚 Dokumentasi Lengkap

Lihat file **`SETUP_MYSQL_API.md`** untuk dokumentasi detail.

---

**Status:**
- ✅ SQL Script
- ✅ REST API
- ✅ Sample Data
- ✅ Postman Collection
- ✅ Backup Script
- ⏳ Flutter Integration (Next)
