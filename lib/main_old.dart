import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart';
import 'models/evaluasi_data.dart';

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

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();

  // Form Controllers
  final _namaKapalController = TextEditingController();
  final _targetBongkarController = TextEditingController();
  final _realisasiBongkarController = TextEditingController();
  final _targetMuatController = TextEditingController();
  final _realisasiMuatController = TextEditingController();
  final _keteranganController = TextEditingController();
  String _selectedShift = 'Shift 1';
  String _selectedPelayaran = 'Pelayaran 1';

  // Chart Controls
  String _currentPeriod = 'week';
  String _currentPelayaran = 'all';

  // Search
  final _searchController = TextEditingController();

  // Database
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<EvaluasiData> _dataTable = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _dbHelper.getAllEvaluasi();
    final stats = await _dbHelper.getStatistics();

    setState(() {
      _dataTable = data;
      _statistics = stats;
      _isLoading = false;
    });
  }

  Future<void> _searchData(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = await _dbHelper.searchEvaluasi(query);

    setState(() {
      _dataTable = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    _namaKapalController.dispose();
    _targetBongkarController.dispose();
    _realisasiBongkarController.dispose();
    _targetMuatController.dispose();
    _realisasiMuatController.dispose();
    _keteranganController.dispose();
    _searchController.dispose();
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
                _buildTabNavigation(),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Top Border Animation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.accent,
                    AppColors.secondary
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
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
                        'TPK Nilam Evaluasi WS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sistem Monitoring Performa',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                          .format(_currentDateTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm:ss').format(_currentDateTime),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton('INPUT DATA', 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTabButton('MONITORING', 1),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.secondary],
                )
              : const LinearGradient(
                  colors: [AppColors.bgCard, AppColors.bgLight],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        _buildInputTab(),
        _buildMonitoringTab(),
      ],
    );
  }

  Widget _buildInputTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Section
        Expanded(
          flex: 1,
          child: _buildCard(
            title: '📝 Input Data Evaluasi',
            child: Column(
              children: [
                _buildFormGroup(
                  label: 'NAMA KAPAL',
                  child: _buildTextField(
                    controller: _namaKapalController,
                    hint: 'Contoh: MV Ocean Star',
                  ),
                ),
                _buildFormGroup(
                  label: 'SHIFT',
                  child: _buildDropdown(
                    value: _selectedShift,
                    items: ['Shift 1', 'Shift 2', 'Shift 3'],
                    onChanged: (value) =>
                        setState(() => _selectedShift = value!),
                  ),
                ),
                _buildFormGroup(
                  label: 'PELAYARAN',
                  child: _buildDropdown(
                    value: _selectedPelayaran,
                    items: ['Pelayaran 1', 'Pelayaran 2', 'Pelayaran 3'],
                    onChanged: (value) =>
                        setState(() => _selectedPelayaran = value!),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TARGET & REALISASI BONGKAR',
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
                      child: _buildFormGroup(
                        label: 'TARGET (TON)',
                        child: _buildTextField(
                          controller: _targetBongkarController,
                          hint: '650',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormGroup(
                        label: 'REALISASI (TON)',
                        child: _buildTextField(
                          controller: _realisasiBongkarController,
                          hint: '615',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'TARGET & REALISASI MUAT',
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
                      child: _buildFormGroup(
                        label: 'TARGET (TON)',
                        child: _buildTextField(
                          controller: _targetMuatController,
                          hint: '690',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormGroup(
                        label: 'REALISASI (TON)',
                        child: _buildTextField(
                          controller: _realisasiMuatController,
                          hint: '680',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildFormGroup(
                  label: 'KETERANGAN',
                  child: _buildTextField(
                    controller: _keteranganController,
                    hint: 'Tambahkan catatan...',
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGradientButton(
                  text: 'SIMPAN DATA',
                  onPressed: _saveData,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Statistics Section
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatisticsGrid(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonitoringTab() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildCard(
                title: '📊 Grafik Performa',
                child: Column(
                  children: [
                    _buildChartControls(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
                      child: _buildChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _buildQuickStats(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildDataTable(),
      ],
    );
  }

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

  Widget _buildFormGroup({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFF0A1929),
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bgCard,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
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

  Widget _buildGradientButton(
      {required String text, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF00C853)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    final totalBongkar = _statistics['totalBongkar'] ?? 0;
    final totalMuat = _statistics['totalMuat'] ?? 0;
    final avgBongkar = _statistics['avgBongkar'] ?? 0;
    final avgMuat = _statistics['avgMuat'] ?? 0;
    final persenBongkar = _statistics['persenBongkar'] ?? 0.0;
    final persenMuat = _statistics['persenMuat'] ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Bongkar',
          value: totalBongkar.toString(),
          unit: 'ton',
          percentage: persenBongkar,
          color: AppColors.success,
          icon: Icons.download,
        ),
        _buildStatCard(
          title: 'Total Muat',
          value: totalMuat.toString(),
          unit: 'ton',
          percentage: persenMuat,
          color: AppColors.secondary,
          icon: Icons.upload,
        ),
        _buildStatCard(
          title: 'Rata-rata Bongkar',
          value: avgBongkar.toString(),
          unit: 'ton/hari',
          percentage: avgBongkar > 0 ? (avgBongkar / 650 * 100) : 0.0,
          color: AppColors.warning,
          icon: Icons.trending_down,
        ),
        _buildStatCard(
          title: 'Rata-rata Muat',
          value: avgMuat.toString(),
          unit: 'ton/hari',
          percentage: avgMuat > 0 ? (avgMuat / 690 * 100) : 0.0,
          color: AppColors.accent,
          icon: Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'JetBrains Mono',
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}% dari target',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      percentage >= 90 ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_isLoading) {
      return _buildCard(
        title: '📋 Aktivitas Terakhir',
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return _buildCard(
      title: '📋 Aktivitas Terakhir',
      child: _dataTable.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: _dataTable.take(5).map((data) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1929),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_boat,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.kapal,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${data.shift} • ${data.tanggal}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${data.persenBongkar.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildChartControls() {
    return Column(
      children: [
        // Period Control
        Row(
          children: [
            const Text(
              'PERIODE: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  _buildControlButton('Minggu', _currentPeriod == 'week', () {
                    setState(() => _currentPeriod = 'week');
                  }),
                  const SizedBox(width: 8),
                  _buildControlButton('Bulan', _currentPeriod == 'month', () {
                    setState(() => _currentPeriod = 'month');
                  }),
                  const SizedBox(width: 8),
                  _buildControlButton('Tahun', _currentPeriod == 'year', () {
                    setState(() => _currentPeriod = 'year');
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Pelayaran Control
        Row(
          children: [
            const Text(
              'PELAYARAN: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  _buildControlButton('Semua', _currentPelayaran == 'all', () {
                    setState(() => _currentPelayaran = 'all');
                  }),
                  const SizedBox(width: 8),
                  _buildControlButton('Pel. 1', _currentPelayaran == 'pel1',
                      () {
                    setState(() => _currentPelayaran = 'pel1');
                  }),
                  const SizedBox(width: 8),
                  _buildControlButton('Pel. 2', _currentPelayaran == 'pel2',
                      () {
                    setState(() => _currentPelayaran = 'pel2');
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(
      String text, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.secondary],
                  )
                : null,
            color: isActive ? null : const Color(0xFF0A1929),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final labels = _getChartLabels();
    final targetBongkar = _getTargetBongkarData();
    final realisasiBongkar = _getRealisasiBongkarData();
    final targetMuat = _getTargetMuatData();
    final realisasiMuat = _getRealisasiMuatData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.border.withOpacity(0.5),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
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
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
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
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Target Bongkar (dashed)
          LineChartBarData(
            spots: targetBongkar.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppColors.success.withOpacity(0.5),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            dashArray: [5, 5],
            belowBarData: BarAreaData(show: false),
          ),
          // Realisasi Bongkar
          LineChartBarData(
            spots: realisasiBongkar.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withOpacity(0.2),
            ),
          ),
          // Target Muat (dashed)
          LineChartBarData(
            spots: targetMuat.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppColors.secondary.withOpacity(0.5),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            dashArray: [5, 5],
            belowBarData: BarAreaData(show: false),
          ),
          // Realisasi Muat
          LineChartBarData(
            spots: realisasiMuat.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getChartLabels() {
    if (_currentPeriod == 'week') {
      return ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    } else if (_currentPeriod == 'month') {
      return ['W1', 'W2', 'W3', 'W4', 'W5'];
    } else {
      return [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
    }
  }

  List<double> _getTargetBongkarData() {
    if (_currentPeriod == 'week') {
      return [650, 650, 650, 650, 650, 650, 650];
    } else if (_currentPeriod == 'month') {
      return [3250, 3250, 3250, 3250, 3250];
    } else {
      return [
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000,
        14000
      ];
    }
  }

  List<double> _getRealisasiBongkarData() {
    if (_currentPeriod == 'week') {
      return [615, 580, 625, 510, 517, 560, 590];
    } else if (_currentPeriod == 'month') {
      return [3075, 2900, 3125, 2550, 2585];
    } else {
      return [
        12500,
        13200,
        13800,
        12900,
        14100,
        13500,
        13700,
        14200,
        13900,
        13400,
        14000,
        13600
      ];
    }
  }

  List<double> _getTargetMuatData() {
    if (_currentPeriod == 'week') {
      return [690, 690, 690, 690, 690, 690, 690];
    } else if (_currentPeriod == 'month') {
      return [3450, 3450, 3450, 3450, 3450];
    } else {
      return [
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000,
        15000
      ];
    }
  }

  List<double> _getRealisasiMuatData() {
    if (_currentPeriod == 'week') {
      return [680, 645, 622, 618, 617, 640, 670];
    } else if (_currentPeriod == 'month') {
      return [3400, 3225, 3110, 3090, 3085];
    } else {
      return [
        13800,
        14200,
        14600,
        13900,
        15200,
        14500,
        14800,
        15100,
        14700,
        14300,
        14900,
        14600
      ];
    }
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        _buildQuickStatCard(
          icon: Icons.show_chart,
          title: 'Efisiensi Bongkar',
          value: '92.3%',
          trend: '+2.5%',
          isPositive: true,
        ),
        const SizedBox(height: 16),
        _buildQuickStatCard(
          icon: Icons.trending_up,
          title: 'Efisiensi Muat',
          value: '95.5%',
          trend: '+1.8%',
          isPositive: true,
        ),
        const SizedBox(height: 16),
        _buildQuickStatCard(
          icon: Icons.access_time,
          title: 'Waktu Rata-rata',
          value: '8.5 jam',
          trend: '-0.5 jam',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'JetBrains Mono',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.danger)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return _buildCard(
      title: '📑 Data Evaluasi',
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Cari data...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
              filled: true,
              fillColor: const Color(0xFF0A1929),
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
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
            onChanged: (value) {
              _searchData(value);
            },
          ),
          const SizedBox(height: 20),
          // Table
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
              : _dataTable.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Belum ada data',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
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
                          DataColumn(
                              label: Text('Tanggal',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Shift',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Nama Kapal',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Pelayaran',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Target B.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Real. B.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Target M.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Real. M.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('% B.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('% M.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Keterangan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _dataTable.map((data) {
                          return DataRow(cells: [
                            DataCell(Text(data.tanggal)),
                            DataCell(Text(data.shift)),
                            DataCell(Text(data.kapal)),
                            DataCell(Text(data.pelayaran)),
                            DataCell(Text('${data.targetBongkar}')),
                            DataCell(Text('${data.realisasiBongkar}')),
                            DataCell(Text('${data.targetMuat}')),
                            DataCell(Text('${data.realisasiMuat}')),
                            DataCell(
                              Text(
                                '${data.persenBongkar.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: data.persenBongkar >= 90
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${data.persenMuat.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: data.persenMuat >= 90
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(data.keterangan)),
                          ]);
                        }).toList(),
                      ),
                    ),
        ],
      ),
    );
  }

  void _saveData() async {
    // Validate inputs
    if (_namaKapalController.text.isEmpty) {
      _showSnackBar('Mohon isi nama kapal', isError: true);
      return;
    }

    final targetBongkar = double.tryParse(_targetBongkarController.text);
    final realisasiBongkar = double.tryParse(_realisasiBongkarController.text);
    final targetMuat = double.tryParse(_targetMuatController.text);
    final realisasiMuat = double.tryParse(_realisasiMuatController.text);

    if (targetBongkar == null ||
        realisasiBongkar == null ||
        targetMuat == null ||
        realisasiMuat == null) {
      _showSnackBar('Mohon isi semua data dengan benar', isError: true);
      return;
    }

    // Calculate percentages
    final persenBongkar = (realisasiBongkar / targetBongkar) * 100;
    final persenMuat = (realisasiMuat / targetMuat) * 100;

    // Create EvaluasiData object
    final newData = EvaluasiData(
      tanggal: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      shift: _selectedShift,
      kapal: _namaKapalController.text,
      pelayaran: _selectedPelayaran,
      targetBongkar: targetBongkar.toInt(),
      realisasiBongkar: realisasiBongkar.toInt(),
      targetMuat: targetMuat.toInt(),
      realisasiMuat: realisasiMuat.toInt(),
      persenBongkar: persenBongkar,
      persenMuat: persenMuat,
      keterangan: _keteranganController.text.isEmpty
          ? 'Normal'
          : _keteranganController.text,
    );

    // Save to database
    try {
      await _dbHelper.insertEvaluasi(newData);

      // Clear form
      _namaKapalController.clear();
      _targetBongkarController.clear();
      _realisasiBongkarController.clear();
      _targetMuatController.clear();
      _realisasiMuatController.clear();
      _keteranganController.clear();

      // Reload data
      await _loadData();

      _showSnackBar('Data berhasil disimpan!');
    } catch (e) {
      _showSnackBar('Gagal menyimpan data: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
