# 🌍 Production Deployment Guide

## 📋 Prerequisites

Sebelum deploy, pastikan Anda punya:
- ✅ Domain name (contoh: tpknilam.com)
- ✅ Web hosting dengan PHP & MySQL support
- ✅ FTP/SSH access ke server
- ✅ SSL Certificate (HTTPS)

---

## 🚀 Step 1: Setup Database di Server

### A. Login ke cPanel / Hosting Panel

### B. Buat Database MySQL
1. Buka **"MySQL Databases"**
2. Buat database baru:
   - Database Name: `username_evaluasiws`
3. Buat user baru:
   - Username: `username_apiuser`
   - Password: (strong password)
4. Add user ke database dengan **ALL PRIVILEGES**

### C. Import Database
1. Buka **PHPMyAdmin**
2. Select database `username_evaluasiws`
3. Klik tab **"Import"**
4. Upload file `database_mysql.sql`
5. Klik **"Go"**

✅ Database siap!

---

## 📤 Step 2: Upload API Files

### Via FTP (FileZilla)
1. Connect ke server FTP
2. Navigasi ke: `/public_html/` atau `/www/`
3. Upload folder `api_php/` ke server
4. Struktur:
   ```
   public_html/
   └── api_php/
       ├── config.php
       ├── index.php
       ├── .htaccess
       └── endpoints/
   ```

### Via cPanel File Manager
1. Buka **"File Manager"**
2. Navigasi ke `/public_html/`
3. Upload ZIP file `api_php.zip`
4. Extract di server

---

## ⚙️ Step 3: Configure API

### Edit config.php
```php
<?php
// Production Database Settings
define('DB_HOST', 'localhost'); // atau IP database server
define('DB_USER', 'username_apiuser');
define('DB_PASS', 'your_strong_password');
define('DB_NAME', 'username_evaluasiws');

// Security: Generate random API key
define('API_KEY', 'TPK-NILAM-PROD-' . bin2hex(random_bytes(16)));
?>
```

### Update .htaccess (jika perlu)
```apache
# Enable Rewrite Engine
RewriteEngine On

# Set base directory (adjust if API not in root)
RewriteBase /api_php/

# HTTPS Redirect (recommended)
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# API Router
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?request=$1 [QSA,L]
```

---

## 🧪 Step 4: Test API

### Test Connection
```
https://yourdomain.com/api_php/index.php?request=test
```

Expected response:
```json
{
  "success": true,
  "message": "API is working!",
  "data": {
    "version": "1.0",
    "timestamp": "2026-02-09 10:30:45"
  }
}
```

### Test Get Data
```
https://yourdomain.com/api_php/index.php?request=evaluasi
```

### Test Statistics
```
https://yourdomain.com/api_php/index.php?request=statistics
```

✅ Jika semua response berhasil, API sudah live!

---

## 📱 Step 5: Update Flutter App

### Update API Base URL
```dart
// lib/services/api_service.dart
class ApiService {
  // Change dari localhost ke production URL
  static const String baseUrl = 'https://yourdomain.com/api_php/index.php';
  
  // API Key untuk authentication
  static const String apiKey = 'TPK-NILAM-PROD-xxxxx'; // dari config.php
  
  // ... methods
}
```

### Add HTTP Package
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

### Create API Service
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://yourdomain.com/api_php/index.php';
  static const String apiKey = 'YOUR_API_KEY';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };
  
  static Future<List<EvaluasiData>> getAllEvaluasi() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?request=evaluasi'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          return data.map((e) => EvaluasiData.fromJson(e)).toList();
        }
      }
      throw Exception('Failed to load data');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
  
  static Future<bool> createEvaluasi(EvaluasiData data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?request=evaluasi'),
        headers: headers,
        body: json.encode(data.toJson()),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
  
  // Add more methods for update, delete, search, etc.
}
```

### Build & Release App
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Output APK
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔒 Step 6: Security Hardening

### 1. Enable API Key Authentication
```php
// Uncomment di semua endpoints
validateApiKey();
```

### 2. Setup SSL Certificate (HTTPS)
- Gunakan Let's Encrypt (free)
- Atau SSL dari hosting provider
- Force HTTPS di .htaccess

### 3. Database Security
```sql
-- Create dedicated user with limited permissions
CREATE USER 'api_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON evaluasiws.* TO 'api_user'@'localhost';
FLUSH PRIVILEGES;
```

### 4. File Permissions
```bash
# Set proper file permissions
chmod 644 config.php
chmod 644 *.php
chmod 755 endpoints/
```

### 5. Hide Sensitive Files
```apache
# Add to .htaccess
<Files "config.php">
  Order Allow,Deny
  Deny from all
</Files>
```

---

## 💾 Step 7: Setup Automated Backup

### Create Backup Script (backup.php)
```php
<?php
// backup.php - Run via cron job
$backup_file = 'backups/evaluasiws_' . date('Y-m-d_H-i-s') . '.sql';
$command = "mysqldump -u username -ppassword database_name > $backup_file";
system($command);

// Delete backups older than 30 days
$files = glob('backups/*.sql');
foreach ($files as $file) {
    if (filemtime($file) < time() - (30 * 86400)) {
        unlink($file);
    }
}
?>
```

### Setup Cron Job (cPanel)
1. Buka **"Cron Jobs"**
2. Add new cron:
   ```
   0 2 * * * /usr/bin/php /home/username/public_html/api_php/backup.php
   ```
   (Run every day at 2 AM)

---

## 📊 Step 8: Monitoring & Analytics

### 1. Server Monitoring
- Setup uptime monitoring (UptimeRobot, Pingdom)
- Monitor server resources (CPU, RAM, disk)

### 2. API Logging
```php
// Add to config.php
function logApiAccess() {
    $log = date('Y-m-d H:i:s') . ' - ' . 
           $_SERVER['REMOTE_ADDR'] . ' - ' . 
           $_SERVER['REQUEST_URI'] . PHP_EOL;
    file_put_contents('logs/api_access.log', $log, FILE_APPEND);
}
```

### 3. Error Tracking
```php
// Set error handler
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    error_log("Error [$errno]: $errstr in $errfile:$errline");
});
```

---

## 🚦 Step 9: Performance Optimization

### 1. Enable PHP OPcache
```ini
; php.ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=10000
```

### 2. Enable Gzip Compression
```apache
# .htaccess
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

### 3. Database Optimization
```sql
-- Add indexes for faster queries
CREATE INDEX idx_tanggal ON evaluasi(tanggal);
CREATE INDEX idx_shift ON evaluasi(shift);
CREATE INDEX idx_pelayaran ON evaluasi(pelayaran);

-- Optimize tables
OPTIMIZE TABLE evaluasi;
```

### 4. API Response Caching
```php
// Simple caching example
$cache_file = 'cache/statistics.json';
$cache_time = 300; // 5 minutes

if (file_exists($cache_file) && (time() - filemtime($cache_file) < $cache_time)) {
    echo file_get_contents($cache_file);
} else {
    // Generate response
    $response = json_encode($data);
    file_put_contents($cache_file, $response);
    echo $response;
}
```

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] Database backup
- [ ] Test all API endpoints locally
- [ ] Update production credentials
- [ ] Remove debug/test code
- [ ] Update API URLs in mobile app

### Deployment
- [ ] Upload API files to server
- [ ] Import database
- [ ] Configure database connection
- [ ] Test API endpoints on server
- [ ] Setup SSL certificate
- [ ] Configure .htaccess

### Post-Deployment
- [ ] Test all API endpoints
- [ ] Test mobile app with production API
- [ ] Setup monitoring
- [ ] Configure automated backups
- [ ] Document API credentials
- [ ] Setup error logging

### Security
- [ ] Enable API key authentication
- [ ] Force HTTPS
- [ ] Hide sensitive files
- [ ] Set proper file permissions
- [ ] Setup firewall rules
- [ ] Regular security updates

---

## 🆘 Troubleshooting Production Issues

### API returns 500 Error
```bash
# Check PHP error log
tail -f /var/log/apache2/error.log

# Common causes:
# - Wrong database credentials
# - PHP version incompatibility
# - Missing PHP extensions
# - File permission issues
```

### Database connection failed
```php
// Test connection separately
<?php
$conn = new mysqli('localhost', 'user', 'pass', 'db');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>
```

### CORS errors from mobile app
```php
// Add to config.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

### Slow API response
```sql
-- Check slow queries
SHOW PROCESSLIST;

-- Add missing indexes
EXPLAIN SELECT * FROM evaluasi WHERE ...;
```

---

## 📞 Production Support

### Server Admin Contacts
- **Hosting Provider:** support@hosting.com
- **Domain Registrar:** support@domain.com
- **SSL Provider:** support@ssl.com

### Maintenance Schedule
- **Daily:** Automated backups
- **Weekly:** Performance monitoring
- **Monthly:** Security updates
- **Quarterly:** Full system audit

---

**Deployment Date:** [To be filled]  
**API URL:** https://yourdomain.com/api_php/  
**Version:** 1.0.0  
**Status:** 🟢 Live
