<?php
/**
 * Statistics Endpoints
 * Get statistical data
 */

require_once __DIR__ . '/../config.php';

$database = new Database();
$db = $database->getConnection();

try {
    $query = "SELECT 
                COUNT(*) as total_records,
                SUM(realisasi_bongkar) as total_bongkar,
                SUM(realisasi_muat) as total_muat,
                SUM(target_bongkar) as total_target_bongkar,
                SUM(target_muat) as total_target_muat,
                AVG(realisasi_bongkar) as avg_bongkar,
                AVG(realisasi_muat) as avg_muat,
                AVG(persen_bongkar) as avg_persen_bongkar,
                AVG(persen_muat) as avg_persen_muat
              FROM evaluasi";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Calculate overall percentages
    if ($stats['total_target_bongkar'] > 0) {
        $stats['persen_bongkar'] = ($stats['total_bongkar'] / $stats['total_target_bongkar']) * 100;
    } else {
        $stats['persen_bongkar'] = 0;
    }
    
    if ($stats['total_target_muat'] > 0) {
        $stats['persen_muat'] = ($stats['total_muat'] / $stats['total_target_muat']) * 100;
    } else {
        $stats['persen_muat'] = 0;
    }
    
    // Format numbers
    $stats['total_bongkar'] = (int)$stats['total_bongkar'];
    $stats['total_muat'] = (int)$stats['total_muat'];
    $stats['avg_bongkar'] = (int)$stats['avg_bongkar'];
    $stats['avg_muat'] = (int)$stats['avg_muat'];
    $stats['persen_bongkar'] = round($stats['persen_bongkar'], 2);
    $stats['persen_muat'] = round($stats['persen_muat'], 2);
    
    sendResponse(true, 'Statistics retrieved successfully', $stats);
    
} catch (PDOException $e) {
    sendError('Failed to retrieve statistics: ' . $e->getMessage());
}
?>
