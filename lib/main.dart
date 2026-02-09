import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel_pkg hide Border;
import 'database/database_helper.dart';
import 'models/target_data.dart';
import 'models/realisasi_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const TPKNilamApp());
}

class TPKNilamApp extends StatelessWidget {
  const TPKNilamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TPK Nilam - Sistem Evaluasi WS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Outfit',
        scaffoldBackgroundColor: const Color(0xFF0A1929),
        brightness: Brightness.dark,
      ),
      home: const MainPage(),
    );
  }
}

// Color Constants
class AppColors {
  static const primary = Color(0xFF0A4D68);
  static const primaryLight = Color(0xFF088395);
  static const secondary = Color(0xFF05BFDB);
  static const accent = Color(0xFF00FFCA);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFB300);
  static const danger = Color(0xFFFF3D00);
  static const bgDark = Color(0xFF0A1929);
  static const bgCard = Color(0xFF132F4C);
  static const bgLight = Color(0xFF1A3A52);
  static const textPrimary = Color(0xFFE3F2FD);
  static const textSecondary = Color(0xFFB0BEC5);
  static const border = Color(0x3305BFDB);
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  int _selectedTab = 0;

  // Form Controllers - Entry Target
  final _targetPelayaranController = TextEditingController();
  final _targetKodeWSController = TextEditingController();
  final _targetBongkarController = TextEditingController();
  final _targetMuatController = TextEditingController();

  // DateTime for Entry Target (Berthing Time dan Departure Time)
  DateTime _targetWaktuBerthing = DateTime.now();
  DateTime _targetWaktuDeparture = DateTime.now();

  // Form Controllers - Entry Realisasi
  final _realisasiPelayaranController = TextEditingController();
  final _realisasiKodeWSController = TextEditingController();
  final _realisasiNamaKapalController = TextEditingController();
  final _realisasiBongkarController = TextEditingController();
  final _realisasiMuatController = TextEditingController();

  // DateTime for Entry Realisasi
  DateTime _realisasiWaktuArrival = DateTime.now();
  DateTime _realisasiWaktuBerthing = DateTime.now();
  DateTime _realisasiWaktuDeparture = DateTime.now();

  // Dropdowns - Entry Target
  String _selectedPelayaranTarget = 'MERATUS';
  String _selectedPeriodeTarget = 'Week 1';

  // Dropdowns - Entry Realisasi
  String _selectedPelayaranRealisasi = 'MERATUS';
  String _selectedPeriodeRealisasi = 'Week 1';

  // List Pelayaran
  static const List<String> pelayaranList = [
    'MERATUS',
    'SPIL',
    'TANTO',
    'CTP',
    'PPNP'
  ];
  // Chart Controls
  String _chartPeriode = 'Minggu';
  String _chartPelayaran = 'Semua';
  String _chartTampilan = 'Total';

  // Chart Period Selectors
  String _chartSelectedMinggu = 'Minggu 1';
  String _chartSelectedBulan = 'Januari';
  String _chartSelectedTahun = '2024';

  // Database
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TargetData> _targetDataList = [];
  List<RealisasiData> _realisasiDataList = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    _loadDatabaseData();
  }

  // Load data from database
  Future<void> _loadDatabaseData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final targetData = await _dbHelper.getAllTargetData();
      final realisasiData = await _dbHelper.getAllRealisasiData();

      setState(() {
        _targetDataList = targetData;
        _realisasiDataList = realisasiData;
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Save Target Data
  Future<void> _saveTargetData() async {
    // Validate inputs
    if (_targetBongkarController.text.isEmpty ||
        _targetMuatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua field Target Bongkar dan Muat'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      // Calculate BT
      final duration = _targetWaktuDeparture.difference(_targetWaktuBerthing);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      final btFormatted =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      final targetData = TargetData(
        pelayaran: _selectedPelayaranTarget,
        kodeWS: _targetKodeWSController.text,
        periode: _selectedPeriodeTarget,
        waktuBerthing: _targetWaktuBerthing.toIso8601String(),
        waktuDeparture: _targetWaktuDeparture.toIso8601String(),
        berthingTime: btFormatted,
        targetBongkar: int.parse(_targetBongkarController.text),
        targetMuat: int.parse(_targetMuatController.text),
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.insertTargetData(targetData);

      // Clear form
      _targetKodeWSController.clear();
      _targetBongkarController.clear();
      _targetMuatController.clear();

      // Reload data
      await _loadDatabaseData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error saving target: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Save Realisasi Data
  Future<void> _saveRealisasiData() async {
    // Validate inputs
    if (_realisasiKodeWSController.text.isEmpty ||
        _realisasiNamaKapalController.text.isEmpty ||
        _realisasiBongkarController.text.isEmpty ||
        _realisasiMuatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua field yang diperlukan'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      // Calculate BT
      final duration =
          _realisasiWaktuDeparture.difference(_realisasiWaktuBerthing);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      final btFormatted =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      final realisasiData = RealisasiData(
        pelayaran: _selectedPelayaranRealisasi,
        kodeWS: _realisasiKodeWSController.text,
        namaKapal: _realisasiNamaKapalController.text,
        periode: _selectedPeriodeRealisasi,
        waktuArrival: _realisasiWaktuArrival.toIso8601String(),
        waktuBerthing: _realisasiWaktuBerthing.toIso8601String(),
        waktuDeparture: _realisasiWaktuDeparture.toIso8601String(),
        berthingTime: btFormatted,
        realisasiBongkar: int.parse(_realisasiBongkarController.text),
        realisasiMuat: int.parse(_realisasiMuatController.text),
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.insertRealisasiData(realisasiData);

      // Clear form
      _realisasiKodeWSController.clear();
      _realisasiNamaKapalController.clear();
      _realisasiBongkarController.clear();
      _realisasiMuatController.clear();

      // Reload data
      await _loadDatabaseData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Realisasi berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error saving realisasi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Delete Target Data
  Future<void> _deleteTargetData(int id) async {
    try {
      await _dbHelper.deleteTargetData(id);
      await _loadDatabaseData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data target berhasil dihapus!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error deleting target: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Delete Realisasi Data
  Future<void> _deleteRealisasiData(int id) async {
    try {
      await _dbHelper.deleteRealisasiData(id);
      await _loadDatabaseData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data realisasi berhasil dihapus!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error deleting realisasi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _targetPelayaranController.dispose();
    _targetKodeWSController.dispose();
    _targetBongkarController.dispose();
    _targetMuatController.dispose();
    _realisasiPelayaranController.dispose();
    _realisasiKodeWSController.dispose();
    _realisasiNamaKapalController.dispose();
    _realisasiBongkarController.dispose();
    _realisasiMuatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgDark, Color(0xFF051923)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTabButtons(),
                const SizedBox(height: 24),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.accent, AppColors.secondary],
                ).createShader(bounds),
                child: const Text(
                  '🚢 TPK NILAM - Sistem Evaluasi WS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Terminal Petikemas Nilam - Working Schedule Management',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                    .format(_currentDateTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('HH.mm.ss').format(_currentDateTime),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'JetBrains Mono',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    final tabs = [
      '▦ Entry Target',
      '✔ Entry Realisasi',
      '📊 Grafik Analisis',
      '📋 Riwayat Target dan Realisasi'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.secondary],
                        )
                      : null,
                  color: isActive ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? AppColors.secondary : AppColors.border,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildEntryTargetTab();
      case 1:
        return _buildEntryRealisasiTab();
      case 2:
        return _buildGrafikAnalisisTab();
      case 3:
        return _buildDataReferensiTab();
      default:
        return _buildEntryTargetTab();
    }
  }

  // ======================== ENTRY TARGET TAB ========================
  Widget _buildEntryTargetTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Section
        Expanded(
          flex: 1,
          child: _buildCard(
            title: '🎯 Form Entry Target',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel('PELAYARAN'),
                _buildDropdownField(
                  value: _selectedPelayaranTarget,
                  items: pelayaranList,
                  onChanged: (value) {
                    setState(() => _selectedPelayaranTarget = value!);
                  },
                ),
                _buildFormLabel('KODE WS'),
                _buildTextField(
                  controller: _targetKodeWSController,
                  hint: 'Contoh: MMTK',
                ),
                _buildFormLabel('PERIODE'),
                _buildDropdownField(
                  value: _selectedPeriodeTarget,
                  items: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                  onChanged: (value) {
                    setState(() => _selectedPeriodeTarget = value!);
                  },
                ),
                _buildFormLabel('BERTHING TIME (TB)'),
                GestureDetector(
                  onTap: () => _selectDateTimeTargetBerthing(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HARI',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getHariName(_targetWaktuBerthing),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'JAM',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm:ss')
                                    .format(_targetWaktuBerthing),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'JetBrains Mono',
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month,
                                  color: AppColors.secondary, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormLabel('DEPARTURE TIME (TD)'),
                GestureDetector(
                  onTap: () => _selectDateTimeTargetDeparture(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HARI',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getHariName(_targetWaktuDeparture),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'JAM',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm:ss')
                                    .format(_targetWaktuDeparture),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'JetBrains Mono',
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month,
                                  color: AppColors.secondary, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormLabel('BERTHING TIME (BT) - OTOMATIS'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _calculateAndFormatTargetBT(),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TARGET BONGKAR & MUAT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bongkar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _targetBongkarController,
                                  hint: 'ton',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Muat',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _targetMuatController,
                                  hint: 'ton',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSaveButton('Simpan Target', _saveTargetData),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildTargetDataTable(),
        ),
      ],
    );
  }

  // ======================== ENTRY REALISASI TAB ========================
  Widget _buildEntryRealisasiTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildCard(
            title: '✔ Form Entry Realisasi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel('PELAYARAN'),
                _buildDropdownField(
                  value: _selectedPelayaranRealisasi,
                  items: pelayaranList,
                  onChanged: (value) {
                    setState(() => _selectedPelayaranRealisasi = value!);
                  },
                ),
                _buildFormLabel('KODE WS'),
                _buildTextField(
                  controller: _realisasiKodeWSController,
                  hint: 'Contoh: MMTK',
                ),
                _buildFormLabel('NAMA KAPAL'),
                _buildTextField(
                  controller: _realisasiNamaKapalController,
                  hint: 'Contoh: MERATUS BATAM',
                ),
                _buildFormLabel('PERIODE'),
                _buildDropdownField(
                  value: _selectedPeriodeRealisasi,
                  items: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                  onChanged: (value) {
                    setState(() => _selectedPeriodeRealisasi = value!);
                  },
                ),
                _buildFormLabel('WAKTU KEDATANGAN'),
                GestureDetector(
                  onTap: () => _selectDateTimeRealisasi('arrival'),
                  child: _buildDateTimePickerDisplay(_realisasiWaktuArrival),
                ),
                _buildFormLabel('WAKTU BERTHING'),
                GestureDetector(
                  onTap: () => _selectDateTimeRealisasi('berthing'),
                  child: _buildDateTimePickerDisplay(_realisasiWaktuBerthing),
                ),
                _buildFormLabel('WAKTU DEPARTURE'),
                GestureDetector(
                  onTap: () => _selectDateTimeRealisasi('departure'),
                  child: _buildDateTimePickerDisplay(_realisasiWaktuDeparture),
                ),
                _buildFormLabel('BERTHING TIME (OTOMATIS)'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _calculateAndFormatRealisasiBT(),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REALISASI BONGKAR & MUAT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bongkar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _realisasiBongkarController,
                                  hint: 'ton',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Muat',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _realisasiMuatController,
                                  hint: 'ton',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSaveButton('Simpan Realisasi', _saveRealisasiData),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildRealisasiDataTable(),
        ),
      ],
    );
  }

  // ======================== GRAFIK ANALISIS TAB ========================
  Widget _buildGrafikAnalisisTab() {
    return Column(
      children: [
        _buildCard(
          title: '📊 Grafik Analisis - Target vs Realisasi',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildChartControls()),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: _exportChartToPDF,
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label:
                              const Text('PDF', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: _exportChartToExcel,
                          icon: const Icon(Icons.table_chart, size: 16),
                          label: const Text('Excel',
                              style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildAnalysisChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartControls() {
    return Column(
      children: [
        // Periode Selection
        Row(
          children: [
            const Text(
              'PERIODE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                value: _chartPeriode,
                items: ['Minggu', 'Bulan', 'Tahun'],
                onChanged: (value) {
                  setState(() => _chartPeriode = value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Conditional Selection based on Periode
        if (_chartPeriode == 'Minggu')
          Row(
            children: [
              const Text(
                'PILIH MINGGU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  value: _chartSelectedMinggu,
                  items: [
                    'Minggu 1',
                    'Minggu 2',
                    'Minggu 3',
                    'Minggu 4',
                    'Minggu 5'
                  ],
                  onChanged: (value) {
                    setState(() => _chartSelectedMinggu = value!);
                  },
                ),
              ),
            ],
          )
        else if (_chartPeriode == 'Bulan')
          Row(
            children: [
              const Text(
                'PILIH BULAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  value: _chartSelectedBulan,
                  items: [
                    'Januari',
                    'Februari',
                    'Maret',
                    'April',
                    'Mei',
                    'Juni',
                    'Juli',
                    'Agustus',
                    'September',
                    'Oktober',
                    'November',
                    'Desember'
                  ],
                  onChanged: (value) {
                    setState(() => _chartSelectedBulan = value!);
                  },
                ),
              ),
            ],
          )
        else if (_chartPeriode == 'Tahun')
          Row(
            children: [
              const Text(
                'PILIH TAHUN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  value: _chartSelectedTahun,
                  items: ['2022', '2023', '2024', '2025', '2026'],
                  onChanged: (value) {
                    setState(() => _chartSelectedTahun = value!);
                  },
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Pelayaran Selection
        Row(
          children: [
            const Text(
              'PELAYARAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                value: _chartPelayaran,
                items: ['Semua', ...pelayaranList],
                onChanged: (value) {
                  setState(() => _chartPelayaran = value!);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tampilan Selection
        Row(
          children: [
            const Text(
              'TAMPILAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                value: _chartTampilan,
                items: ['Total', 'Per Kapal'],
                onChanged: (value) {
                  setState(() => _chartTampilan = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisChart() {
    // Data sampel untuk setiap week (Realisasi - Target)
    // Negative = lebih cepat/kurang dari target, Positive = lebih lambat/lebih dari target

    return Column(
      children: [
        // Legenda Week
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Week 1', const Color(0xFFE53935)),
            const SizedBox(width: 16),
            _buildLegendItem('Week 2', const Color(0xFFFB8C00)),
            const SizedBox(width: 16),
            _buildLegendItem('Week 3', const Color(0xFFFDD835)),
            const SizedBox(width: 16),
            _buildLegendItem('Week 4', const Color(0xFF43A047)),
            const SizedBox(width: 16),
            _buildLegendItem('Week 5', const Color(0xFF1E88E5)),
          ],
        ),
        const SizedBox(height: 24),
        // Panel 1: SELISIH TB (Time Berthing)
        _buildChartPanel(
          title: 'SELISIH TB (Time Berthing)',
          subtitle: 'Selisih Jam (Menit)',
          minY: -20,
          maxY: 20,
          interval: 10,
          rataRata: '2:31',
          data: [
            [
              -2,
              -3,
              2,
              10,
              -5,
              -8,
              3,
              5,
              -4,
              8,
              -6,
              7,
              -3,
              9,
              -7,
              6,
              -2,
              10,
              5,
              -4,
              11,
              -6,
              12,
              -8,
              7,
              -5
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Panel 2: SELISIH TD (Time Departure)
        _buildChartPanel(
          title: 'SELISIH TD (Time Departure)',
          subtitle: 'Selisih Jam (Menit)',
          minY: -30,
          maxY: 30,
          interval: 10,
          rataRata: '0:23',
          data: [
            [
              -15,
              -14,
              -7,
              13,
              -8,
              -10,
              7,
              9,
              -6,
              10,
              -12,
              8,
              -5,
              12,
              -18,
              9,
              -4,
              14,
              8,
              -7,
              13,
              -9,
              15,
              -11,
              10,
              -6
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Panel 3: SELISIH BT (Berthing Time/Durasi Sandar)
        _buildChartPanel(
          title: 'SELISIH BT (Berthing Time/Durasi Sandar)',
          subtitle: 'Selisih Jam (Menit)',
          minY: -20,
          maxY: 20,
          interval: 10,
          rataRata: '2:19',
          data: [
            [
              -7,
              -6,
              2,
              10,
              -5,
              -8,
              4,
              6,
              -3,
              9,
              -11,
              8,
              -4,
              10,
              -7,
              8,
              -3,
              11,
              6,
              -5,
              12,
              -7,
              10,
              -9,
              8,
              -4
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Panel 4: SELISIH BONGKAR (Discharge)
        _buildChartPanel(
          title: 'SELISIH BONGKAR (Discharge)',
          subtitle: 'Selisih (ton)',
          minY: -300,
          maxY: 300,
          interval: 100,
          rataRata: '-45.0 ton',
          data: [
            [
              150,
              -120,
              -180,
              -100,
              -250,
              -50,
              30,
              100,
              -150,
              60,
              -200,
              -80,
              120,
              200,
              -100,
              80,
              -180,
              250,
              150,
              -120,
              180,
              -140,
              220,
              -160,
              150,
              -100
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Panel 5: SELISIH MUAT (Loading)
        _buildChartPanel(
          title: 'SELISIH MUAT (Loading)',
          subtitle: 'Selisih (ton)',
          minY: -300,
          maxY: 300,
          interval: 100,
          rataRata: '-71.5 ton',
          data: [
            [
              100,
              -150,
              -200,
              -180,
              -250,
              50,
              80,
              150,
              -100,
              100,
              -180,
              -120,
              180,
              200,
              -150,
              100,
              -200,
              220,
              180,
              -150,
              200,
              -160,
              180,
              -180,
              150,
              -120
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChartPanel({
    required String title,
    required String subtitle,
    required double minY,
    required double maxY,
    required double interval,
    required String rataRata,
    required List<List<double>> data,
  }) {
    // Generate x-axis labels (dates)
    final labels = List.generate(26, (index) {
      final day = 27 + index;
      final month = day > 31 ? 1 : 12;
      final adjustedDay = day > 31 ? day - 31 : day;
      return 'S${adjustedDay}/${month}';
    });

    // Define colors for each week
    final weekColors = [
      const Color(0xFFE53935), // Week 1 - Red
      const Color(0xFFFB8C00), // Week 2 - Orange
      const Color(0xFFFDD835), // Week 3 - Yellow
      const Color(0xFF43A047), // Week 4 - Green
      const Color(0xFF1E88E5), // Week 5 - Blue
    ];

    // Create spots grouped by week (5 data points per week from the sample data)
    List<LineChartBarData> lineBars = [];

    for (int week = 0; week < 5; week++) {
      List<FlSpot> spots = [];
      for (int i = 0; i < 5; i++) {
        int dataIndex = week * 5 + i;
        if (dataIndex < data[0].length) {
          spots.add(FlSpot(dataIndex.toDouble(), data[0][dataIndex]));
        }
      }

      if (spots.isNotEmpty) {
        lineBars.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: weekColors[week],
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: weekColors[week],
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rata-rata: $rataRata',
                  style: const TextStyle(
                    color: Color(0xFFFDD835),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    if (value == 0) {
                      return FlLine(
                        color: AppColors.textSecondary,
                        strokeWidth: 1.5,
                        dashArray: [5, 3],
                      );
                    }
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.2),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 &&
                            index < labels.length &&
                            index % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontFamily: 'JetBrains Mono',
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                lineBarsData: lineBars,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final week = (barSpot.x / 5).floor() + 1;
                        return LineTooltipItem(
                          'Week $week\n${barSpot.y.toStringAsFixed(1)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================== RIWAYAT TAB ========================
  Widget _buildDataReferensiTab() {
    return _buildCard(
      title: '📋 Riwayat Target dan Realisasi',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari kapal / WS...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.secondary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: _exportTableToPDF,
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('PDF', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: _exportTableToExcel,
                      icon: const Icon(Icons.table_chart, size: 16),
                      label:
                          const Text('Excel', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDataReferensiTable(),
        ],
      ),
    );
  }

  Widget _buildTargetDataTable() {
    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_targetDataList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Belum ada data target.\nSilakan input data baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          AppColors.bgLight.withOpacity(0.5),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.bgLight.withOpacity(0.3);
            }
            return Colors.transparent;
          },
        ),
        columns: const [
          DataColumn(label: Text('NO')),
          DataColumn(label: Text('PELAYARAN')),
          DataColumn(label: Text('WS')),
          DataColumn(label: Text('WEEK')),
          DataColumn(label: Text('TB')),
          DataColumn(label: Text('TD')),
          DataColumn(label: Text('BT')),
          DataColumn(label: Text('TARGET (B/M)')),
          DataColumn(label: Text('AKSI')),
        ],
        rows: _targetDataList.asMap().entries.map((entry) {
          int index = entry.key;
          TargetData data = entry.value;

          // Format DateTime
          final tbDate = DateTime.parse(data.waktuBerthing);
          final tdDate = DateTime.parse(data.waktuDeparture);
          final tbFormatted = DateFormat('dd/MM HH:mm').format(tbDate);
          final tdFormatted = DateFormat('dd/MM HH:mm').format(tdDate);

          return _buildTargetDataTableRow(
            no: '${index + 1}',
            pelayaran: data.pelayaran,
            ws: data.kodeWS,
            week: data.periode,
            tb: tbFormatted,
            td: tdFormatted,
            bt: data.berthingTime,
            target: '${data.targetBongkar} / ${data.targetMuat}',
            onDelete: () => _deleteTargetData(data.id!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealisasiDataTable() {
    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_realisasiDataList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Belum ada data realisasi.\nSilakan input data baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          AppColors.bgLight.withOpacity(0.5),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.bgLight.withOpacity(0.3);
            }
            return Colors.transparent;
          },
        ),
        columns: const [
          DataColumn(label: Text('NO')),
          DataColumn(label: Text('PELAYARAN')),
          DataColumn(label: Text('WS')),
          DataColumn(label: Text('KAPAL')),
          DataColumn(label: Text('WEEK')),
          DataColumn(label: Text('TA')),
          DataColumn(label: Text('TB')),
          DataColumn(label: Text('TD')),
          DataColumn(label: Text('BT')),
          DataColumn(label: Text('REALISASI (B/M)')),
          DataColumn(label: Text('AKSI')),
        ],
        rows: _realisasiDataList.asMap().entries.map((entry) {
          int index = entry.key;
          RealisasiData data = entry.value;

          // Format DateTime
          final taDate = DateTime.parse(data.waktuArrival);
          final tbDate = DateTime.parse(data.waktuBerthing);
          final tdDate = DateTime.parse(data.waktuDeparture);
          final taFormatted = DateFormat('dd/MM HH:mm').format(taDate);
          final tbFormatted = DateFormat('dd/MM HH:mm').format(tbDate);
          final tdFormatted = DateFormat('dd/MM HH:mm').format(tdDate);

          return _buildRealisasiDataTableRow(
            no: '${index + 1}',
            pelayaran: data.pelayaran,
            ws: data.kodeWS,
            kapal: data.namaKapal,
            week: data.periode,
            ta: taFormatted,
            tb: tbFormatted,
            td: tdFormatted,
            bt: data.berthingTime,
            realisasi: '${data.realisasiBongkar} / ${data.realisasiMuat}',
            onDelete: () => _deleteRealisasiData(data.id!),
          );
        }).toList(),
      ),
    );
  }

  DataRow _buildTargetDataTableRow({
    required String no,
    required String pelayaran,
    required String ws,
    required String week,
    required String tb,
    required String td,
    required String bt,
    required String target,
    required VoidCallback onDelete,
  }) {
    return DataRow(cells: [
      DataCell(Text(no)),
      DataCell(Text(pelayaran,
          style: const TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.w600))),
      DataCell(Text(ws,
          style: const TextStyle(
              color: AppColors.accent, fontWeight: FontWeight.w600))),
      DataCell(Text(week)),
      DataCell(Text(tb,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(td,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(bt,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(target,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Row(
        children: [
          InkWell(
            onTap: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Edit',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onDelete,
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      )),
    ]);
  }

  DataRow _buildRealisasiDataTableRow({
    required String no,
    required String pelayaran,
    required String ws,
    required String kapal,
    required String week,
    required String ta,
    required String tb,
    required String td,
    required String bt,
    required String realisasi,
    required VoidCallback onDelete,
  }) {
    return DataRow(cells: [
      DataCell(Text(no)),
      DataCell(Text(pelayaran,
          style: const TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.w600))),
      DataCell(Text(ws,
          style: const TextStyle(
              color: AppColors.accent, fontWeight: FontWeight.w600))),
      DataCell(Text(kapal)),
      DataCell(Text(week)),
      DataCell(Text(ta,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(tb,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(td,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(bt,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(realisasi,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Row(
        children: [
          InkWell(
            onTap: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Edit',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onDelete,
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      )),
    ]);
  }

  Widget _buildDataReferensiTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          AppColors.bgLight.withOpacity(0.5),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.bgLight.withOpacity(0.3);
            }
            return Colors.transparent;
          },
        ),
        columns: const [
          DataColumn(label: Text('NO')),
          DataColumn(label: Text('PELAYARAN')),
          DataColumn(label: Text('WS')),
          DataColumn(label: Text('KAPAL')),
          DataColumn(label: Text('WEEK')),
          DataColumn(label: Text('TA')),
          DataColumn(label: Text('TB')),
          DataColumn(label: Text('TD')),
          DataColumn(label: Text('BT')),
          DataColumn(label: Text('TARGET (B/M)')),
          DataColumn(label: Text('REALISASI (B/M)')),
          DataColumn(label: Text('ACHIEVEMENT')),
          DataColumn(label: Text('AKSI')),
        ],
        rows: [
          _buildDataReferensiDataTableRow(
              no: '1',
              pelayaran: 'MERATUS',
              ws: 'MMTK',
              kapal: 'MERATUS BATAM',
              week: '1',
              ta: '28/12 02:40',
              tb: '28/12 03:30',
              td: '28/12 15:25',
              bt: '11:55',
              target: '512 / 0',
              realisasi: '512 / 0',
              achievement: '100% / -'),
          _buildDataReferensiDataTableRow(
              no: '2',
              pelayaran: 'MERATUS',
              ws: 'MMTK',
              kapal: 'MERATUS LABUAN BAJO',
              week: '2',
              ta: '04/01 11:10',
              tb: '04/01 12:23',
              td: '05/01 11:42',
              bt: '23:19',
              target: '401 / 512',
              realisasi: '401 / 512',
              achievement: '100% / 100%'),
          _buildDataReferensiDataTableRow(
              no: '3',
              pelayaran: 'MERATUS',
              ws: 'MMTK',
              kapal: 'MERATUS LARANTUKA',
              week: '3',
              ta: '11/01 17:58',
              tb: '11/01 18:18',
              td: '12/01 12:34',
              bt: '18:16',
              target: '409 / 391',
              realisasi: '409 / 391',
              achievement: '100% / 100%'),
          _buildDataReferensiDataTableRow(
              no: '4',
              pelayaran: 'MERATUS',
              ws: 'MPMI',
              kapal: 'MERATUS GORONTALO',
              week: '1',
              ta: '28/12 21:27',
              tb: '28/12 22:19',
              td: '29/12 18:15',
              bt: '19:56',
              target: '324 / 348',
              realisasi: '324 / 348',
              achievement: '100% / 100%'),
          _buildDataReferensiDataTableRow(
              no: '5',
              pelayaran: 'SPIL',
              ws: 'SKD1',
              kapal: 'SPIL RETNO',
              week: '1',
              ta: '27/12 18:52',
              tb: '27/12 18:59',
              td: '28/12 15:20',
              bt: '20:21',
              target: '400 / 430',
              realisasi: '400 / 430',
              achievement: '100% / 100%'),
          _buildDataReferensiDataTableRow(
              no: '6',
              pelayaran: 'SPIL',
              ws: 'SSR1',
              kapal: 'BALI AYU',
              week: '1',
              ta: '29/12 01:18',
              tb: '29/12 01:18',
              td: '29/12 06:41',
              bt: '05:23',
              target: '245 / 0',
              realisasi: '245 / 0',
              achievement: '100% / -'),
        ],
      ),
    );
  }

  DataRow _buildDataReferensiDataTableRow({
    required String no,
    required String pelayaran,
    required String ws,
    required String kapal,
    required String week,
    required String ta,
    required String tb,
    required String td,
    required String bt,
    required String target,
    required String realisasi,
    required String achievement,
  }) {
    return DataRow(cells: [
      DataCell(Text(no)),
      DataCell(Text(pelayaran,
          style: const TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.w600))),
      DataCell(Text(ws,
          style: const TextStyle(
              color: AppColors.accent, fontWeight: FontWeight.w600))),
      DataCell(Text(kapal)),
      DataCell(Text(week)),
      DataCell(Text(ta,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(tb,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(td,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(bt,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(target,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(realisasi,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Text(achievement,
          style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'))),
      DataCell(Row(
        children: [
          InkWell(
            onTap: () => _showEditDialog(
                kapal: kapal, ws: ws, pelayaran: pelayaran, week: week),
            child: const Text('Edit',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _showDeleteConfirmation(kapal),
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      )),
    ]);
  }

  // ======================== HELPER WIDGETS ========================
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.accent, AppColors.secondary],
            ).createShader(bounds),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.bgDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bgCard,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTimeRealisasi(String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: type == 'arrival'
          ? _realisasiWaktuArrival
          : type == 'berthing'
              ? _realisasiWaktuBerthing
              : _realisasiWaktuDeparture,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          type == 'arrival'
              ? _realisasiWaktuArrival
              : type == 'berthing'
                  ? _realisasiWaktuBerthing
                  : _realisasiWaktuDeparture,
        ),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );

          if (type == 'arrival') {
            _realisasiWaktuArrival = newDateTime;
          } else if (type == 'berthing') {
            _realisasiWaktuBerthing = newDateTime;
          } else {
            _realisasiWaktuDeparture = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _selectDateTimeTargetBerthing() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetWaktuBerthing,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_targetWaktuBerthing),
      );

      if (time != null) {
        setState(() {
          _targetWaktuBerthing = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectDateTimeTargetDeparture() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetWaktuDeparture,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_targetWaktuDeparture),
      );

      if (time != null) {
        setState(() {
          _targetWaktuDeparture = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _getHariName(DateTime date) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[date.weekday - 1];
  }

  String _calculateAndFormatRealisasiBT() {
    // BT = TD - TB (Waktu Departure - Waktu Berthing)
    Duration difference =
        _realisasiWaktuDeparture.difference(_realisasiWaktuBerthing);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    // Format: jam:menit:detik
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return '$formattedTime jam (Otomatis berhasil)';
  }

  String _calculateAndFormatTargetBT() {
    // BT = TD - TB (Waktu Departure Target - Waktu Berthing Target)
    Duration difference =
        _targetWaktuDeparture.difference(_targetWaktuBerthing);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    // Format: jam:menit:detik
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return '$formattedTime jam (Otomatis)';
  }

  Widget _buildDateTimePickerDisplay(DateTime dateTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TANGGAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(dateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'JetBrains Mono',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.border,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'JAM',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm:ss').format(dateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'JetBrains Mono',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.border,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month,
                    color: AppColors.secondary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================== EXPORT FUNCTIONS ========================
  Future<void> _exportChartToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Grafik Analisis - Target vs Realisasi',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Periode: $_chartPeriode${_chartPeriode == 'Minggu' ? ' ($_chartSelectedMinggu)' : _chartPeriode == 'Bulan' ? ' ($_chartSelectedBulan)' : ' ($_chartSelectedTahun)'} | Pelayaran: $_chartPelayaran | Tampilan: $_chartTampilan',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text('Data Grafik:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Hari',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Target Bongkar',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Realisasi Bongkar',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Target Muat',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Realisasi Muat',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Selasa')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('700')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('680')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('700')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('680')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rabu')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('680')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('650')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('680')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('650')),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportChartToExcel() async {
    var excelFile = excel_pkg.Excel.createExcel();
    excel_pkg.Sheet sheetObject = excelFile['Sheet1'];

    sheetObject.appendRow(['Grafik Analisis - Target vs Realisasi']);
    sheetObject.appendRow([
      'Periode: $_chartPeriode${_chartPeriode == 'Minggu' ? ' ($_chartSelectedMinggu)' : _chartPeriode == 'Bulan' ? ' ($_chartSelectedBulan)' : ' ($_chartSelectedTahun)'} | Pelayaran: $_chartPelayaran | Tampilan: $_chartTampilan'
    ]);
    sheetObject.appendRow([]);
    sheetObject.appendRow([
      'Hari',
      'Target Bongkar',
      'Realisasi Bongkar',
      'Target Muat',
      'Realisasi Muat'
    ]);
    sheetObject.appendRow(['Selasa', 700, 680, 700, 680]);
    sheetObject.appendRow(['Rabu', 680, 650, 680, 650]);
    sheetObject.appendRow(['Kamis', 620, 590, 620, 590]);
    sheetObject.appendRow(['Jumat', 600, 570, 600, 570]);
    sheetObject.appendRow(['Sabtu', 610, 580, 610, 580]);
    sheetObject.appendRow(['Minggu', 680, 650, 680, 650]);
    sheetObject.appendRow(['Senin', 710, 680, 710, 680]);
    sheetObject.appendRow([]);
    sheetObject.appendRow(
        ['Dicetak', DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())]);

    var fileBytes = excelFile.encode();
    if (fileBytes != null) {
      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chart exported to Excel successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportTableToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Riwayat Target dan Realisasi',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FixedColumnWidth(35),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(60),
                  7: const pw.FixedColumnWidth(60),
                  8: const pw.FixedColumnWidth(40),
                  9: const pw.FixedColumnWidth(60),
                  10: const pw.FixedColumnWidth(60),
                  11: const pw.FixedColumnWidth(50),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('NO',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('PELAYARAN',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('WS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('KAPAL',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('WEEK',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('TA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('TB',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('TD',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('BT',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('TARGET (B/M)',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('REALISASI (B/M)',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('ACHIEVEMENT',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9))),
                    ],
                  ),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('1',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MERATUS',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MMTK',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MERATUS BATAM',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('1',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('28/12 02:40',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('28/12 03:30',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('28/12 15:25',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('11:55',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('512 / 400',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('512 / 0',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('56%',
                            style: const pw.TextStyle(fontSize: 9))),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('2',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MERATUS',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MMTK',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('MERATUS LABUAN BAJO',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('2',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('04/01 11:10',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('04/01 12:23',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('05/01 11:42',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('23:19',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('512 / 500',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('401 / 512',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('90%',
                            style: const pw.TextStyle(fontSize: 9))),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportTableToExcel() async {
    var excelFile = excel_pkg.Excel.createExcel();
    excel_pkg.Sheet sheetObject = excelFile['Sheet1'];

    sheetObject.appendRow(['Riwayat Target dan Realisasi']);
    sheetObject.appendRow(
        ['Dicetak', DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())]);
    sheetObject.appendRow([]);
    sheetObject.appendRow([
      'NO',
      'PELAYARAN',
      'WS',
      'KAPAL',
      'WEEK',
      'TA',
      'TB',
      'TD',
      'BT',
      'TARGET (B/M)',
      'REALISASI (B/M)',
      'ACHIEVEMENT'
    ]);
    sheetObject.appendRow([
      '1',
      'MERATUS',
      'MMTK',
      'MERATUS BATAM',
      '1',
      '28/12 02:40',
      '28/12 03:30',
      '28/12 15:25',
      '11:55',
      '512 / 400',
      '512 / 0',
      '56%'
    ]);
    sheetObject.appendRow([
      '2',
      'MERATUS',
      'MMTK',
      'MERATUS LABUAN BAJO',
      '2',
      '04/01 11:10',
      '04/01 12:23',
      '05/01 11:42',
      '23:19',
      '512 / 500',
      '401 / 512',
      '90%'
    ]);
    sheetObject.appendRow([
      '3',
      'MERATUS',
      'MMTK',
      'MERATUS LARANTUKA',
      '3',
      '11/01 17:58',
      '11/01 18:18',
      '12/01 12:34',
      '18:16',
      '400 / 400',
      '409 / 391',
      '188%'
    ]);

    var fileBytes = excelFile.encode();
    if (fileBytes != null) {
      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Table exported to Excel successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // ======================== EDIT & DELETE DIALOGS ========================
  void _showEditDialog({
    required String kapal,
    required String ws,
    required String pelayaran,
    required String week,
  }) {
    final namaKapalController = TextEditingController(text: kapal);
    final wsController = TextEditingController(text: ws);
    final weekController = TextEditingController(text: week);
    final bongkarController = TextEditingController();
    final muatController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Text(
            'Edit Data - $kapal',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogFormField(
                  label: 'Nama Kapal',
                  controller: namaKapalController,
                ),
                const SizedBox(height: 12),
                _buildDialogFormField(
                  label: 'WS',
                  controller: wsController,
                ),
                const SizedBox(height: 12),
                _buildDialogFormField(
                  label: 'Pelayaran',
                  controller: TextEditingController(text: pelayaran),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                _buildDialogFormField(
                  label: 'Week',
                  controller: weekController,
                ),
                const SizedBox(height: 12),
                _buildDialogFormField(
                  label: 'Realisasi Bongkar',
                  controller: bongkarController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildDialogFormField(
                  label: 'Realisasi Muat',
                  controller: muatController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil diperbarui'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String kapal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text(
            'Konfirmasi Penghapusan',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data kapal "$kapal"?\n\nTindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
