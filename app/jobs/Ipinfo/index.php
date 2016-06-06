<?php

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header('Content-Type: application/json; charset=utf-8');
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("X-XSS-Protection: 1; mode=block");

header('Access-Control-Allow-Methods: GET');

$origin = ( isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : null );
if ( in_array($origin, [ 'http://www.navihub.net', 'https://www.navihub.net', 'http://beta.navihub.net', 'https://beta.navihub.net', 'http://localhost:3000' ]) ) {
	header('Access-Control-Allow-Origin: '. $origin);
} else {
	header('Access-Control-Allow-Origin: https://www.navihub.net');
} // end if

$json = '{}';
$ip = ( ! empty($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : null );

if ( filter_var($ip, FILTER_VALIDATE_IP) ) {

	$cacheFile = __DIR__ . '/cache/' . md5($ip);
	if ( is_file($cacheFile) && ( time() - filemtime($cacheFile) ) < 604800 ) {
		readfile($cacheFile);
	} else {
		$json = file_get_contents('http://www.ipinfo.io/' . $ip . '/json');
		file_put_contents($cacheFile, $json);
		echo $json;
	} // end if-else
} // end if
