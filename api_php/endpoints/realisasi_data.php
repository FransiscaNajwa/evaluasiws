<?php
/**
 * Realisasi Data Endpoints
 * CRUD operations for realisasi_data table
 */

require_once __DIR__ . '/../config.php';

validateApiKey();

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            getRealisasiById($db, $_GET['id']);
        } else {
            getAllRealisasi($db);
        }
        break;

    case 'POST':
        createRealisasi($db);
        break;

    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteRealisasi($db, $_GET['id']);
        } else {
            sendError('ID is required for delete');
        }
        break;

    default:
        sendError('Method not allowed', 405);
        break;
}

function getAllRealisasi($db) {
    try {
        $query = "SELECT * FROM realisasi_data ORDER BY id DESC";
        $stmt = $db->prepare($query);
        $stmt->execute();

        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        sendResponse(true, 'Data retrieved successfully', $data);
    } catch (PDOException $e) {
        sendError('Failed to retrieve data: ' . $e->getMessage());
    }
}

function getRealisasiById($db, $id) {
    try {
        $query = "SELECT * FROM realisasi_data WHERE id = :id";
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

function createRealisasi($db) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            sendError('Invalid JSON input');
        }

        $required = [
            'pelayaran', 'kodeWS', 'namaKapal', 'periode', 'waktuArrival',
            'waktuBerthing', 'waktuDeparture', 'berthingTime',
            'realisasiBongkar', 'realisasiMuat', 'createdAt'
        ];

        foreach ($required as $field) {
            if (!isset($input[$field])) {
                sendError("Field '$field' is required");
            }
        }

        $query = "INSERT INTO realisasi_data (
                    pelayaran, kodeWS, namaKapal, periode,
                    waktuArrival, waktuBerthing, waktuDeparture, berthingTime,
                    realisasiBongkar, realisasiMuat, createdAt
                  ) VALUES (
                    :pelayaran, :kodeWS, :namaKapal, :periode,
                    :waktuArrival, :waktuBerthing, :waktuDeparture, :berthingTime,
                    :realisasiBongkar, :realisasiMuat, :createdAt
                  )";

        $stmt = $db->prepare($query);
        $stmt->bindParam(':pelayaran', $input['pelayaran']);
        $stmt->bindParam(':kodeWS', $input['kodeWS']);
        $stmt->bindParam(':namaKapal', $input['namaKapal']);
        $stmt->bindParam(':periode', $input['periode']);
        $stmt->bindParam(':waktuArrival', $input['waktuArrival']);
        $stmt->bindParam(':waktuBerthing', $input['waktuBerthing']);
        $stmt->bindParam(':waktuDeparture', $input['waktuDeparture']);
        $stmt->bindParam(':berthingTime', $input['berthingTime']);
        $stmt->bindParam(':realisasiBongkar', $input['realisasiBongkar'], PDO::PARAM_INT);
        $stmt->bindParam(':realisasiMuat', $input['realisasiMuat'], PDO::PARAM_INT);
        $stmt->bindParam(':createdAt', $input['createdAt']);
        $stmt->execute();

        sendResponse(true, 'Data created successfully', array('id' => $db->lastInsertId()));
    } catch (PDOException $e) {
        sendError('Failed to create data: ' . $e->getMessage());
    }
}

function deleteRealisasi($db, $id) {
    try {
        $query = "DELETE FROM realisasi_data WHERE id = :id";
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
