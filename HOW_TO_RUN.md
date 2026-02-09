# ⚠️ PENTING: Cara Run Project Ini

## ❌ JANGAN Run File SQL di VS Code!

File **`database_mysql.sql`** adalah script untuk di-import ke **PHPMyAdmin**, bukan untuk di-run di VS Code. 

Kalau Anda mencoba run file `.sql`, VS Code akan minta extension MS SQL (yang TIDAK diperlukan).

---

## ✅ Cara BENAR Run Project Ini

### 🚀 Run Flutter Mobile App

1. **Buka Command Palette** (Ctrl+Shift+P)
2. Ketik: **"Flutter: Select Device"**
3. Pilih device (Chrome, Android, iOS, atau Windows)
4. **Tekan F5** atau klik **"Run > Start Debugging"**
5. Atau dari terminal:
   ```bash
   flutter run
   ```

### 📊 Import Database MySQL

1. **Buka PHPMyAdmin**: http://localhost/phpmyadmin
2. Klik tab **"Import"**
3. Pilih file: `database_mysql.sql`
4. Klik **"Go"**
5. ✅ Database siap!

### 🔌 Test REST API

1. **Pastikan Apache & MySQL running di XAMPP**
2. **Buka browser**: http://localhost/evaluasi_ws/
3. Atau test dengan: http://localhost/evaluasi_ws/test_api.html

---

## 🎯 Quick Commands

### Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run app (release mode)
flutter run --release

# Build APK
flutter build apk --release

# Clean project
flutter clean
```

### XAMPP/Database
- ✅ Start Apache: XAMPP Control Panel → Apache → Start
- ✅ Start MySQL: XAMPP Control Panel → MySQL → Start
- ✅ Open PHPMyAdmin: http://localhost/phpmyadmin
- ✅ Test API: http://localhost/evaluasi_ws/

---

## 📁 File Structure

```
evaluasiws/
├── lib/
│   └── main.dart          ← Run this (Flutter app)
│
├── database_mysql.sql     ← Import ke PHPMyAdmin (JANGAN di-run)
│
└── C:\xampp\htdocs\evaluasi_ws\
    ├── index.php          ← API endpoint (akses via browser)
    └── test_api.html      ← Test API
```

---

## 🐛 Troubleshooting

### Error: "MS SQL extension required"
**Penyebab:** Anda mencoba run file `.sql` di VS Code

**Solusi:**
1. ❌ JANGAN run file SQL di VS Code
2. ✅ Import ke PHPMyAdmin
3. ✅ Run Flutter app: Tekan **F5** atau `flutter run`

### Error: "No devices found"
**Solusi:**
```bash
flutter devices
flutter run -d chrome    # Run di Chrome
flutter run -d windows   # Run di Windows
```

### API tidak bisa diakses
**Solusi:**
1. ✅ Pastikan XAMPP Apache running
2. ✅ Pastikan folder ada: `C:\xampp\htdocs\evaluasi_ws\`
3. ✅ Test: http://localhost/evaluasi_ws/

---

## 📦 Extensions VS Code Yang Diperlukan

### ✅ Required (Sudah auto-recommend):
- **Dart** - dart-code.dart-code
- **Flutter** - dart-code.flutter
- **Flutter Snippets** - alexisvt.flutter-snippets

### ❌ TIDAK Diperlukan:
- MS SQL Tools
- SQL Server
- SQLTools

---

## 🎮 Keyboard Shortcuts

- **F5** - Run Flutter app (Debug mode)
- **Ctrl+F5** - Run Flutter app (Without debugging)
- **Shift+F5** - Stop debugging
- **Ctrl+Shift+P** - Command Palette
- **Ctrl+`** - Open Terminal

---

**Status Project:**
- ✅ Flutter App: `lib/main.dart`
- ✅ Database Script: `database_mysql.sql` (import ke PHPMyAdmin)
- ✅ REST API: `C:\xampp\htdocs\evaluasi_ws\`
- ✅ VS Code Config: `.vscode/launch.json` (sudah dibuat)

**Next:** Tekan **F5** untuk run Flutter app! 🚀
