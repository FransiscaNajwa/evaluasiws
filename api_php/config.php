<?php
/**
 * Database Configuration
 * TPK Nilam - Evaluasi WS API
 */

// Database credentials
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'evaluasiws');

// API Settings
define('API_VERSION', '1.0');
define('API_KEY', 'TPK-NILAM-2026');

// Timezone
date_default_timezone_set('Asia/Jakarta');

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=UTF-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/**
 * Database Connection Class
 */
class Database {
    private $conn;
    
    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME,
                DB_USER,
                DB_PASS,
                array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
                )
            );
        } catch(PDOException $e) {
            echo json_encode(array(
                'success' => false,
                'message' => 'Database connection failed: ' . $e->getMessage()
            ));
            exit();
        }
        
        return $this->conn;
    }
}

/**
 * Response Helper Functions
 */
function sendResponse($success, $message, $data = null) {
    $response = array(
        'success' => $success,
        'message' => $message
    );
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}

function sendError($message, $code = 400) {
    http_response_code($code);
    sendResponse(false, $message);
}

/**
 * Validate API Key
 */
function validateApiKey() {
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $apiKey = '';

    if (isset($headers['Authorization'])) {
        $apiKey = $headers['Authorization'];
    } elseif (isset($headers['authorization'])) {
        $apiKey = $headers['authorization'];
    } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $apiKey = $_SERVER['HTTP_AUTHORIZATION'];
    }
    
    if ($apiKey !== 'Bearer ' . API_KEY) {
        sendError('Invalid API Key', 401);
    }
}
?>
