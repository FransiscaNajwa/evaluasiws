-- =====================================================
-- Database SQL untuk PHPMyAdmin
-- TPK Nilam - Sistem Evaluasi WS
-- =====================================================

-- Buat database baru
CREATE DATABASE IF NOT EXISTS `evaluasiws` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `evaluasiws`;

-- =====================================================
-- Tabel: evaluasi
-- =====================================================
CREATE TABLE IF NOT EXISTS `evaluasi` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tanggal` varchar(20) NOT NULL,
  `shift` varchar(50) NOT NULL,
  `kapal` varchar(100) NOT NULL,
  `pelayaran` varchar(50) NOT NULL,
  `target_bongkar` int(11) NOT NULL,
  `realisasi_bongkar` int(11) NOT NULL,
  `target_muat` int(11) NOT NULL,
  `realisasi_muat` int(11) NOT NULL,
  `persen_bongkar` decimal(5,2) NOT NULL,
  `persen_muat` decimal(5,2) NOT NULL,
  `keterangan` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tanggal` (`tanggal`),
  KEY `idx_shift` (`shift`),
  KEY `idx_pelayaran` (`pelayaran`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Insert Sample Data
-- =====================================================
INSERT INTO `evaluasi` (`tanggal`, `shift`, `kapal`, `pelayaran`, `target_bongkar`, `realisasi_bongkar`, `target_muat`, `realisasi_muat`, `persen_bongkar`, `persen_muat`, `keterangan`) VALUES
('10/02/2026', 'Shift 1', 'MV Ocean Star', 'Pelayaran 1', 650, 615, 690, 680, 94.62, 98.55, 'Normal'),
('10/02/2026', 'Shift 2', 'MV Pacific Wave', 'Pelayaran 2', 650, 580, 690, 645, 89.23, 93.48, 'Cuaca buruk'),
('09/02/2026', 'Shift 1', 'MV Atlantic Hope', 'Pelayaran 1', 650, 625, 690, 622, 96.15, 90.14, 'Normal'),
('09/02/2026', 'Shift 2', 'MV Indian Pride', 'Pelayaran 3', 650, 510, 690, 618, 78.46, 89.57, 'Delay karena cuaca'),
('09/02/2026', 'Shift 3', 'MV Arctic Dawn', 'Pelayaran 2', 650, 517, 690, 617, 79.54, 89.42, 'Perbaikan crane'),
('08/02/2026', 'Shift 1', 'MV Solar Breeze', 'Pelayaran 1', 650, 560, 690, 640, 86.15, 92.75, 'Normal'),
('08/02/2026', 'Shift 2', 'MV Luna Star', 'Pelayaran 2', 650, 590, 690, 670, 90.77, 97.10, 'Normal');

-- =====================================================
-- Tabel: users (untuk login sistem)
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `role` enum('admin','operator','viewer') NOT NULL DEFAULT 'operator',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin user (password: admin123)
INSERT INTO `users` (`username`, `password`, `nama_lengkap`, `role`) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin'),
('operator1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Operator Shift 1', 'operator');

-- =====================================================
-- View untuk Statistik
-- =====================================================
CREATE OR REPLACE VIEW `view_statistik` AS
SELECT 
    COUNT(*) as total_records,
    SUM(realisasi_bongkar) as total_bongkar,
    SUM(realisasi_muat) as total_muat,
    AVG(realisasi_bongkar) as avg_bongkar,
    AVG(realisasi_muat) as avg_muat,
    AVG(persen_bongkar) as avg_persen_bongkar,
    AVG(persen_muat) as avg_persen_muat
FROM evaluasi;

-- =====================================================
-- View untuk Statistik per Shift
-- =====================================================
CREATE OR REPLACE VIEW `view_statistik_shift` AS
SELECT 
    shift,
    COUNT(*) as total_records,
    SUM(realisasi_bongkar) as total_bongkar,
    SUM(realisasi_muat) as total_muat,
    AVG(realisasi_bongkar) as avg_bongkar,
    AVG(realisasi_muat) as avg_muat,
    AVG(persen_bongkar) as avg_persen_bongkar,
    AVG(persen_muat) as avg_persen_muat
FROM evaluasi
GROUP BY shift;

-- =====================================================
-- View untuk Statistik per Pelayaran
-- =====================================================
CREATE OR REPLACE VIEW `view_statistik_pelayaran` AS
SELECT 
    pelayaran,
    COUNT(*) as total_records,
    SUM(realisasi_bongkar) as total_bongkar,
    SUM(realisasi_muat) as total_muat,
    AVG(realisasi_bongkar) as avg_bongkar,
    AVG(realisasi_muat) as avg_muat,
    AVG(persen_bongkar) as avg_persen_bongkar,
    AVG(persen_muat) as avg_persen_muat
FROM evaluasi
GROUP BY pelayaran;

-- =====================================================
-- Stored Procedure: Get Statistics
-- =====================================================
DELIMITER $$
CREATE PROCEDURE `sp_get_statistics`()
BEGIN
    SELECT * FROM view_statistik;
END$$
DELIMITER ;

-- =====================================================
-- Stored Procedure: Insert Evaluasi
-- =====================================================
DELIMITER $$
CREATE PROCEDURE `sp_insert_evaluasi`(
    IN p_tanggal VARCHAR(20),
    IN p_shift VARCHAR(50),
    IN p_kapal VARCHAR(100),
    IN p_pelayaran VARCHAR(50),
    IN p_target_bongkar INT,
    IN p_realisasi_bongkar INT,
    IN p_target_muat INT,
    IN p_realisasi_muat INT,
    IN p_persen_bongkar DECIMAL(5,2),
    IN p_persen_muat DECIMAL(5,2),
    IN p_keterangan TEXT
)
BEGIN
    INSERT INTO evaluasi (
        tanggal, shift, kapal, pelayaran,
        target_bongkar, realisasi_bongkar,
        target_muat, realisasi_muat,
        persen_bongkar, persen_muat, keterangan
    ) VALUES (
        p_tanggal, p_shift, p_kapal, p_pelayaran,
        p_target_bongkar, p_realisasi_bongkar,
        p_target_muat, p_realisasi_muat,
        p_persen_bongkar, p_persen_muat, p_keterangan
    );
    
    SELECT LAST_INSERT_ID() as id;
END$$
DELIMITER ;

-- =====================================================
-- END OF SQL SCRIPT
-- =====================================================
