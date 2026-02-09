# Database Documentation - TPK Nilam Evaluasi WS

## Overview
Aplikasi ini menggunakan SQLite sebagai database lokal untuk menyimpan data evaluasi work shift secara persisten.

## Struktur Database

### Tabel: `evaluasi`

| Kolom | Tipe Data | Deskripsi |
|-------|-----------|-----------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | ID unik untuk setiap record |
| tanggal | TEXT | Tanggal evaluasi (format: dd/MM/yyyy) |
| shift | TEXT | Shift kerja (Shift 1, 2, 3) |
| kapal | TEXT | Nama kapal |
| pelayaran | TEXT | Nama pelayaran (Pelayaran 1, 2, 3) |
| targetBongkar | INTEGER | Target bongkar dalam ton |
| realisasiBongkar | INTEGER | Realisasi bongkar dalam ton |
| targetMuat | INTEGER | Target muat dalam ton |
| realisasiMuat | INTEGER | Realisasi muat dalam ton |
| persenBongkar | REAL | Persentase realisasi bongkar |
| persenMuat | REAL | Persentase realisasi muat |
| keterangan | TEXT | Keterangan tambahan |

## Struktur File

```
lib/
├── main.dart                    # Main application file
├── models/
│   └── evaluasi_data.dart      # Model class untuk data evaluasi
└── database/
    └── database_helper.dart    # Database helper class
```

## Fungsi-Fungsi Database

### DatabaseHelper Class

#### 1. `insertEvaluasi(EvaluasiData evaluasi)`
Menyimpan data evaluasi baru ke database.

**Parameter:**
- `evaluasi`: Objek EvaluasiData yang akan disimpan

**Return:** `Future<int>` - ID record yang baru disimpan

**Contoh:**
```dart
final newData = EvaluasiData(
  tanggal: '09/02/2026',
  shift: 'Shift 1',
  kapal: 'MV Test Ship',
  pelayaran: 'Pelayaran 1',
  targetBongkar: 650,
  realisasiBongkar: 615,
  targetMuat: 690,
  realisasiMuat: 680,
  persenBongkar: 94.6,
  persenMuat: 98.6,
  keterangan: 'Normal',
);
await dbHelper.insertEvaluasi(newData);
```

#### 2. `getAllEvaluasi()`
Mengambil semua data evaluasi dari database (diurutkan dari yang terbaru).

**Return:** `Future<List<EvaluasiData>>` - List semua data evaluasi

**Contoh:**
```dart
List<EvaluasiData> allData = await dbHelper.getAllEvaluasi();
```

#### 3. `searchEvaluasi(String query)`
Mencari data evaluasi berdasarkan nama kapal atau tanggal.

**Parameter:**
- `query`: String pencarian

**Return:** `Future<List<EvaluasiData>>` - List data yang sesuai dengan pencarian

**Contoh:**
```dart
List<EvaluasiData> results = await dbHelper.searchEvaluasi('Ocean');
```

#### 4. `updateEvaluasi(EvaluasiData evaluasi)`
Mengupdate data evaluasi yang sudah ada.

**Parameter:**
- `evaluasi`: Objek EvaluasiData dengan id yang valid

**Return:** `Future<int>` - Jumlah row yang diupdate

**Contoh:**
```dart
final updatedData = EvaluasiData(
  id: 1,
  tanggal: '09/02/2026',
  shift: 'Shift 1',
  kapal: 'MV Updated Ship',
  // ... field lainnya
);
await dbHelper.updateEvaluasi(updatedData);
```

#### 5. `deleteEvaluasi(int id)`
Menghapus data evaluasi berdasarkan id.

**Parameter:**
- `id`: ID record yang akan dihapus

**Return:** `Future<int>` - Jumlah row yang dihapus

**Contoh:**
```dart
await dbHelper.deleteEvaluasi(1);
```

#### 6. `getStatistics()`
Mengambil statistik agregat dari semua data evaluasi.

**Return:** `Future<Map<String, dynamic>>` - Map berisi:
- `totalBongkar`: Total semua realisasi bongkar
- `totalMuat`: Total semua realisasi muat
- `avgBongkar`: Rata-rata realisasi bongkar
- `avgMuat`: Rata-rata realisasi muat
- `persenBongkar`: Persentase total realisasi bongkar terhadap target
- `persenMuat`: Persentase total realisasi muat terhadap target
- `totalRecords`: Jumlah total record

**Contoh:**
```dart
Map<String, dynamic> stats = await dbHelper.getStatistics();
print('Total Bongkar: ${stats['totalBongkar']} ton');
```

#### 7. `clearAllData()`
Menghapus semua data dari database (untuk testing).

**Return:** `Future<void>`

**Contoh:**
```dart
await dbHelper.clearAllData();
```

## Model Class: EvaluasiData

### Properties
```dart
final int? id;
final String tanggal;
final String shift;
final String kapal;
final String pelayaran;
final int targetBongkar;
final int realisasiBongkar;
final int targetMuat;
final int realisasiMuat;
final double persenBongkar;
final double persenMuat;
final String keterangan;
```

### Methods

#### `toMap()`
Mengkonversi objek EvaluasiData menjadi Map untuk disimpan ke database.

#### `fromMap(Map<String, dynamic> map)`
Factory constructor untuk membuat objek EvaluasiData dari Map.

## Lokasi Database

Database disimpan di lokasi default aplikasi:
- **Android:** `/data/data/com.example.evaluasiws/databases/evaluasi_ws.db`
- **iOS:** Library/Application Support directory
- **Windows/Linux/macOS:** User application data directory

## Sample Data

Database secara otomatis diisi dengan 2 sample data saat pertama kali dibuat:

1. MV Ocean Star - Shift 1 - Pelayaran 1
2. MV Pacific Wave - Shift 2 - Pelayaran 2

## Cara Menggunakan Database di Aplikasi

### 1. Import dependencies
```dart
import 'database/database_helper.dart';
import 'models/evaluasi_data.dart';
```

### 2. Inisialisasi DatabaseHelper
```dart
final DatabaseHelper _dbHelper = DatabaseHelper();
```

### 3. Load data saat aplikasi dimulai
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  final data = await _dbHelper.getAllEvaluasi();
  final stats = await _dbHelper.getStatistics();
  setState(() {
    _dataTable = data;
    _statistics = stats;
  });
}
```

### 4. Simpan data baru
```dart
final newData = EvaluasiData(...);
await _dbHelper.insertEvaluasi(newData);
await _loadData(); // Reload data
```

## Backup & Restore

Untuk backup database, Anda dapat mengcopy file `evaluasi_ws.db` dari lokasi database aplikasi.

Untuk restore, copy file backup ke lokasi database aplikasi yang sama.

## Notes

1. Data disimpan secara lokal di device, tidak disinkronkan ke cloud
2. Jika aplikasi di-uninstall, semua data akan hilang
3. Database secara otomatis dibuat saat aplikasi pertama kali dijalankan
4. Semua operasi database bersifat asynchronous (`async/await`)

## Troubleshooting

### Database kosong setelah install
- Database akan otomatis dibuat dengan sample data saat pertama kali dijalankan

### Error saat save data
- Pastikan semua field required terisi
- Check console untuk error message detail

### Data tidak muncul setelah save
- Pastikan memanggil `_loadData()` setelah operasi database
- Check apakah ada error di console
