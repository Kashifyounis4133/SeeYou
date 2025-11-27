<?php
// PHP Router Code for hack.html
if (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) == '/') {
    // If the root address (/) is accessed, serve hack.html
    require 'hack.html';
    return true;
}

// All other files (like catch_image.php) will be served automatically
return false; 
?>
