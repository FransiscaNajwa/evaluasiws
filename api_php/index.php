<?php
/**
 * TPK Nilam - Evaluasi WS REST API
 * Main Endpoint Router
 */

require_once 'config.php';

// Get request method and endpoint
$method = $_SERVER['REQUEST_METHOD'];
$request = isset($_GET['request']) ? $_GET['request'] : '';

// Route requests
switch ($request) {
    case 'evaluasi':
        require_once 'endpoints/evaluasi.php';
        break;
        
    case 'statistics':
        require_once 'endpoints/statistics.php';
        break;
        
    case 'search':
        require_once 'endpoints/search.php';
        break;
        
    case 'test':
        sendResponse(true, 'API is working!', array(
            'version' => API_VERSION,
            'timestamp' => date('Y-m-d H:i:s')
        ));
        break;
        
    default:
        sendResponse(true, 'TPK Nilam Evaluasi WS API v' . API_VERSION, array(
            'endpoints' => array(
                'GET /api/index.php?request=test' => 'Test API connection',
                'GET /api/index.php?request=evaluasi' => 'Get all evaluasi data',
                'POST /api/index.php?request=evaluasi' => 'Create new evaluasi',
                'PUT /api/index.php?request=evaluasi&id={id}' => 'Update evaluasi',
                'DELETE /api/index.php?request=evaluasi&id={id}' => 'Delete evaluasi',
                'GET /api/index.php?request=statistics' => 'Get statistics',
                'GET /api/index.php?request=search&q={query}' => 'Search evaluasi'
            )
        ));
        break;
}
?>
