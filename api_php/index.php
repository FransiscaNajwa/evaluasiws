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
    case 'target_data':
        require_once 'endpoints/target_data.php';
        break;

    case 'realisasi_data':
        require_once 'endpoints/realisasi_data.php';
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
                'GET /api_php/index.php?request=test' => 'Test API connection',
                'GET /api_php/index.php?request=target_data' => 'Get all target data',
                'POST /api_php/index.php?request=target_data' => 'Create new target',
                'DELETE /api_php/index.php?request=target_data&id={id}' => 'Delete target',
                'GET /api_php/index.php?request=realisasi_data' => 'Get all realisasi data',
                'POST /api_php/index.php?request=realisasi_data' => 'Create new realisasi',
                'DELETE /api_php/index.php?request=realisasi_data&id={id}' => 'Delete realisasi'
            )
        ));
        break;
}
?>
