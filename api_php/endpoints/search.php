<?php
/**
 * Search Endpoints
 * Search evaluasi data
 */

require_once __DIR__ . '/../config.php';

$database = new Database();
$db = $database->getConnection();

if (!isset($_GET['q'])) {
    sendError('Search query (q) is required');
}

$searchTerm = '%' . $_GET['q'] . '%';

try {
    $query = "SELECT * FROM evaluasi 
              WHERE kapal LIKE :search OR tanggal LIKE :search 
              ORDER BY id DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':search', $searchTerm);
    $stmt->execute();
    
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendResponse(true, 'Search completed successfully', $data);
    
} catch (PDOException $e) {
    sendError('Failed to search data: ' . $e->getMessage());
}
?>
