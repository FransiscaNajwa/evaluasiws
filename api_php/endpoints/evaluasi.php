<?php
/**
 * Evaluasi Endpoints
 * CRUD operations for evaluasi data
 */

require_once __DIR__ . '/../config.php';

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Get all evaluasi or specific by ID
        if (isset($_GET['id'])) {
            getEvaluasiById($db, $_GET['id']);
        } else {
            getAllEvaluasi($db);
        }
        break;
        
    case 'POST':
        // Create new evaluasi
        createEvaluasi($db);
        break;
        
    case 'PUT':
        // Update evaluasi
        if (isset($_GET['id'])) {
            updateEvaluasi($db, $_GET['id']);
        } else {
            sendError('ID is required for update');
        }
        break;
        
    case 'DELETE':
        // Delete evaluasi
        if (isset($_GET['id'])) {
            deleteEvaluasi($db, $_GET['id']);
        } else {
            sendError('ID is required for delete');
        }
        break;
        
    default:
        sendError('Method not allowed', 405);
        break;
}

/**
 * Get all evaluasi data
 */
function getAllEvaluasi($db) {
    try {
        $query = "SELECT * FROM evaluasi ORDER BY id DESC";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        sendResponse(true, 'Data retrieved successfully', $data);
    } catch (PDOException $e) {
        sendError('Failed to retrieve data: ' . $e->getMessage());
    }
}

/**
 * Get evaluasi by ID
 */
function getEvaluasiById($db, $id) {
    try {
        $query = "SELECT * FROM evaluasi WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($data) {
            sendResponse(true, 'Data retrieved successfully', $data);
        } else {
            sendError('Data not found', 404);
        }
    } catch (PDOException $e) {
        sendError('Failed to retrieve data: ' . $e->getMessage());
    }
}

/**
 * Create new evaluasi
 */
function createEvaluasi($db) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Validate required fields
        $required = ['tanggal', 'shift', 'kapal', 'pelayaran', 'target_bongkar', 
                     'realisasi_bongkar', 'target_muat', 'realisasi_muat', 
                     'persen_bongkar', 'persen_muat', 'keterangan'];
        
        foreach ($required as $field) {
            if (!isset($input[$field])) {
                sendError("Field '$field' is required");
            }
        }
        
        $query = "INSERT INTO evaluasi (
                    tanggal, shift, kapal, pelayaran,
                    target_bongkar, realisasi_bongkar,
                    target_muat, realisasi_muat,
                    persen_bongkar, persen_muat, keterangan
                  ) VALUES (
                    :tanggal, :shift, :kapal, :pelayaran,
                    :target_bongkar, :realisasi_bongkar,
                    :target_muat, :realisasi_muat,
                    :persen_bongkar, :persen_muat, :keterangan
                  )";
        
        $stmt = $db->prepare($query);
        
        // Bind parameters
        $stmt->bindParam(':tanggal', $input['tanggal']);
        $stmt->bindParam(':shift', $input['shift']);
        $stmt->bindParam(':kapal', $input['kapal']);
        $stmt->bindParam(':pelayaran', $input['pelayaran']);
        $stmt->bindParam(':target_bongkar', $input['target_bongkar'], PDO::PARAM_INT);
        $stmt->bindParam(':realisasi_bongkar', $input['realisasi_bongkar'], PDO::PARAM_INT);
        $stmt->bindParam(':target_muat', $input['target_muat'], PDO::PARAM_INT);
        $stmt->bindParam(':realisasi_muat', $input['realisasi_muat'], PDO::PARAM_INT);
        $stmt->bindParam(':persen_bongkar', $input['persen_bongkar']);
        $stmt->bindParam(':persen_muat', $input['persen_muat']);
        $stmt->bindParam(':keterangan', $input['keterangan']);
        
        $stmt->execute();
        
        sendResponse(true, 'Data created successfully', array('id' => $db->lastInsertId()));
    } catch (PDOException $e) {
        sendError('Failed to create data: ' . $e->getMessage());
    }
}

/**
 * Update evaluasi
 */
function updateEvaluasi($db, $id) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $query = "UPDATE evaluasi SET 
                    tanggal = :tanggal,
                    shift = :shift,
                    kapal = :kapal,
                    pelayaran = :pelayaran,
                    target_bongkar = :target_bongkar,
                    realisasi_bongkar = :realisasi_bongkar,
                    target_muat = :target_muat,
                    realisasi_muat = :realisasi_muat,
                    persen_bongkar = :persen_bongkar,
                    persen_muat = :persen_muat,
                    keterangan = :keterangan
                  WHERE id = :id";
        
        $stmt = $db->prepare($query);
        
        // Bind parameters
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':tanggal', $input['tanggal']);
        $stmt->bindParam(':shift', $input['shift']);
        $stmt->bindParam(':kapal', $input['kapal']);
        $stmt->bindParam(':pelayaran', $input['pelayaran']);
        $stmt->bindParam(':target_bongkar', $input['target_bongkar'], PDO::PARAM_INT);
        $stmt->bindParam(':realisasi_bongkar', $input['realisasi_bongkar'], PDO::PARAM_INT);
        $stmt->bindParam(':target_muat', $input['target_muat'], PDO::PARAM_INT);
        $stmt->bindParam(':realisasi_muat', $input['realisasi_muat'], PDO::PARAM_INT);
        $stmt->bindParam(':persen_bongkar', $input['persen_bongkar']);
        $stmt->bindParam(':persen_muat', $input['persen_muat']);
        $stmt->bindParam(':keterangan', $input['keterangan']);
        
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Data updated successfully');
        } else {
            sendError('Data not found or no changes made', 404);
        }
    } catch (PDOException $e) {
        sendError('Failed to update data: ' . $e->getMessage());
    }
}

/**
 * Delete evaluasi
 */
function deleteEvaluasi($db, $id) {
    try {
        $query = "DELETE FROM evaluasi WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Data deleted successfully');
        } else {
            sendError('Data not found', 404);
        }
    } catch (PDOException $e) {
        sendError('Failed to delete data: ' . $e->getMessage());
    }
}
?>
